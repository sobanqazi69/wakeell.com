const { Notification, User } = require('../models');
const { getFirebaseAdmin } = require('../config/firebase');

async function send(userId, title, body, type = 'booking_new', data = {}) {
  try {
    await Notification.create({ userId, title, body, type, data });
  } catch (e) {
    console.error('[notif.service] DB create error:', e.message);
  }

  try {
    const user = await User.findByPk(userId, { attributes: ['fcmToken'] });
    if (!user?.fcmToken) return;

    const fb = getFirebaseAdmin();
    if (!fb) return;

    await fb.messaging().send({
      token: user.fcmToken,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      apns: {
        payload: { aps: { sound: 'default', badge: 1 } },
      },
      android: {
        notification: { sound: 'default', channelId: 'wakeell_bookings' },
        priority: 'high',
      },
    });
  } catch (e) {
    // Invalid / stale token — log but don't crash
    if (e.code === 'messaging/registration-token-not-registered') {
      await User.update({ fcmToken: null }, { where: { id: userId } });
    }
    console.error('[notif.service] push error:', e.message);
  }
}

module.exports = { send };
