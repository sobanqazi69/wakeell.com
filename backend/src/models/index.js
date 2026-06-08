const User             = require('./User');
const Lawyer           = require('./Lawyer');
const LawyerAvailability = require('./LawyerAvailability');
const Booking          = require('./Booking');
const Session          = require('./Session');
const Review           = require('./Review');
const Notification     = require('./Notification');

// ── User ↔ Lawyer ─────────────────────────────────────────────────────────────
User.hasOne(Lawyer, { foreignKey: 'userId', as: 'lawyerProfile', onDelete: 'CASCADE' });
Lawyer.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// ── Lawyer ↔ Availability ─────────────────────────────────────────────────────
Lawyer.hasMany(LawyerAvailability, { foreignKey: 'lawyerId', as: 'availability', onDelete: 'CASCADE' });
LawyerAvailability.belongsTo(Lawyer, { foreignKey: 'lawyerId' });

// ── Booking ↔ Client (User) ───────────────────────────────────────────────────
User.hasMany(Booking, { foreignKey: 'clientId', as: 'clientBookings' });
Booking.belongsTo(User, { foreignKey: 'clientId', as: 'client' });

// ── Booking ↔ Lawyer (User) ───────────────────────────────────────────────────
User.hasMany(Booking, { foreignKey: 'lawyerId', as: 'lawyerBookings' });
Booking.belongsTo(User, { foreignKey: 'lawyerId', as: 'lawyerUser' });

// ── Booking ↔ LawyerProfile ───────────────────────────────────────────────────
Lawyer.hasMany(Booking, { foreignKey: 'lawyerProfileId', as: 'bookings' });
Booking.belongsTo(Lawyer, { foreignKey: 'lawyerProfileId', as: 'lawyerProfile' });

// ── Booking ↔ Session ─────────────────────────────────────────────────────────
Booking.hasOne(Session, { foreignKey: 'bookingId', as: 'session', onDelete: 'CASCADE' });
Session.belongsTo(Booking, { foreignKey: 'bookingId', as: 'booking' });

// ── Booking ↔ Review ──────────────────────────────────────────────────────────
Booking.hasOne(Review, { foreignKey: 'bookingId', as: 'review', onDelete: 'CASCADE' });
Review.belongsTo(Booking, { foreignKey: 'bookingId', as: 'booking' });

// ── Review ↔ Client / Lawyer (User) ──────────────────────────────────────────
User.hasMany(Review, { foreignKey: 'clientId', as: 'clientReviews' });
Review.belongsTo(User, { foreignKey: 'clientId', as: 'client' });

User.hasMany(Review, { foreignKey: 'lawyerId', as: 'lawyerReviews' });
Review.belongsTo(User, { foreignKey: 'lawyerId', as: 'lawyerUser' });

// ── Notification ↔ User ───────────────────────────────────────────────────────
User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications', onDelete: 'CASCADE' });
Notification.belongsTo(User, { foreignKey: 'userId', as: 'user' });

module.exports = { User, Lawyer, LawyerAvailability, Booking, Session, Review, Notification };
