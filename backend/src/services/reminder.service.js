const schedule = require('node-schedule');
const { Op } = require('sequelize');
const { Booking } = require('../models');
const notif = require('./notification.service');

const _jobs = {}; // bookingId → [job, ...]

const REMINDERS = [
  { offsetMin: -60, flag: 'reminderSent60',  label: '1 hour' },
  { offsetMin: -30, flag: 'reminderSent30',  label: '30 minutes' },
  { offsetMin: -5,  flag: 'reminderSent5',   label: '5 minutes' },
  { offsetMin:  0,  flag: 'reminderSentNow', label: 'now' },
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

        const isNow  = offsetMin === 0;
        const title  = isNow ? 'Your session is starting now!' : `Session in ${label}`;
        const body   = isNow
          ? 'Your consultation is starting. Tap to join.'
          : `Your consultation starts in ${label}. Get ready!`;
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
    bookings.forEach(scheduleReminders);
    console.log(`[reminder.service] rescheduled ${bookings.length} bookings on boot`);
  } catch (e) {
    console.error('[reminder.service] rescheduleAllOnBoot:', e.message);
  }
}

module.exports = { scheduleReminders, cancelReminders, rescheduleAllOnBoot };
