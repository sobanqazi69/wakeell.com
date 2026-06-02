const Lawyer = require('../models/Lawyer');
const User = require('../models/User');

exports.getLawyers = async (req, res) => {
  const { category, language, minRating, page = 1, limit = 20 } = req.query;

  const lawyerFilter = { status: 'approved' };
  if (category) lawyerFilter.specializations = category;
  if (language) lawyerFilter.languages = language;
  if (minRating) lawyerFilter.rating = { $gte: Number(minRating) };

  const lawyers = await Lawyer.find(lawyerFilter)
    .populate('user', 'name avatar location jurisdiction')
    .skip((page - 1) * limit)
    .limit(Number(limit));

  res.json({ lawyers });
};

exports.getLawyerById = async (req, res) => {
  const profile = await Lawyer.findById(req.params.id).populate('user', 'name avatar location jurisdiction phone');
  if (!profile) return res.status(404).json({ message: 'Lawyer not found' });
  res.json({ profile });
};

exports.updateProfile = async (req, res) => {
  const { specializations, bio, languages, hourlyRate, experience, education } = req.body;
  const profile = await Lawyer.findOneAndUpdate(
    { user: req.user._id },
    { specializations, bio, languages, hourlyRate, experience, education },
    { new: true }
  );
  res.json({ profile });
};

exports.setAvailability = async (req, res) => {
  const { availability } = req.body; // [{ date: 'YYYY-MM-DD', slots: ['09:00', ...] }]
  const profile = await Lawyer.findOneAndUpdate(
    { user: req.user._id },
    { availability },
    { new: true }
  );
  res.json({ profile });
};

exports.getAvailability = async (req, res) => {
  const profile = await Lawyer.findById(req.params.id, 'availability');
  if (!profile) return res.status(404).json({ message: 'Lawyer not found' });
  res.json({ availability: profile.availability });
};
