const { Booking, Lawyer, User, LawyerAvailability } = require('../models');

exports.createBooking = async (req, res) => {
  try {
    const { lawyerId, date, timeSlot, sessionType, category, caseBrief, duration } = req.body;

    if (!lawyerId || !date || !timeSlot || !category) {
      return res.status(400).json({ message: 'lawyerId, date, timeSlot and category are required' });
    }

    const lawyerProfile = await Lawyer.findByPk(lawyerId);
    if (!lawyerProfile) return res.status(404).json({ message: 'Lawyer not found' });
    if (lawyerProfile.status !== 'approved') {
      return res.status(400).json({ message: 'Lawyer is not available for bookings' });
    }

    // Verify slot availability — slots may be a JS array or a raw JSON string (mysql2 JSON column)
    const avail = await LawyerAvailability.findOne({ where: { lawyerId, date } });
    console.log('[booking.createBooking] avail found=%s lawyerId=%s date=%s', !!avail, lawyerId, date);
    if (!avail) return res.status(400).json({ message: 'No availability set for this date' });

    let slotsArr = avail.slots;
    console.log('[booking.createBooking] slots raw type=%s value=%j', typeof slotsArr, slotsArr);
    if (!Array.isArray(slotsArr)) {
      try {
        const parsed = JSON.parse(slotsArr);
        slotsArr = Array.isArray(parsed) ? parsed : [];
      } catch { slotsArr = []; }
    }
    console.log('[booking.createBooking] slotsArr=%j timeSlot=%s includes=%s', slotsArr, timeSlot, slotsArr.includes(timeSlot));
    if (!slotsArr.includes(timeSlot)) {
      return res.status(400).json({ message: `Slot ${timeSlot} is not available. Available: ${slotsArr.join(', ')}` });
    }

    const booking = await Booking.create({
      clientId: req.user.id,
      lawyerId: lawyerProfile.userId,
      lawyerProfileId: lawyerProfile.id,
      date,
      timeSlot,
      duration: duration || 60,
      sessionType: sessionType || 'video',
      category,
      caseBrief: caseBrief || '',
    });

    return res.status(201).json({ booking });
  } catch (err) {
    console.error('[booking.createBooking]', err);
    return res.status(500).json({ message: 'Failed to create booking' });
  }
};

exports.getMyBookings = async (req, res) => {
  try {
    const where = req.user.role === 'client'
      ? { clientId: req.user.id }
      : { lawyerId: req.user.id };

    const bookings = await Booking.findAll({
      where,
      include: [
        { model: User, as: 'client', attributes: ['id', 'name', 'avatar'] },
        { model: User, as: 'lawyerUser', attributes: ['id', 'name', 'avatar'] },
        { model: Lawyer, as: 'lawyerProfile', attributes: ['id', 'specializations', 'rating'] },
      ],
      order: [['createdAt', 'DESC']],
    });

    return res.json({ bookings });
  } catch (err) {
    console.error('[booking.getMyBookings]', err);
    return res.status(500).json({ message: 'Failed to fetch bookings' });
  }
};

exports.getBookingById = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id, {
      include: [
        { model: User, as: 'client', attributes: ['id', 'name', 'avatar', 'phone'] },
        { model: User, as: 'lawyerUser', attributes: ['id', 'name', 'avatar'] },
        { model: Lawyer, as: 'lawyerProfile' },
      ],
    });

    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const isOwner = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isOwner && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }

    return res.json({ booking });
  } catch (err) {
    console.error('[booking.getBookingById]', err);
    return res.status(500).json({ message: 'Failed to fetch booking' });
  }
};

exports.respondToBooking = async (req, res) => {
  try {
    const { status } = req.body;

    if (!['accepted', 'declined'].includes(status)) {
      return res.status(400).json({ message: 'status must be accepted or declined' });
    }

    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    if (booking.lawyerId !== req.user.id) {
      return res.status(403).json({ message: 'Access denied' });
    }
    if (booking.status !== 'pending') {
      return res.status(400).json({ message: 'Booking already responded to' });
    }

    await booking.update({ status });
    return res.json({ booking });
  } catch (err) {
    console.error('[booking.respondToBooking]', err);
    return res.status(500).json({ message: 'Failed to update booking' });
  }
};

exports.cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const isOwner = booking.clientId === req.user.id || booking.lawyerId === req.user.id;
    if (!isOwner) return res.status(403).json({ message: 'Access denied' });

    if (['completed', 'cancelled'].includes(booking.status)) {
      return res.status(400).json({ message: `Booking is already ${booking.status}` });
    }

    await booking.update({ status: 'cancelled' });
    return res.json({ booking });
  } catch (err) {
    console.error('[booking.cancelBooking]', err);
    return res.status(500).json({ message: 'Failed to cancel booking' });
  }
};
