const CITIES_API_URL = 'https://countriesnow.space/api/v0.1/countries/cities';
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

const cache = new Map(); // key: country → { cities, expiresAt }

async function getCities(req, res) {
  const country = (req.query.country || 'Pakistan').trim();

  try {
    const cached = cache.get(country);
    if (cached && Date.now() < cached.expiresAt) {
      return res.json({ success: true, data: cached.cities, source: 'cache' });
    }

    const response = await fetch(CITIES_API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ country }),
      signal: AbortSignal.timeout(10_000),
    });

    if (!response.ok) {
      throw new Error(`CountriesNow responded with ${response.status}`);
    }

    const json = await response.json();

    if (json.error || !Array.isArray(json.data)) {
      throw new Error(json.msg || 'Unexpected response from CountriesNow');
    }

    const cities = [...json.data].sort((a, b) => a.localeCompare(b));

    cache.set(country, { cities, expiresAt: Date.now() + CACHE_TTL_MS });

    return res.json({ success: true, data: cities, source: 'api' });
  } catch (err) {
    console.error('[CitiesController] Failed to fetch cities:', err.message);
    return res.status(502).json({
      success: false,
      message: 'Could not retrieve city list. Please try again.',
    });
  }
}

module.exports = { getCities };
