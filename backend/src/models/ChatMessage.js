const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const ChatMessage = sequelize.define('ChatMessage', {
  id:         { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  bookingId:  { type: DataTypes.INTEGER, allowNull: false },
  senderId:   { type: DataTypes.INTEGER, allowNull: false },
  senderRole: { type: DataTypes.ENUM('client', 'lawyer'), allowNull: false },
  message:    { type: DataTypes.TEXT, allowNull: false },
}, {
  tableName: 'chat_messages',
  underscored: true,
});

module.exports = ChatMessage;
