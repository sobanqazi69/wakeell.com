const { User, Lawyer } = require('../models');

exports.getPendingLawyers = async (req, res) => {
  try {
    const lawyers = await Lawyer.findAll({
      where: { status: 'pending' },
      include: [{ model: User, as: 'user', attributes: ['id', 'name', 'email', 'phone'] }],
      order: [['createdAt', 'ASC']],
    });
    return res.json({ lawyers });
  } catch (err) {
    console.error('[admin.getPendingLawyers]', err);
    return res.status(500).json({ message: 'Failed to fetch pending lawyers' });
  }
};

exports.verifyLawyer = async (req, res) => {
  try {
    const { status, adminNote } = req.body;

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ message: 'status must be approved or rejected' });
    }

    const lawyer = await Lawyer.findByPk(req.params.id, {
      include: [{ model: User, as: 'user', attributes: ['id', 'name', 'email'] }],
    });
    if (!lawyer) return res.status(404).json({ message: 'Lawyer not found' });

    await lawyer.update({ status, adminNote: adminNote || null });

    if (status === 'approved') {
      await User.update({ isVerified: true }, { where: { id: lawyer.userId } });
    }

    return res.json({ lawyer });
  } catch (err) {
    console.error('[admin.verifyLawyer]', err);
    return res.status(500).json({ message: 'Failed to verify lawyer' });
  }
};

exports.getUsers = async (req, res) => {
  try {
    const users = await User.findAll({ order: [['createdAt', 'DESC']] });
    return res.json({ users });
  } catch (err) {
    console.error('[admin.getUsers]', err);
    return res.status(500).json({ message: 'Failed to fetch users' });
  }
};

exports.toggleUserActive = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    await user.update({ isActive: !user.isActive });
    return res.json({ user });
  } catch (err) {
    console.error('[admin.toggleUserActive]', err);
    return res.status(500).json({ message: 'Failed to toggle user status' });
  }
};
