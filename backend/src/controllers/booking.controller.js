const Booking = require('../models/Booking');
const Lawyer = require('../models/Lawyer');

exports.createBooking = async (req, res) => {
  const { lawyerId, date, timeSlot, sessionType, category, caseBrief, duration } = req.body;

  const lawyerProfile = await Lawyer.findById(lawyerId);
  if (!lawyerProfile) return res.status(404).json({ message: 'Lawyer not found' });

  // Check slot is still available
  const daySlots = lawyerProfile.availability.find((a) => a.date === date);
  if (!daySlots || !daySlots.slots.includes(timeSlot)) {
    return res.status(400).json({ message: 'Time slot not available' });
  }

  const booking = await Booking.create({
    client: req.user._id,
    lawyer: lawyerProfile.user,
    lawyerProfile: lawyerProfile._id,
    date,
    timeSlot,
    duration: duration || 60,
    sessionType: sessionType || 'video',
    category,
    caseBrief: caseBrief || '',
  });

  res.status(201).json({ booking });
};

exports.getMyBookings = async (req, res) => {
  const filter = req.user.role === 'client'
    ? { client: req.user._id }
    : { lawyer: req.user._id };

  const bookings = await Booking.find(filter)
    .populate('client', 'name avatar')
    .populate('lawyer', 'name avatar')
    .populate('lawyerProfile', 'specializations rating')
    .sort({ createdAt: -1 });

  res.json({ bookings });
};

exports.getBookingById = async (req, res) => {
  const booking = await Booking.findById(req.params.id)
    .populate('client', 'name avatar phone')
    .populate('lawyer', 'name avatar')
    .populate('lawyerProfile');

  if (!booking) return res.status(404).json({ message: 'Booking not found' });

  const isOwner =
    booking.client._id.toString() === req.user._id.toString() ||
    booking.lawyer._id.toString() === req.user._id.toString();
  if (!isOwner && req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Access denied' });
  }

  res.json({ booking });
};

exports.respondToBooking = async (req, res) => {
  const { status } = req.body; // 'accepted' | 'declined'
  const booking = await Booking.findById(req.params.id);
  if (!booking) return res.status(404).json({ message: 'Booking not found' });
  if (booking.lawyer.toString() !== req.user._id.toString()) {
    return res.status(403).json({ message: 'Access denied' });
  }

  booking.status = status;
  await booking.save();
  res.json({ booking });
};

exports.cancelBooking = async (req, res) => {
  const booking = await Booking.findById(req.params.id);
  if (!booking) return res.status(404).json({ message: 'Booking not found' });

  const isOwner =
    booking.client.toString() === req.user._id.toString() ||
    booking.lawyer.toString() === req.user._id.toString();
  if (!isOwner) return res.status(403).json({ message: 'Access denied' });

  booking.status = 'cancelled';
  await booking.save();
  res.json({ booking });
};
