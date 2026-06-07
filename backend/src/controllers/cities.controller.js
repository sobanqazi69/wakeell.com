const path = require('path');
const fs = require('fs');

const CITIES_API_URL = 'https://countriesnow.space/api/v0.1/countries/cities';
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

// Load the bundled comprehensive list once at startup
const STATIC_CITIES = JSON.parse(
  fs.readFileSync(path.join(__dirname, '../data/pakistan-cities.json'), 'utf8')
);

const cache = new Map(); // key: country → { cities, expiresAt }

async function getCities(req, res) {
  const country = (req.query.country || 'Pakistan').trim();

  try {
    const cached = cache.get(country);
    if (cached && Date.now() < cached.expiresAt) {
      return res.json({ success: true, data: cached.cities, source: 'cache' });
    }

    // Fetch from CountriesNow to supplement the static list
    let apiCities = [];
    try {
      const response = await fetch(CITIES_API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ country }),
        signal: AbortSignal.timeout(8_000),
      });

      if (response.ok) {
        const json = await response.json();
        if (!json.error && Array.isArray(json.data)) {
          apiCities = json.data;
        }
      }
    } catch (fetchErr) {
      console.warn('[CitiesController] CountriesNow fetch failed, using static list only:', fetchErr.message);
    }

    // Merge static + API, deduplicate, sort
    const merged = [...new Set([...STATIC_CITIES, ...apiCities])]
      .map((c) => c.trim())
      .filter(Boolean)
      .sort((a, b) => a.localeCompare(b));

    cache.set(country, { cities: merged, expiresAt: Date.now() + CACHE_TTL_MS });

    return res.json({ success: true, data: merged, source: 'merged' });
  } catch (err) {
    console.error('[CitiesController] Unexpected error:', err.message);

    // Always fall back to the static list
    const sorted = [...STATIC_CITIES].sort((a, b) => a.localeCompare(b));
    return res.json({ success: true, data: sorted, source: 'static' });
  }
}

module.exports = { getCities };
