const express = require('express');
const { getCities } = require('../controllers/cities.controller');

const router = express.Router();

// GET /api/cities?country=Pakistan
router.get('/', getCities);

module.exports = router;
