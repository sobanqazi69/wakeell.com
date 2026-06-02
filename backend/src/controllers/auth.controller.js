const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Lawyer = require('../models/Lawyer');

const signToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '7d' });

exports.register = async (req, res) => {
  const { name, email, password, role, phone, location, jurisdiction } = req.body;
  const existing = await User.findOne({ email });
  if (existing) return res.status(400).json({ message: 'Email already in use' });

  const user = await User.create({ name, email, password, role, phone, location, jurisdiction });
  const token = signToken(user._id);
  res.status(201).json({ token, user: { id: user._id, name, email, role } });
};

exports.registerLawyer = async (req, res) => {
  const { name, email, password, phone, barLicense, specializations, bio, languages, hourlyRate } = req.body;
  const existing = await User.findOne({ email });
  if (existing) return res.status(400).json({ message: 'Email already in use' });

  const user = await User.create({ name, email, password, role: 'lawyer', phone });
  await Lawyer.create({
    user: user._id,
    barLicense,
    specializations: specializations || [],
    bio: bio || '',
    languages: languages || [],
    hourlyRate: hourlyRate || 0,
    status: 'pending',
  });

  res.status(201).json({ message: 'Registration submitted. Awaiting admin approval.' });
};

exports.login = async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email }).select('+password');
  if (!user || !(await user.comparePassword(password))) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }
  if (!user.isActive) return res.status(403).json({ message: 'Account suspended' });

  if (user.role === 'lawyer') {
    const profile = await Lawyer.findOne({ user: user._id });
    if (profile?.status === 'pending') {
      return res.status(403).json({ message: 'Account pending admin approval' });
    }
    if (profile?.status === 'rejected') {
      return res.status(403).json({ message: 'Account application rejected' });
    }
  }

  const token = signToken(user._id);
  res.json({ token, user: { id: user._id, name: user.name, email: user.email, role: user.role } });
};

exports.getMe = async (req, res) => {
  const user = await User.findById(req.user._id);
  res.json({ user });
};

exports.updateFcmToken = async (req, res) => {
  const { fcmToken } = req.body;
  await User.findByIdAndUpdate(req.user._id, { fcmToken });
  res.json({ message: 'FCM token updated' });
};
