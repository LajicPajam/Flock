const express = require('express');

const {
  getCurrentUserHandler,
  updateDriverProfileHandler,
  updateCurrentUserHandler,
} = require('../controllers/userController');
const { getCarbonStatsHandler } = require('../controllers/carbonController');
const { getUserReviewsHandler } = require('../controllers/reviewController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/me', authRequired, getCurrentUserHandler);
router.put('/me', authRequired, updateCurrentUserHandler);
router.post('/me/driver-profile', authRequired, updateDriverProfileHandler);
router.get('/me/carbon-stats', authRequired, getCarbonStatsHandler);
router.get('/:id/reviews', getUserReviewsHandler);

module.exports = router;
