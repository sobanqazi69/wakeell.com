const { ChatMessage, Booking, User } = require('../models');

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
