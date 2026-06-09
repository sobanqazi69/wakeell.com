const router = require('express').Router();
const ctrl = require('../controllers/chat.controller');
const { protect } = require('../middleware/auth');

router.use(protect);
router.get('/:bookingId', ctrl.getHistory);
router.post('/:bookingId', ctrl.sendMessage);

module.exports = router;
