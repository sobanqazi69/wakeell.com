const router = require('express').Router();
const ctrl = require('../controllers/booking.controller');
const { protect } = require('../middleware/auth');

router.use(protect);
router.post('/', ctrl.createBooking);
router.get('/', ctrl.getMyBookings);
router.get('/:id', ctrl.getBookingById);
router.patch('/:id/respond', ctrl.respondToBooking);
router.patch('/:id/cancel', ctrl.cancelBooking);

module.exports = router;
