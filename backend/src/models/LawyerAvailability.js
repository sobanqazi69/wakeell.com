const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const LawyerAvailability = sequelize.define('LawyerAvailability', {
  id:       { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  lawyerId: { type: DataTypes.INTEGER, allowNull: false },
  date:     { type: DataTypes.STRING(10), allowNull: false },  // YYYY-MM-DD
  slots: {
    type: DataTypes.TEXT,
    defaultValue: '[]',
    get() {
      const raw = this.getDataValue('slots');
      if (Array.isArray(raw)) return raw;
      if (typeof raw === 'string' && raw.length > 0) {
        try { return JSON.parse(raw); } catch { return []; }
      }
      return [];
    },
    set(val) {
      this.setDataValue('slots', JSON.stringify(Array.isArray(val) ? val : []));
    },
  },
}, {
  tableName: 'lawyer_availability',
  underscored: true,
  indexes: [{ fields: ['lawyer_id', 'date'], unique: true }],
});

module.exports = LawyerAvailability;
