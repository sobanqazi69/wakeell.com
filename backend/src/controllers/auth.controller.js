const jwt = require('jsonwebtoken');
const { User, Lawyer } = require('../models');

const signToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '7d' });

exports.register = async (req, res) => {
  try {
    const { name, email, password, role = 'client', phone, location, jurisdiction } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Name, email and password are required' });
    }

    const existing = await User.findOne({ where: { email: email.toLowerCase() } });
    if (existing) return res.status(400).json({ message: 'Email already in use' });

    const user = await User.create({ name, email, password, role, phone, location, jurisdiction });
    const token = signToken(user.id);

    return res.status(201).json({
      token,
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
    });
  } catch (err) {
    console.error('[auth.register]', err);
    return res.status(500).json({ message: 'Registration failed. Please try again.' });
  }
};

exports.registerLawyer = async (req, res) => {
  try {
    const { name, email, password, phone, barLicense, specializations, bio, languages, hourlyRate } = req.body;

    if (!name || !email || !password || !barLicense) {
      return res.status(400).json({ message: 'Name, email, password and bar license are required' });
    }

    const existing = await User.findOne({ where: { email: email.toLowerCase() } });
    if (existing) return res.status(400).json({ message: 'Email already in use' });

    const user = await User.create({ name, email, password, role: 'lawyer', phone });
    await Lawyer.create({
      userId: user.id,
      barLicense,
      specializations: specializations || [],
      bio: bio || '',
      languages: languages || [],
      hourlyRate: hourlyRate || 0,
      status: 'pending',
    });

    return res.status(201).json({ message: 'Registration submitted. Awaiting admin approval.' });
  } catch (err) {
    console.error('[auth.registerLawyer]', err);
    return res.status(500).json({ message: 'Lawyer registration failed. Please try again.' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const user = await User.findOne({ where: { email: email.toLowerCase() } });
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

    if (!user.isActive) return res.status(403).json({ message: 'Account suspended' });

    if (user.role === 'lawyer') {
      const profile = await Lawyer.findOne({ where: { userId: user.id } });
      if (profile?.status === 'pending') {
        return res.status(403).json({ message: 'Account pending admin approval' });
      }
      if (profile?.status === 'rejected') {
        return res.status(403).json({ message: 'Account application rejected' });
      }
    }

    const token = signToken(user.id);
    return res.json({
      token,
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
    });
  } catch (err) {
    console.error('[auth.login]', err);
    return res.status(500).json({ message: 'Login failed. Please try again.' });
  }
};

exports.getMe = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    return res.json({ user });
  } catch (err) {
    console.error('[auth.getMe]', err);
    return res.status(500).json({ message: 'Failed to fetch profile' });
  }
};

exports.updateMe = async (req, res) => {
  try {
    const { name, phone, location, jurisdiction } = req.body;
    const user = await User.findByPk(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const updates = {};
    if (name !== undefined) updates.name = name;
    if (phone !== undefined) updates.phone = phone;
    if (location !== undefined) updates.location = location;
    if (jurisdiction !== undefined) updates.jurisdiction = jurisdiction;

    await user.update(updates);
    return res.json({ user });
  } catch (err) {
    console.error('[auth.updateMe]', err);
    return res.status(500).json({ message: 'Failed to update profile' });
  }
};

exports.updateFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) return res.status(400).json({ message: 'fcmToken is required' });

    await User.update({ fcmToken }, { where: { id: req.user.id } });
    return res.json({ message: 'FCM token updated' });
  } catch (err) {
    console.error('[auth.updateFcmToken]', err);
    return res.status(500).json({ message: 'Failed to update FCM token' });
  }
};
