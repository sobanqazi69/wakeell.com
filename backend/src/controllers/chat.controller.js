const { ChatMessage, Booking, User } = require('../models');
let _io = null;
exports.setIo = (io) => { _io = io; };

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

    return res.status(201).json({ message: payload });
  } catch (err) {
    console.error('[chat.sendMessage]', err);
    return res.status(500).json({ message: 'Failed to send message' });
  }
};
