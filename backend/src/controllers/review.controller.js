const Review = require('../models/Review');
const Booking = require('../models/Booking');
const Lawyer = require('../models/Lawyer');

exports.createReview = async (req, res) => {
  const { bookingId, rating, comment } = req.body;

  const booking = await Booking.findById(bookingId);
  if (!booking) return res.status(404).json({ message: 'Booking not found' });
  if (booking.client.toString() !== req.user._id.toString()) {
    return res.status(403).json({ message: 'Access denied' });
  }
  if (booking.status !== 'completed') return res.status(400).json({ message: 'Session not completed' });

  const existing = await Review.findOne({ booking: bookingId });
  if (existing) return res.status(400).json({ message: 'Already reviewed' });

  const review = await Review.create({
    booking: bookingId,
    client: req.user._id,
    lawyer: booking.lawyer,
    rating,
    comment: comment || '',
  });

  // Update lawyer's aggregate rating
  const reviews = await Review.find({ lawyer: booking.lawyer });
  const avg = reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;
  await Lawyer.findOneAndUpdate(
    { user: booking.lawyer },
    { rating: Math.round(avg * 10) / 10, reviewCount: reviews.length }
  );

  res.status(201).json({ review });
};

exports.getLawyerReviews = async (req, res) => {
  const reviews = await Review.find({ lawyer: req.params.lawyerId })
    .populate('client', 'name avatar')
    .sort({ createdAt: -1 });
  res.json({ reviews });
};
