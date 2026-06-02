const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({
  booking: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', required: true, unique: true },
  roomId: { type: String, required: true, unique: true },
  clientJoined: { type: Boolean, default: false },
  lawyerJoined: { type: Boolean, default: false },
  startedAt: { type: Date, default: null },
  endedAt: { type: Date, default: null },
  adviceSummary: { type: String, default: '' },
  summaryWritten: { type: Boolean, default: false },
  status: { type: String, enum: ['waiting', 'active', 'ended'], default: 'waiting' },
}, { timestamps: true });

module.exports = mongoose.model('Session', sessionSchema);
