const db = require('../db');
const {
  findTripById,
  findTripRowById,
  updateTripSeatState,
} = require('../models/trips');
const {
  createRideRequest,
  findRideRequestById,
  updateRideRequestStatus,
  deleteRideRequest,
} = require('../models/rideRequests');
const { createNotification } = require('../models/notifications');

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

    if (trip.status === 'cancelled') {
      return res.status(400).json({ error: 'This trip has been cancelled.' });
    }

    if (trip.status === 'full' || Number(trip.seats_available) < 1) {
      return res.status(400).json({ error: 'This trip is already full.' });
    }

    const request = await createRideRequest({
      tripId: trip.id,
      riderId: req.user.id,
      message: message.trim(),
    });

    await createNotification({
      userId: trip.driver_id,
      type: 'ride_request',
      title: 'New ride request',
      body: 'A rider requested a seat on your trip.',
      tripId: trip.id,
      requestId: request.id,
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
  const client = await db.connect();

  try {
    await client.query('BEGIN');

    const request = await findRideRequestById(req.params.id, client);
    if (!request) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Ride request not found.' });
    }

    const trip = await findTripRowById(request.trip_id, client);
    if (!trip || trip.driver_id !== req.user.id) {
      await client.query('ROLLBACK');
      return res.status(403).json({ error: 'Only the driver can accept this request.' });
    }

    if (trip.status === 'cancelled') {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'Cancelled trips cannot accept requests.' });
    }

    if (request.status !== 'pending') {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'Only pending requests can be accepted.' });
    }

    const seatsAvailable = Number(trip.seats_available);
    if (seatsAvailable < 1) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'This trip is already full.' });
    }

    const updatedRequest = await updateRideRequestStatus(request.id, 'accepted', client);
    const remainingSeats = seatsAvailable - 1;
    await updateTripSeatState({
      tripId: request.trip_id,
      seatsAvailable: remainingSeats,
      status: remainingSeats > 0 ? 'open' : 'full',
    }, client);
    await createNotification({
      userId: request.rider_id,
      type: 'request_accepted',
      title: 'Ride request accepted',
      body: 'Your ride request was accepted.',
      tripId: request.trip_id,
      requestId: request.id,
    }, client);

    await client.query('COMMIT');
    return res.json(updatedRequest);
  } catch (error) {
    await client.query('ROLLBACK');
    return res.status(500).json({ error: 'Unable to accept ride request.' });
  } finally {
    client.release();
  }
}

async function rejectRideRequestHandler(req, res) {
  const client = await db.connect();

  try {
    await client.query('BEGIN');

    const request = await findRideRequestById(req.params.id, client);
    if (!request) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Ride request not found.' });
    }

    const trip = await findTripRowById(request.trip_id, client);
    if (!trip || trip.driver_id !== req.user.id) {
      await client.query('ROLLBACK');
      return res.status(403).json({ error: 'Only the driver can reject this request.' });
    }

    const updatedRequest = await updateRideRequestStatus(request.id, 'rejected', client);

    if (request.status === 'accepted' && trip.status !== 'cancelled') {
      const nextSeats = Number(trip.seats_available) + 1;
      await updateTripSeatState({
        tripId: request.trip_id,
        seatsAvailable: nextSeats,
        status: 'open',
      }, client);
    }

    await createNotification({
      userId: request.rider_id,
      type: 'request_rejected',
      title: 'Ride request updated',
      body: 'Your ride request was rejected.',
      tripId: request.trip_id,
      requestId: request.id,
    }, client);

    await client.query('COMMIT');
    return res.json(updatedRequest);
  } catch (error) {
    await client.query('ROLLBACK');
    return res.status(500).json({ error: 'Unable to reject ride request.' });
  } finally {
    client.release();
  }
}

async function withdrawRideRequestHandler(req, res) {
  const client = await db.connect();

  try {
    await client.query('BEGIN');

    const request = await findRideRequestById(req.params.id, client);
    if (!request) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Ride request not found.' });
    }

    if (request.rider_id !== req.user.id) {
      await client.query('ROLLBACK');
      return res.status(403).json({ error: 'Only the rider can withdraw this request.' });
    }

    const trip = await findTripRowById(request.trip_id, client);
    if (!trip) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Trip not found.' });
    }

    if (request.status === 'accepted' && trip.status !== 'cancelled') {
      const nextSeats = Number(trip.seats_available) + 1;
      await updateTripSeatState({
        tripId: request.trip_id,
        seatsAvailable: nextSeats,
        status: 'open',
      }, client);
    }

    const deletedRequest = await deleteRideRequest(request.id, client);
    await client.query('COMMIT');
    return res.json(deletedRequest);
  } catch (error) {
    await client.query('ROLLBACK');
    return res.status(500).json({ error: 'Unable to withdraw ride request.' });
  } finally {
    client.release();
  }
}

module.exports = {
  createRideRequestHandler,
  acceptRideRequestHandler,
  rejectRideRequestHandler,
  withdrawRideRequestHandler,
};
