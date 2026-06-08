/**
 * Creates the first admin user.
 * Usage: node scripts/create-admin.js
 */
require('dotenv').config();
const sequelize = require('../src/config/db');
require('../src/models'); // register all models
const { User } = require('../src/models');

const ADMIN = {
  name:     'Wakeell Admin',
  email:    'admin@wakeell.com',
  password: 'Admin@2025!',
  role:     'admin',
};

(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync();

    const existing = await User.findOne({ where: { email: ADMIN.email } });
    if (existing) {
      console.log(`Admin already exists: ${ADMIN.email}`);
      process.exit(0);
    }

    const admin = await User.create(ADMIN);
    console.log(`✓ Admin created — id: ${admin.id}, email: ${ADMIN.email}`);
    console.log(`  Password: ${ADMIN.password}`);
  } catch (err) {
    console.error('Failed to create admin:', err.message);
    process.exit(1);
  } finally {
    await sequelize.close();
  }
})();
