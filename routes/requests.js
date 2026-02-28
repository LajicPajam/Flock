const express = require('express');

const {
  acceptRideRequestHandler,
  rejectRideRequestHandler,
} = require('../controllers/requestController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.post('/:id/accept', authRequired, acceptRideRequestHandler);
router.post('/:id/reject', authRequired, rejectRideRequestHandler);

module.exports = router;
