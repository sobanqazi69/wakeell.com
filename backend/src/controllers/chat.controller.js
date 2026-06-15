const { ChatMessage, Booking, User } = require('../models');
const notifService = require('../services/notification.service');
let _io = null;
exports.setIo = (io) => { _io = io; };

function isUserActiveInChat(io, userId, bookingId) {
  if (!io) return false;
  const room = io.sockets.adapter.rooms.get(`chat_${bookingId}`);
  if (!room) return false;
  for (const socketId of room) {
    const s = io.sockets.sockets.get(socketId);
    if (s && s.userId === userId) return true;
  }
  return false;
}

exports.getHistory = async (req, res) => {
  try {
    const bookingId = Number(req.params.bookingId);
    const booking = await Booking.findByPk(bookingId);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const isParty = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isParty) return res.status(403).json({ message: 'Access denied' });

    const messages = await ChatMessage.findAll({
      where: { bookingId },
      include: [{ model: User, as: 'sender', attributes: ['id', 'name', 'avatar'] }],
      order: [['createdAt', 'ASC']],
    });

    return res.json({ messages });
  } catch (err) {
    console.error('[chat.getHistory]', err);
    return res.status(500).json({ message: 'Failed to fetch chat history' });
  }
};

exports.sendMessage = async (req, res) => {
  try {
    const bookingId = Number(req.params.bookingId);
    const { message } = req.body;
    if (!message?.trim()) return res.status(400).json({ message: 'Message is required' });

    const booking = await Booking.findByPk(bookingId);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const isParty = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isParty) return res.status(403).json({ message: 'Access denied' });

    const sender = await User.findByPk(req.user.id, { attributes: ['id', 'name', 'avatar'] });

    const msg = await ChatMessage.create({
      bookingId,
      senderId:   req.user.id,
      senderRole: req.user.role,
      message:    message.trim(),
    });

    const payload = {
      id:         msg.id,
      bookingId:  msg.bookingId,
      senderId:   msg.senderId,
      senderRole: msg.senderRole,
      message:    msg.message,
      createdAt:  msg.createdAt,
      sender:     { id: sender.id, name: sender.name, avatar: sender.avatar },
    };

    // Push to anyone else in the chat room via socket (real-time delivery).
    if (_io) _io.to(`chat_${bookingId}`).emit('chat:message', payload);

    // FCM push notification — only if recipient doesn't have this chat open.
    const recipientId = req.user.id === booking.clientId ? booking.lawyerId : booking.clientId;
    if (!isUserActiveInChat(_io, recipientId, bookingId)) {
      const senderName = sender.name || 'Someone';
      const preview = msg.message.length > 80 ? msg.message.substring(0, 80) + '…' : msg.message;
      notifService.send(
        recipientId,
        `New message from ${senderName}`,
        preview,
        'chat_message',
        { bookingId: String(booking.id), senderId: String(req.user.id) },
      ).catch((e) => console.error('[chat.sendMessage] notif error:', e));
    }

    return res.status(201).json({ message: payload });
  } catch (err) {
    console.error('[chat.sendMessage]', err);
    return res.status(500).json({ message: 'Failed to send message' });
  }
};
