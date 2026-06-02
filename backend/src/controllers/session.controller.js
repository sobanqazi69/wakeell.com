const { v4: uuidv4 } = require('uuid');
const Session = require('../models/Session');
const Booking = require('../models/Booking');

exports.createSession = async (req, res) => {
  const booking = await Booking.findById(req.params.bookingId);
  if (!booking) return res.status(404).json({ message: 'Booking not found' });
  if (booking.status !== 'accepted') return res.status(400).json({ message: 'Booking not accepted' });

  let session = await Session.findOne({ booking: booking._id });
  if (!session) {
    session = await Session.create({ booking: booking._id, roomId: uuidv4() });
    booking.sessionRoom = session.roomId;
    await booking.save();
  }

  res.json({ session });
};

exports.getSession = async (req, res) => {
  const session = await Session.findOne({ booking: req.params.bookingId }).populate('booking');
  if (!session) return res.status(404).json({ message: 'Session not found' });
  res.json({ session });
};

exports.writeAdviceSummary = async (req, res) => {
  const { adviceSummary } = req.body;
  const session = await Session.findOne({ booking: req.params.bookingId });
  if (!session) return res.status(404).json({ message: 'Session not found' });

  session.adviceSummary = adviceSummary;
  session.summaryWritten = true;
  await session.save();

  await Booking.findByIdAndUpdate(req.params.bookingId, { status: 'completed' });
  res.json({ session });
};
