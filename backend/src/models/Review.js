const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Review = sequelize.define('Review', {
  id:        { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  bookingId: { type: DataTypes.INTEGER, allowNull: false, unique: true },
  clientId:  { type: DataTypes.INTEGER, allowNull: false },
  lawyerId:  { type: DataTypes.INTEGER, allowNull: false },
  rating:    { type: DataTypes.INTEGER, allowNull: false, validate: { min: 1, max: 5 } },
  comment:   { type: DataTypes.TEXT, defaultValue: '' },
}, {
  tableName: 'reviews',
  underscored: true,
});

module.exports = Review;
