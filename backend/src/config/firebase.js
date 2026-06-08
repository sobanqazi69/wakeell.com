const admin = require('firebase-admin');

let initialized = false;

function getFirebaseAdmin() {
  if (initialized) return admin;

  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!raw) {
    console.warn('[firebase] FIREBASE_SERVICE_ACCOUNT_JSON not set — push notifications disabled');
    return null;
  }

  try {
    const serviceAccount = JSON.parse(Buffer.from(raw, 'base64').toString('utf8'));
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    initialized = true;
    console.log('[firebase] Admin SDK initialized');
    return admin;
  } catch (e) {
    console.error('[firebase] Failed to initialize:', e.message);
    return null;
  }
}

module.exports = { getFirebaseAdmin };
