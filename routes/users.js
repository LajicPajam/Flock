const express = require('express');

const {
  getCurrentUserHandler,
  updateDriverProfileHandler,
  updateCurrentUserHandler,
} = require('../controllers/userController');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/me', authRequired, getCurrentUserHandler);
router.put('/me', authRequired, updateCurrentUserHandler);
router.post('/me/driver-profile', authRequired, updateDriverProfileHandler);

module.exports = router;
