const { v4: uuidv4 } = require('uuid');
const { AccessToken } = require('livekit-server-sdk');
const { Session, Booking, User } = require('../models');
const egressService = require('../services/egress.service');

// Socket.io instance — set by index.js after server starts
let _io = null;
exports.setIo = (io) => { _io = io; };

// In-memory no-show timers: bookingId → timeoutId
const _noShowTimers = {};

function _scheduleNoShowCheck(session, booking) {
  if (!_io) return;

  // Cancel any existing timer for this booking
  if (_noShowTimers[session.bookingId]) {
    clearTimeout(_noShowTimers[session.bookingId]);
  }

  // Fire 5 minutes after the scheduled booking start time
  const bookingStart = new Date(`${booking.date}T${booking.timeSlot}:00`);
  const now = new Date();
  const msUntilDeadline = Math.max(bookingStart.getTime() - now.getTime(), 0) + 5 * 60 * 1000;

  _noShowTimers[session.bookingId] = setTimeout(async () => {
    try {
      delete _noShowTimers[session.bookingId];

      const fresh = await Session.findByPk(session.id);
      if (!fresh) return;
      if (fresh.lawyerJoined) return;    // lawyer showed up — all good
      if (fresh.status === 'ended') return; // already ended normally

      const bk = await Booking.findByPk(session.bookingId);
      if (!bk || bk.status !== 'accepted') return; // booking already resolved

      await fresh.update({ status: 'ended' });
      await bk.update({ status: 'cancelled', cancellationReason: 'Lawyer did not join' });

      _io.to(fresh.roomId).emit('session_auto_cancelled', {
        bookingId: session.bookingId,
        reason: 'Lawyer did not join',
      });
    } catch (e) {
      console.error('[session.noShowTimer]', e.message);
    }
  }, msUntilDeadline);
}

exports.createSession = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.bookingId);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.status !== 'accepted') {
      return res.status(400).json({ message: 'Booking must be accepted before starting a session' });
    }

    const isParty = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isParty) return res.status(403).json({ message: 'Access denied' });

    let session = await Session.findOne({ where: { bookingId: booking.id } });
    if (!session) {
      const roomId = uuidv4();
      session = await Session.create({ bookingId: booking.id, roomId });
      await booking.update({ sessionRoom: roomId });
    }

    return res.json({ session });
  } catch (err) {
    console.error('[session.createSession]', err);
    return res.status(500).json({ message: 'Failed to create session' });
  }
};

exports.getSession = async (req, res) => {
  try {
    const session = await Session.findOne({
      where: { bookingId: req.params.bookingId },
      include: [{ association: 'booking' }],
    });
    if (!session) return res.status(404).json({ message: 'Session not found' });
    return res.json({ session });
  } catch (err) {
    console.error('[session.getSession]', err);
    return res.status(500).json({ message: 'Failed to fetch session' });
  }
};

