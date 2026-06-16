const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Session = sequelize.define('Session', {
  id:             { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  bookingId:      { type: DataTypes.INTEGER, allowNull: false, unique: true },
  roomId:         { type: DataTypes.STRING(255), allowNull: false, unique: true },
  clientJoined:   { type: DataTypes.BOOLEAN, defaultValue: false },
  lawyerJoined:   { type: DataTypes.BOOLEAN, defaultValue: false },
  startedAt:      { type: DataTypes.DATE, allowNull: true, defaultValue: null },
  endedAt:        { type: DataTypes.DATE, allowNull: true, defaultValue: null },
  adviceSummary:  { type: DataTypes.TEXT, defaultValue: '' },
  summaryWritten: { type: DataTypes.BOOLEAN, defaultValue: false },
  status:         { type: DataTypes.ENUM('waiting', 'active', 'ended'), defaultValue: 'waiting' },
  egressId:       { type: DataTypes.STRING(255), allowNull: true, defaultValue: null },
  recordingKey:   { type: DataTypes.STRING(500), allowNull: true, defaultValue: null },
}, {
  tableName: 'sessions',
  underscored: true,
});

module.exports = Session;
