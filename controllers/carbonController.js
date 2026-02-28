const { getCarbonSavedForUser } = require('../models/carbon');

async function getCarbonStatsHandler(req, res) {
  try {
    const stats = await getCarbonSavedForUser(req.user.id);
    return res.json(stats);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load carbon stats.' });
  }
}

module.exports = { getCarbonStatsHandler };
