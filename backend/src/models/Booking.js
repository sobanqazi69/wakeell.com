const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  client: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  lawyer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  lawyerProfile: { type: mongoose.Schema.Types.ObjectId, ref: 'Lawyer', required: true },
  date: { type: String, required: true }, // YYYY-MM-DD
  timeSlot: { type: String, required: true }, // HH:MM
  duration: { type: Number, default: 60 }, // minutes
  sessionType: { type: String, enum: ['video', 'audio', 'text'], default: 'video' },
  category: { type: String, required: true }, // Family, Business, Criminal, Civil
  caseBrief: { type: String, default: '' },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'declined', 'completed', 'cancelled'],
    default: 'pending',
  },
  sessionRoom: { type: String, default: null }, // socket room id
  reminderSent30: { type: Boolean, default: false },
  reminderSent5: { type: Boolean, default: false },
  startedAt: { type: Date, default: null },
  endedAt: { type: Date, default: null },
}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);
