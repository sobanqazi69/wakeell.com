const router = require('express').Router();
const ctrl = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth');

router.post('/register', ctrl.register);
router.post('/register/lawyer', ctrl.registerLawyer);
router.post('/login', ctrl.login);
router.get('/me', protect, ctrl.getMe);
router.patch('/me', protect, ctrl.updateMe);
router.patch('/fcm-token', protect, ctrl.updateFcmToken);

module.exports = router;
