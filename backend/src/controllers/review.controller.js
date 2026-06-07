const { Review, Booking, Lawyer, User } = require('../models');
const sequelize = require('../config/db');

exports.createReview = async (req, res) => {
  try {
    const { bookingId, rating, comment } = req.body;

    if (!bookingId || !rating) {
      return res.status(400).json({ message: 'bookingId and rating are required' });
    }
    if (rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }

    const booking = await Booking.findByPk(bookingId);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.clientId !== req.user.id) {
      return res.status(403).json({ message: 'Only the client can leave a review' });
    }
    if (booking.status !== 'completed') {
      return res.status(400).json({ message: 'Session must be completed before reviewing' });
    }

    const existing = await Review.findOne({ where: { bookingId } });
    if (existing) return res.status(400).json({ message: 'You have already reviewed this session' });

    const review = await Review.create({
      bookingId,
      clientId: req.user.id,
      lawyerId: booking.lawyerId,
      rating,
      comment: comment || '',
    });

    // Recalculate lawyer's aggregate rating
    const result = await Review.findOne({
      where: { lawyerId: booking.lawyerId },
      attributes: [
        [sequelize.fn('AVG', sequelize.col('rating')), 'avg'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'count'],
      ],
      raw: true,
    });

    await Lawyer.update(
      {
        rating: Math.round(Number(result.avg) * 10) / 10,
        reviewCount: Number(result.count),
      },
      { where: { userId: booking.lawyerId } }
    );

    return res.status(201).json({ review });
  } catch (err) {
    console.error('[review.createReview]', err);
    return res.status(500).json({ message: 'Failed to submit review' });
  }
};

exports.getLawyerReviews = async (req, res) => {
  try {
    const reviews = await Review.findAll({
      where: { lawyerId: req.params.lawyerId },
      include: [{ model: User, as: 'client', attributes: ['id', 'name', 'avatar'] }],
      order: [['createdAt', 'DESC']],
    });
    return res.json({ reviews });
  } catch (err) {
    console.error('[review.getLawyerReviews]', err);
    return res.status(500).json({ message: 'Failed to fetch reviews' });
  }
};