exports.joinToken = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.bookingId, {
      include: [{ model: User, as: 'client', attributes: ['id', 'name'] }],
    });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.status !== 'accepted') {
      return res.status(400).json({ message: 'Session is not available — booking must be accepted' });
    }

    const isParty = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isParty) return res.status(403).json({ message: 'Access denied' });

    // Create/retrieve session row (idempotent)
    let session = await Session.findOne({ where: { bookingId: booking.id } });
    if (!session) {
      const roomId = uuidv4();
      session = await Session.create({ bookingId: booking.id, roomId });
      await booking.update({ sessionRoom: session.roomId });
    }

    // Build LiveKit access token
    const apiKey    = process.env.LIVEKIT_API_KEY;
    const apiSecret = process.env.LIVEKIT_API_SECRET;
    const wsUrl     = process.env.LIVEKIT_WS_URL;

    const identity = `user_${req.user.id}`;
    const at = new AccessToken(apiKey, apiSecret, {
      identity,
      name: req.user.name || identity,
      ttl: 3600,
    });
    at.addGrant({ roomJoin: true, room: session.roomId, canPublish: true, canSubscribe: true });
    const token = await at.toJwt();

    // Track who has joined and handle no-show timer
    const isClient = booking.clientId === req.user.id;
    const isLawyer = booking.lawyerId === req.user.id;
    const wasClientJoined = session.clientJoined;
    const wasLawyerJoined = session.lawyerJoined;

    if (isClient && !session.clientJoined) {
      await session.update({ clientJoined: true });
    }
    if (isLawyer && !session.lawyerJoined) {
      await session.update({ lawyerJoined: true });
      // Lawyer arrived — cancel any pending no-show timer
      if (_noShowTimers[booking.id]) {
        clearTimeout(_noShowTimers[booking.id]);
        delete _noShowTimers[booking.id];
      }
    }

    await session.reload();

    if (!session.startedAt && session.clientJoined && session.lawyerJoined) {
      await session.update({ status: 'active', startedAt: new Date() });
      await session.reload();

      // Start recording as soon as both parties are connected — fire and forget
      if (!session.egressId) {
        egressService.startRecording(session.roomId, session.id, booking.sessionType)
          .then(async (result) => {
            if (result) {
              await session.update({ egressId: result.egressId, recordingKey: result.recordingKey });
            }
          })
          .catch((e) => console.error('[session.joinToken] startRecording:', e.message));
      }
    }

    // If the client just joined for the first time and the lawyer hasn't arrived,
    // schedule the no-show check (fires 5 min after the booking's scheduled start)
    if (isClient && !wasClientJoined && !session.lawyerJoined) {
      _scheduleNoShowCheck(session, booking);
    }

    return res.json({ token, wsUrl, roomId: session.roomId, sessionId: session.id });
  } catch (err) {
    console.error('[session.joinToken]', err);
    return res.status(500).json({ message: 'Failed to generate session token' });
  }
};

exports.endSession = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.bookingId);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const isParty = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isParty) return res.status(403).json({ message: 'Access denied' });

    const session = await Session.findOne({ where: { bookingId: booking.id } });

    // Only complete if both parties actually connected — prevents early-join/early-leave
    // from permanently closing the session before it even started.
    if (!session || session.status !== 'active') {
      return res.json({ message: 'Session not yet active — no changes made' });
    }

    // Cancel any pending no-show timer since the session ended normally
    if (_noShowTimers[booking.id]) {
      clearTimeout(_noShowTimers[booking.id]);
      delete _noShowTimers[booking.id];
    }

    if (booking.status !== 'completed') {
      await booking.update({ status: 'completed', endedAt: new Date() });
      await session.update({ status: 'ended', endedAt: new Date() });

      // Stop the egress recording — LiveKit Egress will upload the file to MinIO
      if (session.egressId) {
        egressService.stopRecording(session.egressId).catch(() => {});
      }
    }

    return res.json({ message: 'Session ended' });
  } catch (err) {
    console.error('[session.endSession]', err);
    return res.status(500).json({ message: 'Failed to end session' });
  }
};

exports.getRecording = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.bookingId);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const isParty = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isParty) return res.status(403).json({ message: 'Access denied' });

    const session = await Session.findOne({ where: { bookingId: booking.id } });
    if (!session?.recordingKey) {
      return res.status(404).json({ message: 'No recording available for this session' });
    }

    const url = await egressService.getPresignedUrl(session.recordingKey);
    if (!url) return res.status(500).json({ message: 'Could not generate recording URL' });

    return res.json({ url, recordingKey: session.recordingKey });
  } catch (err) {
    console.error('[session.getRecording]', err);
    return res.status(500).json({ message: 'Failed to fetch recording' });
  }
};

exports.writeAdviceSummary = async (req, res) => {
  try {
    const { adviceSummary } = req.body;
    if (!adviceSummary) return res.status(400).json({ message: 'adviceSummary is required' });

    const session = await Session.findOne({ where: { bookingId: req.params.bookingId } });
    if (!session) return res.status(404).json({ message: 'Session not found' });

    const booking = await Booking.findByPk(req.params.bookingId);
    if (booking.lawyerId !== req.user.id) {
      return res.status(403).json({ message: 'Only the lawyer can write the advice summary' });
    }

    await session.update({ adviceSummary, summaryWritten: true });
    await booking.update({ status: 'completed' });

    return res.json({ session });
  } catch (err) {
    console.error('[session.writeAdviceSummary]', err);
    return res.status(500).json({ message: 'Failed to write advice summary' });
  }
};
