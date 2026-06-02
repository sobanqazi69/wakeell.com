const User = require('../models/User');
const Lawyer = require('../models/Lawyer');

exports.getPendingLawyers = async (req, res) => {
  const lawyers = await Lawyer.find({ status: 'pending' }).populate('user', 'name email phone');
  res.json({ lawyers });
};

exports.verifyLawyer = async (req, res) => {
  const { status, adminNote } = req.body; // 'approved' | 'rejected'
  const lawyer = await Lawyer.findByIdAndUpdate(
    req.params.id,
    { status, adminNote: adminNote || null },
    { new: true }
  ).populate('user', 'name email');

  if (!lawyer) return res.status(404).json({ message: 'Lawyer not found' });

  if (status === 'approved') {
    await User.findByIdAndUpdate(lawyer.user._id, { isVerified: true });
  }

  res.json({ lawyer });
};

exports.getUsers = async (req, res) => {
  const users = await User.find().sort({ createdAt: -1 });
  res.json({ users });
};

exports.toggleUserActive = async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) return res.status(404).json({ message: 'User not found' });
  user.isActive = !user.isActive;
  await user.save();
  res.json({ user });
};
