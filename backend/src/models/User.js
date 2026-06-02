const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true, select: false },
  role: { type: String, enum: ['client', 'lawyer', 'admin'], default: 'client' },
  avatar: { type: String, default: null },
  phone: { type: String, default: null },
  location: { type: String, default: null },
  jurisdiction: { type: String, default: null },
  isVerified: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true },
  fcmToken: { type: String, default: null },
}, { timestamps: true });

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
