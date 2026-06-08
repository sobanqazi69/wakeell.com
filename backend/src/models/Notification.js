const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Notification = sequelize.define('Notification', {
  id:     { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  userId: { type: DataTypes.INTEGER, allowNull: false },
  title:  { type: DataTypes.STRING(255), allowNull: false },
  body:   { type: DataTypes.TEXT, allowNull: false },
  type: {
    type: DataTypes.ENUM('booking_new', 'booking_accepted', 'booking_declined', 'reminder'),
    defaultValue: 'booking_new',
  },
  data:   { type: DataTypes.JSON, defaultValue: {} },
  isRead: { type: DataTypes.BOOLEAN, defaultValue: false },
}, {
  tableName: 'notifications',
  underscored: true,
});

module.exports = Notification;
