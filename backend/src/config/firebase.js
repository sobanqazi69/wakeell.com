const path  = require('path');
const fs    = require('fs');
const admin = require('firebase-admin');

let initialized = false;

function getFirebaseAdmin() {
  if (initialized) return admin;

  let serviceAccount;

  // 1. Try file path (most reliable — no shell encoding issues)
  const filePath = path.join(__dirname, '../../../firebase-service-account.json');
  if (fs.existsSync(filePath)) {
    try {
      serviceAccount = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (e) {
      console.error('[firebase] Failed to parse service account file:', e.message);
    }
  }

  // 2. Fallback: base64-encoded env var
  if (!serviceAccount) {
    const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    if (!raw) {
      console.warn('[firebase] No service account found — push notifications disabled');
      return null;
    }
    try {
      serviceAccount = JSON.parse(Buffer.from(raw, 'base64').toString('utf8'));
    } catch (e) {
      console.error('[firebase] Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON env var:', e.message);
      return null;
    }
  }

  try {
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    initialized = true;
    console.log('[firebase] Admin SDK initialized for project:', serviceAccount.project_id);
    return admin;
  } catch (e) {
    console.error('[firebase] initializeApp failed:', e.message);
    return null;
  }
}

module.exports = { getFirebaseAdmin };
