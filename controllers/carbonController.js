const { getCarbonSavedForUser, getOverallCarbonStats } = require('../models/carbon');

async function getCarbonStatsHandler(req, res) {
  try {
    const stats = await getCarbonSavedForUser(req.user.id);
    return res.json(stats);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load carbon stats.' });
  }
}

async function getOverallCarbonStatsHandler(_req, res) {
  try {
    const stats = await getOverallCarbonStats();
    return res.json(stats);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load overall carbon stats.' });
  }
}

module.exports = { getCarbonStatsHandler, getOverallCarbonStatsHandler };
