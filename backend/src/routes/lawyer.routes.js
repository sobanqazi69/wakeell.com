const router = require('express').Router();
const ctrl = require('../controllers/lawyer.controller');
const { protect, restrictTo } = require('../middleware/auth');

// Public
router.get('/', ctrl.getLawyers);

// Authenticated lawyer-only (must be before /:id to avoid param collision)
router.get('/me', protect, restrictTo('lawyer'), ctrl.getMyProfile);
router.patch('/profile', protect, restrictTo('lawyer'), ctrl.updateProfile);
router.patch('/availability', protect, restrictTo('lawyer'), ctrl.setAvailability);

// Public by ID (after /me to avoid collision)
router.get('/:id', ctrl.getLawyerById);
router.get('/:id/availability', ctrl.getAvailability);

module.exports = router;
