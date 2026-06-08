const { Op } = require('sequelize');
const { Lawyer, User, LawyerAvailability } = require('../models');

exports.getLawyers = async (req, res) => {
  try {
    const { search, category, language, minRating, page = 1, limit = 20 } = req.query;

    const where = { status: 'approved' };
    if (minRating) where.rating = { [Op.gte]: Number(minRating) };

    const userWhere = {};
    if (search && search.trim()) {
      userWhere.name = { [Op.like]: `%${search.trim()}%` };
    }

    const lawyers = await Lawyer.findAll({
      where,
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'name', 'avatar', 'location', 'jurisdiction'],
        where: Object.keys(userWhere).length ? userWhere : undefined,
      }],
      limit: Number(limit),
      offset: (Number(page) - 1) * Number(limit),
      order: [['rating', 'DESC']],
    });

    // JS-side filter for JSON array fields (category / language)
    const filtered = lawyers.filter((l) => {
      if (category && !l.specializations.includes(category)) return false;
      if (language && !l.languages.includes(language)) return false;
      return true;
    });

    return res.json({ lawyers: filtered });
  } catch (err) {
    console.error('[lawyer.getLawyers]', err);
    return res.status(500).json({ message: 'Failed to fetch lawyers' });
  }
};

exports.getMyProfile = async (req, res) => {
  try {
    const profile = await Lawyer.findOne({
      where: { userId: req.user.id },
      include: [{ model: User, as: 'user', attributes: ['id', 'name', 'email', 'avatar', 'location', 'jurisdiction', 'phone'] }],
    });
    if (!profile) return res.status(404).json({ message: 'Lawyer profile not found' });
    return res.json({ profile });
  } catch (err) {
    console.error('[lawyer.getMyProfile]', err);
    return res.status(500).json({ message: 'Failed to fetch profile' });
  }
};

exports.getLawyerById = async (req, res) => {
  try {
    const profile = await Lawyer.findByPk(req.params.id, {
      include: [{ model: User, as: 'user', attributes: ['id', 'name', 'avatar', 'location', 'jurisdiction', 'phone'] }],
    });
    if (!profile) return res.status(404).json({ message: 'Lawyer not found' });
    return res.json({ profile });
  } catch (err) {
    console.error('[lawyer.getLawyerById]', err);
    return res.status(500).json({ message: 'Failed to fetch lawyer profile' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { specializations, bio, languages, hourlyRate, experience, education } = req.body;

    const profile = await Lawyer.findOne({ where: { userId: req.user.id } });
    if (!profile) return res.status(404).json({ message: 'Lawyer profile not found' });

    await profile.update({ specializations, bio, languages, hourlyRate, experience, education });
    return res.json({ profile });
  } catch (err) {
    console.error('[lawyer.updateProfile]', err);
    return res.status(500).json({ message: 'Failed to update profile' });
  }
};

exports.setAvailability = async (req, res) => {
  try {
    const { availability } = req.body; // [{ date: 'YYYY-MM-DD', slots: ['09:00', ...] }]

    if (!Array.isArray(availability)) {
      return res.status(400).json({ message: 'availability must be an array' });
    }

    const profile = await Lawyer.findOne({ where: { userId: req.user.id } });
    if (!profile) return res.status(404).json({ message: 'Lawyer profile not found' });

    // Replace all availability records for this lawyer
    await LawyerAvailability.destroy({ where: { lawyerId: profile.id } });
    await LawyerAvailability.bulkCreate(
      availability.map((a) => ({ lawyerId: profile.id, date: a.date, slots: a.slots || [] }))
    );

    const updated = await LawyerAvailability.findAll({ where: { lawyerId: profile.id } });
    return res.json({ availability: updated });
  } catch (err) {
    console.error('[lawyer.setAvailability]', err);
    return res.status(500).json({ message: 'Failed to set availability' });
  }
};

exports.getAvailability = async (req, res) => {
  try {
    const profile = await Lawyer.findByPk(req.params.id, { attributes: ['id'] });
    if (!profile) return res.status(404).json({ message: 'Lawyer not found' });

    const availability = await LawyerAvailability.findAll({
      where: { lawyerId: profile.id },
      order: [['date', 'ASC']],
    });
    return res.json({ availability });
  } catch (err) {
    console.error('[lawyer.getAvailability]', err);
    return res.status(500).json({ message: 'Failed to fetch availability' });
  }
};
