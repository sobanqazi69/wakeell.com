const { Notification } = require('../models');

exports.getMyNotifications = async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']],
      limit: 50,
    });
    const unreadCount = notifications.filter(n => !n.isRead).length;
    return res.json({ notifications, unreadCount });
  } catch (err) {
    console.error('[notification.getMyNotifications]', err);
    return res.status(500).json({ message: 'Failed to fetch notifications' });
  }
};

exports.markRead = async (req, res) => {
  try {
    await Notification.update(
      { isRead: true },
      { where: { id: req.params.id, userId: req.user.id } }
    );
    return res.json({ success: true });
  } catch (err) {
    console.error('[notification.markRead]', err);
    return res.status(500).json({ message: 'Failed to mark notification' });
  }
};

exports.markAllRead = async (req, res) => {
  try {
    await Notification.update(
      { isRead: true },
      { where: { userId: req.user.id, isRead: false } }
    );
    return res.json({ success: true });
  } catch (err) {
    console.error('[notification.markAllRead]', err);
    return res.status(500).json({ message: 'Failed to mark all notifications' });
  }
};
