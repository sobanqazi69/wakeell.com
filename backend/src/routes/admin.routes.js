const router = require('express').Router();
const ctrl = require('../controllers/admin.controller');
const { protect, restrictTo } = require('../middleware/auth');

router.use(protect, restrictTo('admin'));
router.get('/lawyers/pending', ctrl.getPendingLawyers);
router.patch('/lawyers/:id/verify', ctrl.verifyLawyer);
router.get('/users', ctrl.getUsers);
router.patch('/users/:id/toggle', ctrl.toggleUserActive);

module.exports = router;
