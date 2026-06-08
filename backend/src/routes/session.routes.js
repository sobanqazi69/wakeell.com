const router = require('express').Router();
const ctrl = require('../controllers/session.controller');
const { protect } = require('../middleware/auth');

router.use(protect);
router.post('/:bookingId', ctrl.createSession);
router.get('/:bookingId', ctrl.getSession);
router.post('/:bookingId/token', ctrl.joinToken);        // returns LiveKit JWT + wsUrl
router.patch('/:bookingId/end', ctrl.endSession);
router.patch('/:bookingId/summary', ctrl.writeAdviceSummary);

module.exports = router;
