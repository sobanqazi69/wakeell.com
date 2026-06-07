const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Lawyer = sequelize.define('Lawyer', {
  id:          { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  userId:      { type: DataTypes.INTEGER, allowNull: false, unique: true },
  barLicense:  { type: DataTypes.STRING(255), allowNull: false },
  idDocument:  { type: DataTypes.STRING(500), allowNull: true, defaultValue: null },
  specializations: { type: DataTypes.JSON, defaultValue: [] },
  bio:         { type: DataTypes.TEXT, defaultValue: '' },
  languages:   { type: DataTypes.JSON, defaultValue: [] },
  hourlyRate:  { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  currency:    { type: DataTypes.STRING(10), defaultValue: 'USD' },
  experience:  { type: DataTypes.INTEGER, defaultValue: 0 },
  education:   { type: DataTypes.JSON, defaultValue: [] },
  status:      { type: DataTypes.ENUM('pending', 'approved', 'rejected'), defaultValue: 'pending' },
  adminNote:   { type: DataTypes.TEXT, allowNull: true, defaultValue: null },
  rating:      { type: DataTypes.DECIMAL(3, 1), defaultValue: 0 },
  reviewCount: { type: DataTypes.INTEGER, defaultValue: 0 },
}, {
  tableName: 'lawyers',
  underscored: true,
});

module.exports = Lawyer;
