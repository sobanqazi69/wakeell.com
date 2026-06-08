const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const LawyerAvailability = sequelize.define('LawyerAvailability', {
  id:       { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  lawyerId: { type: DataTypes.INTEGER, allowNull: false },
  date:     { type: DataTypes.STRING(10), allowNull: false },  // YYYY-MM-DD
  slots:    { type: DataTypes.JSON, defaultValue: [] },        // ['09:00', '10:00']
}, {
  tableName: 'lawyer_availability',
  underscored: true,
  indexes: [{ fields: ['lawyer_id', 'date'], unique: true }],
});

module.exports = LawyerAvailability;
