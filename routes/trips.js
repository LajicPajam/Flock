const express = require('express');

const {
  createTripHandler,
  updateTripHandler,
  listTripsHandler,
  getTripByIdHandler,
} = require('../controllers/tripController');
const { createRideRequestHandler } = require('../controllers/requestController');
const {
  getMessagesHandler,
  createMessageHandler,
} = require('../controllers/messageController');
const { createTripReviewHandler } = require('../controllers/reviewController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/', listTripsHandler);
router.post('/', authRequired, createTripHandler);
router.put('/:id', authRequired, updateTripHandler);
router.get('/:id', getTripByIdHandler);
router.post('/:id/request', authRequired, createRideRequestHandler);
router.get('/:id/messages', authRequired, getMessagesHandler);
router.post('/:id/messages', authRequired, createMessageHandler);
router.post('/:id/reviews', authRequired, createTripReviewHandler);

module.exports = router;
