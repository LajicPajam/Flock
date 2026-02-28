const { findTripById } = require('../models/trips');
const {
  createRideRequest,
  findRideRequestById,
  updateRideRequestStatus,
} = require('../models/rideRequests');

async function createRideRequestHandler(req, res) {
  const { message } = req.body;

  if (!message || typeof message !== 'string' || message.trim().length < 2) {
    return res.status(400).json({ error: 'A short request note is required.' });
  }

  try {
    const trip = await findTripById(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'Trip not found.' });
    }

    if (trip.driver_id === req.user.id) {
      return res.status(400).json({ error: 'Drivers cannot request their own trips.' });
    }

    const request = await createRideRequest({
      tripId: trip.id,
      riderId: req.user.id,
      message: message.trim(),
    });

    return res.status(201).json(request);
  } catch (error) {
    if (error.code === '23505') {
      return res.status(409).json({ error: 'You have already requested a seat on this trip.' });
    }

    return res.status(500).json({ error: 'Unable to create ride request.' });
  }
}

async function acceptRideRequestHandler(req, res) {
  try {
    const request = await findRideRequestById(req.params.id);
    if (!request) {
      return res.status(404).json({ error: 'Ride request not found.' });
    }

    const trip = await findTripById(request.trip_id);
    if (!trip || trip.driver_id !== req.user.id) {
      return res.status(403).json({ error: 'Only the driver can accept this request.' });
    }

    const updatedRequest = await updateRideRequestStatus(request.id, 'accepted');
    return res.json(updatedRequest);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to accept ride request.' });
  }
}

async function rejectRideRequestHandler(req, res) {
  try {
    const request = await findRideRequestById(req.params.id);
    if (!request) {
      return res.status(404).json({ error: 'Ride request not found.' });
    }

    const trip = await findTripById(request.trip_id);
    if (!trip || trip.driver_id !== req.user.id) {
      return res.status(403).json({ error: 'Only the driver can reject this request.' });
    }

    const updatedRequest = await updateRideRequestStatus(request.id, 'rejected');
    return res.json(updatedRequest);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to reject ride request.' });
  }
}

module.exports = {
  createRideRequestHandler,
  acceptRideRequestHandler,
  rejectRideRequestHandler,
};
