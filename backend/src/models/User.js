const { DataTypes } = require('sequelize');
const bcrypt = require('bcryptjs');
const sequelize = require('../config/db');

const User = sequelize.define('User', {
  id:           { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  name:         { type: DataTypes.STRING(255), allowNull: false },
  email:        { type: DataTypes.STRING(255), allowNull: false, unique: true, validate: { isEmail: true } },
  password:     { type: DataTypes.STRING(255), allowNull: false },
  role:         { type: DataTypes.ENUM('client', 'lawyer', 'admin'), defaultValue: 'client' },
  avatar:       { type: DataTypes.STRING(500), allowNull: true, defaultValue: null },
  phone:        { type: DataTypes.STRING(50),  allowNull: true, defaultValue: null },
  location:     { type: DataTypes.STRING(255), allowNull: true, defaultValue: null },
  jurisdiction: { type: DataTypes.STRING(255), allowNull: true, defaultValue: null },
  googleId:     { type: DataTypes.STRING(255), allowNull: true, defaultValue: null, unique: true },
  isVerified:   { type: DataTypes.BOOLEAN, defaultValue: false },
  isActive:     { type: DataTypes.BOOLEAN, defaultValue: true },
  fcmToken:     { type: DataTypes.STRING(500), allowNull: true, defaultValue: null },
}, {
  tableName: 'users',
  underscored: true,
  hooks: {
    beforeSave: async (user) => {
      if (user.changed('password')) {
        user.password = await bcrypt.hash(user.password, 12);
      }
    },
  },
});

// Strip password from every JSON output
User.prototype.toJSON = function () {
  const obj = { ...this.get() };
  delete obj.password;
  return obj;
};

User.prototype.comparePassword = async function (candidate) {
  return bcrypt.compare(candidate, this.password);
};

module.exports = User;
