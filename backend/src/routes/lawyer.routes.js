const router = require('express').Router();
const ctrl = require('../controllers/lawyer.controller');
const { protect, restrictTo } = require('../middleware/auth');

router.get('/', ctrl.getLawyers);
router.get('/:id', ctrl.getLawyerById);
router.get('/:id/availability', ctrl.getAvailability);
router.patch('/profile', protect, restrictTo('lawyer'), ctrl.updateProfile);
router.patch('/availability', protect, restrictTo('lawyer'), ctrl.setAvailability);

module.exports = router;
