const router = require('express').Router();
const ctrl = require('../controllers/review.controller');
const { protect } = require('../middleware/auth');

router.use(protect);
router.post('/', ctrl.createReview);
router.get('/booking/:bookingId', ctrl.getBookingReview);
router.get('/lawyer/:lawyerId', ctrl.getLawyerReviews);

module.exports = router;
