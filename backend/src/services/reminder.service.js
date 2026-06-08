const schedule = require('node-schedule');
const { Op } = require('sequelize');
const { Booking, Session } = require('../models');
const notif = require('./notification.service');

const _jobs = {}; // bookingId → [job, ...]

const REMINDERS = [
  { offsetMin: -30, flag: 'reminderSent30', label: '30 minutes' },
  { offsetMin: -15, flag: 'reminderSent15', label: '15 minutes' },
  { offsetMin: -5,  flag: 'reminderSent5',  label: '5 minutes' },
];

function _sessionStart(date, timeSlot) {
  const [y, mo, d] = date.split('-').map(Number);
  const [h, mi]    = timeSlot.split(':').map(Number);
  return new Date(y, mo - 1, d, h, mi, 0);
}

function scheduleReminders(booking) {
  const { id, clientId, lawyerId, date, timeSlot, duration } = booking;
  cancelReminders(id);
  _jobs[id] = [];

  const start = _sessionStart(date, timeSlot);
  const now   = Date.now();

  for (const { offsetMin, flag, label } of REMINDERS) {
    const fireAt = new Date(start.getTime() + offsetMin * 60_000);
    if (fireAt.getTime() <= now) continue;

    const job = schedule.scheduleJob(`booking_${id}_${flag}`, fireAt, async () => {
      try {
        const b = await Booking.findByPk(id);
        if (!b || b.status !== 'accepted' || b[flag]) return;

        const title = `Session in ${label}`;
        const body  = `Your consultation starts in ${label}. Get ready to join!`;
        const data   = { bookingId: String(id), screen: 'bookings' };

        await Promise.all([
          notif.send(clientId, title, body, 'reminder', data),
          notif.send(lawyerId, title, body, 'reminder', data),
        ]);
        await b.update({ [flag]: true });
      } catch (e) {
        console.error(`[reminder.service] job booking_${id}_${flag} error:`, e.message);
      }
    });

    if (job) _jobs[id].push(job);
  }

  // Auto-cancel job: fires 30 min after start if no one joined
  const cancelAt = new Date(start.getTime() + 30 * 60_000);
  if (cancelAt.getTime() > Date.now()) {
    const cancelJob = schedule.scheduleJob(`booking_${id}_autocancel`, cancelAt, async () => {
      try {
        const b = await Booking.findByPk(id);
        if (!b || b.status !== 'accepted') return;

        const session = await Session.findOne({ where: { bookingId: id } });
        const anyoneJoined = session && (session.clientJoined || session.lawyerJoined);
        if (anyoneJoined) return;

        await b.update({ status: 'cancelled' });

        await Promise.all([
          notif.send(b.clientId, 'Booking Cancelled', 'Your session was cancelled — no one joined within 30 minutes.', 'booking_declined', { bookingId: String(id) }),
          notif.send(b.lawyerId, 'Booking Cancelled', 'The session was cancelled — no one joined within 30 minutes.', 'booking_declined', { bookingId: String(id) }),
        ]);
      } catch (e) {
        console.error(`[reminder.service] autocancel booking_${id} error:`, e.message);
      }
    });
    if (cancelJob) _jobs[id].push(cancelJob);
  }
}

function cancelReminders(bookingId) {
  (_jobs[bookingId] || []).forEach(j => j.cancel());
  delete _jobs[bookingId];
}

async function rescheduleAllOnBoot() {
  try {
    const today = new Date().toISOString().slice(0, 10);
    const bookings = await Booking.findAll({
      where: { status: 'accepted', date: { [Op.gte]: today } },
    });

    const now = Date.now();
    let cancelled = 0;

    for (const b of bookings) {
      const start    = _sessionStart(b.date, b.timeSlot);
      const cancelAt = new Date(start.getTime() + 30 * 60_000);

      if (cancelAt.getTime() <= now) {
        // Window already passed — complete if joined, cancel if not
        const session = await Session.findOne({ where: { bookingId: b.id } });
        const anyoneJoined = session && (session.clientJoined || session.lawyerJoined);
        if (anyoneJoined) {
          await b.update({ status: 'completed' });
          if (session.status !== 'ended') {
            await session.update({ status: 'ended', endedAt: session.endedAt || new Date() });
          }
          cancelled++; // reuse counter for logging
        } else {
          await b.update({ status: 'cancelled' });
          await Promise.all([
            notif.send(b.clientId, 'Booking Cancelled', 'Your session was cancelled — no one joined within 30 minutes.', 'booking_declined', { bookingId: String(b.id) }),
            notif.send(b.lawyerId, 'Booking Cancelled', 'The session was cancelled — no one joined within 30 minutes.', 'booking_declined', { bookingId: String(b.id) }),
          ]).catch(() => {});
          cancelled++;
        }
      } else {
        scheduleReminders(b);
      }
    }

    console.log(`[reminder.service] rescheduled ${bookings.length - cancelled} bookings, resolved ${cancelled} expired on boot`);
  } catch (e) {
    console.error('[reminder.service] rescheduleAllOnBoot:', e.message);
  }
}

module.exports = { scheduleReminders, cancelReminders, rescheduleAllOnBoot };
