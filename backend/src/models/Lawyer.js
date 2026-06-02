const mongoose = require('mongoose');

const availabilitySlotSchema = new mongoose.Schema({
  date: { type: String, required: true }, // YYYY-MM-DD
  slots: [{ type: String }], // ['09:00', '10:00', ...]
}, { _id: false });

const lawyerSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  barLicense: { type: String, required: true },
  idDocument: { type: String, default: null }, // file path/url
  specializations: [{ type: String }],
  bio: { type: String, default: '' },
  languages: [{ type: String }],
  hourlyRate: { type: Number, default: 0 },
  currency: { type: String, default: 'USD' },
  experience: { type: Number, default: 0 }, // years
  education: [{ degree: String, institution: String, year: Number }],
  availability: [availabilitySlotSchema],
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  adminNote: { type: String, default: null },
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
}, { timestamps: true });

module.exports = mongoose.model('Lawyer', lawyerSchema);
