/**
 * egress.service.js
 *
 * Wraps LiveKit Egress (room recording) and MinIO (S3-compatible object storage).
 *
 * Env vars required:
 *   LIVEKIT_API_KEY        — same key used for token generation
 *   LIVEKIT_API_SECRET     — same secret
 *   LIVEKIT_WS_URL         — e.g. wss://wakeell.livekit.cloud  (used to derive HTTP host)
 *   LIVEKIT_HOST           — optional override, e.g. https://wakeell.livekit.cloud
 *
 *   MINIO_ENDPOINT         — hostname only, e.g. "localhost" or "72.61.147.68"
 *   MINIO_PORT             — default 9000
 *   MINIO_USE_SSL          — "true" | "false"
 *   MINIO_ACCESS_KEY       — MinIO root user
 *   MINIO_SECRET_KEY       — MinIO root password
 *   MINIO_BUCKET           — e.g. "wakeell-recordings"
 *   MINIO_PUBLIC_BASE      — public base URL for presigned links,
 *                            e.g. "http://72.61.147.68:9000"
 *                            If MinIO is behind nginx at a domain, use that.
 */

const { EgressClient } = require('livekit-server-sdk');
const Minio = require('minio');

// ── LiveKit Egress client ─────────────────────────────────────────────────────

const _wsUrl     = process.env.LIVEKIT_WS_URL || '';
const _httpHost  = process.env.LIVEKIT_HOST ||
  _wsUrl.replace(/^wss:\/\//, 'https://').replace(/^ws:\/\//, 'http://');

let egressClient = null;
function _egress() {
  if (!egressClient) {
    egressClient = new EgressClient(
      _httpHost,
      process.env.LIVEKIT_API_KEY,
      process.env.LIVEKIT_API_SECRET,
    );
  }
  return egressClient;
}

// ── MinIO client ──────────────────────────────────────────────────────────────

const _minioEndpoint  = process.env.MINIO_ENDPOINT   || 'localhost';
const _minioPort      = parseInt(process.env.MINIO_PORT || '9000', 10);
const _minioSsl       = process.env.MINIO_USE_SSL === 'true';
const _minioAccessKey = process.env.MINIO_ACCESS_KEY  || 'minioadmin';
const _minioSecretKey = process.env.MINIO_SECRET_KEY  || 'minioadmin';
const _minioBucket    = process.env.MINIO_BUCKET      || 'wakeell-recordings';
const _minioPublicBase = process.env.MINIO_PUBLIC_BASE ||
  `${_minioSsl ? 'https' : 'http'}://${_minioEndpoint}:${_minioPort}`;

const minioClient = new Minio.Client({
  endPoint:  _minioEndpoint,
  port:      _minioPort,
  useSSL:    _minioSsl,
  accessKey: _minioAccessKey,
  secretKey: _minioSecretKey,
});

// Ensure the bucket exists on startup (non-fatal)
(async () => {
  try {
    const exists = await minioClient.bucketExists(_minioBucket);
    if (!exists) {
      await minioClient.makeBucket(_minioBucket, 'us-east-1');
      console.log(`[egress] Created MinIO bucket: ${_minioBucket}`);
    }
  } catch (e) {
    console.warn('[egress] Could not verify/create MinIO bucket:', e.message);
  }
})();

// ── Public API ────────────────────────────────────────────────────────────────

/**
 * Start recording a LiveKit room.
 * Called when session.status transitions to 'active' (both parties connected).
 *
 * @param {string} roomId       — LiveKit room name
 * @param {number} sessionId    — our DB session ID (used for the filename)
 * @param {string} sessionType  — 'video' | 'audio' | 'text'
 * @returns {{ egressId: string, recordingKey: string } | null}
 */
exports.startRecording = async (roomId, sessionId, sessionType) => {
  try {
    const recordingKey = `session_${sessionId}.mp4`;

    const s3Config = {
      accessKey: _minioAccessKey,
      secret:    _minioSecretKey,
      region:    'us-east-1',
      endpoint:  `${_minioSsl ? 'https' : 'http'}://${_minioEndpoint}:${_minioPort}`,
      bucket:    _minioBucket,
      forcePathStyle: true,
    };

    const fileOutput = {
      fileType: 1,          // 1 = MP4
      filepath: recordingKey,
      output: { case: 's3', value: s3Config },
    };

    const isAudio = sessionType === 'audio';
    const opts = isAudio
      ? { audioOnly: true }
      : { layout: 'grid' };

    const info = await _egress().startRoomCompositeEgress(roomId, { file: fileOutput }, opts);

    console.log(`[egress] Recording started: egressId=${info.egressId} key=${recordingKey}`);
    return { egressId: info.egressId, recordingKey };
  } catch (e) {
    console.error('[egress.startRecording]', e.message);
    return null;
  }
};

/**
 * Stop a running egress job.
 * LiveKit Egress will finalize the file and upload it to MinIO automatically.
 */
exports.stopRecording = async (egressId) => {
  if (!egressId) return;
  try {
    await _egress().stopEgress(egressId);
    console.log(`[egress] Recording stopped: ${egressId}`);
  } catch (e) {
    console.error('[egress.stopRecording]', e.message);
  }
};

/**
 * Generate a time-limited presigned URL so the client/lawyer can watch the recording.
 * The URL is valid for 24 hours. MinIO's internal URL is rewritten to the public base.
 *
 * @param {string} recordingKey — object key inside the bucket (e.g. "session_42.mp4")
 * @returns {string | null}
 */
exports.getPresignedUrl = async (recordingKey) => {
  try {
    const expirySeconds = 60 * 60 * 24; // 24 hours
    const raw = await minioClient.presignedGetObject(_minioBucket, recordingKey, expirySeconds);

    // MinIO signs URLs with its internal endpoint; replace with the public base
    // so the URL is reachable from outside the server.
    const internalBase = `${_minioSsl ? 'https' : 'http'}://${_minioEndpoint}:${_minioPort}`;
    const publicUrl = raw.replace(internalBase, _minioPublicBase);

    return publicUrl;
  } catch (e) {
    console.error('[egress.getPresignedUrl]', e.message);
    return null;
  }
};
