const router = require('express').Router();
const ctrl = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post('/register', ctrl.register);
router.post('/register/lawyer', upload.single('avatar'), ctrl.registerLawyer);
router.post('/login', ctrl.login);
router.post('/google', ctrl.googleAuth);
router.get('/me', protect, ctrl.getMe);
router.patch('/me', protect, ctrl.updateMe);
router.patch('/me/avatar', protect, upload.single('avatar'), ctrl.uploadMyAvatar);
router.delete('/me/avatar', protect, ctrl.removeMyAvatar);
router.patch('/fcm-token', protect, ctrl.updateFcmToken);

module.exports = router;
