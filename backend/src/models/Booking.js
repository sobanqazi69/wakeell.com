const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Booking = sequelize.define('Booking', {
  id:             { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  clientId:       { type: DataTypes.INTEGER, allowNull: false },
  lawyerId:       { type: DataTypes.INTEGER, allowNull: false },
  lawyerProfileId:{ type: DataTypes.INTEGER, allowNull: false },
  date:           { type: DataTypes.STRING(10), allowNull: false },   // YYYY-MM-DD
  timeSlot:       { type: DataTypes.STRING(10), allowNull: false },   // HH:MM
  duration:       { type: DataTypes.INTEGER, defaultValue: 60 },      // minutes
  sessionType:    { type: DataTypes.ENUM('video', 'audio', 'text'), defaultValue: 'video' },
  category:       { type: DataTypes.STRING(100), allowNull: false },
  caseBrief:      { type: DataTypes.TEXT, defaultValue: '' },
  status:         {
    type: DataTypes.ENUM('pending', 'accepted', 'declined', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },
  sessionRoom:    { type: DataTypes.STRING(255), allowNull: true, defaultValue: null },
  reminderSent30:  { type: DataTypes.BOOLEAN, defaultValue: false },
  reminderSent15:  { type: DataTypes.BOOLEAN, defaultValue: false },
  reminderSent5:   { type: DataTypes.BOOLEAN, defaultValue: false },
  startedAt:          { type: DataTypes.DATE, allowNull: true, defaultValue: null },
  endedAt:            { type: DataTypes.DATE, allowNull: true, defaultValue: null },
  cancellationReason: { type: DataTypes.STRING(255), allowNull: true, defaultValue: null },
}, {
  tableName: 'bookings',
  underscored: true,
});

module.exports = Booking;
