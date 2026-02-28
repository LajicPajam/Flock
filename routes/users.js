const express = require('express');

const {
  getCurrentUserHandler,
  updateDriverProfileHandler,
  updateCurrentUserHandler,
  getMyTripsHandler,
  getMyRequestsHandler,
  getNotificationsHandler,
  markAllNotificationsReadHandler,
  markNotificationReadHandler,
} = require('../controllers/userController');
const { getCarbonStatsHandler } = require('../controllers/carbonController');
const { getUserReviewsHandler } = require('../controllers/reviewController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/me', authRequired, getCurrentUserHandler);
router.get('/me/trips', authRequired, getMyTripsHandler);
router.get('/me/requests', authRequired, getMyRequestsHandler);
router.get('/me/notifications', authRequired, getNotificationsHandler);
router.post('/me/notifications/read-all', authRequired, markAllNotificationsReadHandler);
router.post('/me/notifications/:id/read', authRequired, markNotificationReadHandler);
router.put('/me', authRequired, updateCurrentUserHandler);
router.post('/me/driver-profile', authRequired, updateDriverProfileHandler);
router.get('/me/carbon-stats', authRequired, getCarbonStatsHandler);
router.get('/:id/reviews', getUserReviewsHandler);

module.exports = router;
