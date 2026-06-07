const { v4: uuidv4 } = require('uuid');
const { Session, Booking } = require('../models');

exports.createSession = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.bookingId);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.status !== 'accepted') {
      return res.status(400).json({ message: 'Booking must be accepted before starting a session' });
    }

    const isParty = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isParty) return res.status(403).json({ message: 'Access denied' });

    // Idempotent — return existing session if already created
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

exports.writeAdviceSummary = async (req, res) => {
  try {
    const { adviceSummary } = req.body;
    if (!adviceSummary) return res.status(400).json({ message: 'adviceSummary is required' });

    const session = await Session.findOne({ where: { bookingId: req.params.bookingId } });
    if (!session) return res.status(404).json({ message: 'Session not found' });

    // Only the lawyer can write the summary
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
