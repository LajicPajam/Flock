const express = require('express');

const {
  createTripHandler,
  listTripsHandler,
  getTripByIdHandler,
} = require('../controllers/tripController');
const { createRideRequestHandler } = require('../controllers/requestController');
const {
  getMessagesHandler,
  createMessageHandler,
} = require('../controllers/messageController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/', listTripsHandler);
router.post('/', authRequired, createTripHandler);
router.get('/:id', getTripByIdHandler);
router.post('/:id/request', authRequired, createRideRequestHandler);
router.get('/:id/messages', authRequired, getMessagesHandler);
router.post('/:id/messages', authRequired, createMessageHandler);

module.exports = router;
