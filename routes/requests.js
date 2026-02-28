const express = require('express');

const {
  acceptRideRequestHandler,
  rejectRideRequestHandler,
  withdrawRideRequestHandler,
} = require('../controllers/requestController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.post('/:id/accept', authRequired, acceptRideRequestHandler);
router.post('/:id/reject', authRequired, rejectRideRequestHandler);
router.post('/:id/withdraw', authRequired, withdrawRideRequestHandler);

module.exports = router;
