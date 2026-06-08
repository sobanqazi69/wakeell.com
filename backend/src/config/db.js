const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASS,
  {
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 3306,
    dialect: 'mysql',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: { max: 10, min: 0, acquire: 30000, idle: 10000 },
    define: { underscored: true, timestamps: true },
    dialectOptions: {
      // mysql2 returns JSON columns as raw strings — parse them at driver level
      typeCast(field, next) {
        if (field.type === 'JSON') {
          const raw = field.string();
          if (raw === null || raw === undefined) return null;
          try { return JSON.parse(raw); } catch { return raw; }
        }
        return next();
      },
    },
  }
);

module.exports = sequelize;
