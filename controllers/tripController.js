const { getOptionalUser } = require('../middleware/auth');
const { isValidCity } = require('../models/cities');
const { findUserById } = require('../models/users');
const {
  createTrip,
  listTrips,
  findTripById,
  listRideRequestsForTrip,
  findViewerRequest,
} = require('../models/trips');

async function createTripHandler(req, res) {
  const {
    originCity,
    destinationCity,
    departureTime,
    seatsAvailable,
    notes,
  } = req.body;

  if (!originCity || !destinationCity || !departureTime || !seatsAvailable) {
    return res.status(400).json({ error: 'Origin, destination, departure time, and seats available are required.' });
  }

  if (!isValidCity(originCity) || !isValidCity(destinationCity) || originCity === destinationCity) {
    return res.status(400).json({ error: 'Trip cities must be different supported cities.' });
  }

  if (Number(seatsAvailable) < 1) {
    return res.status(400).json({ error: 'Seats available must be at least 1.' });
  }

  try {
    const user = await findUserById(req.user.id);
    if (!user?.is_driver) {
      return res.status(403).json({
        error: 'You must complete driver registration before posting a trip.',
      });
    }

    const trip = await createTrip({
      driverId: req.user.id,
      originCity,
      destinationCity,
      departureTime,
      seatsAvailable: Number(seatsAvailable),
      notes,
    });

    return res.status(201).json(trip);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to create trip.' });
  }
}

async function listTripsHandler(_req, res) {
  try {
    const trips = await listTrips();
    return res.json(trips);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load trips.' });
  }
}

async function getTripByIdHandler(req, res) {
  try {
    const trip = await findTripById(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'Trip not found.' });
    }

    const viewer = getOptionalUser(req);
    let viewerRequest = null;
    if (viewer && viewer.id !== trip.driver_id) {
      viewerRequest = await findViewerRequest(trip.id, viewer.id);
    }

    let rideRequests = [];
    if (viewer && viewer.id === trip.driver_id) {
      rideRequests = await listRideRequestsForTrip(trip.id);
    }

    return res.json({
      ...trip,
      viewer_request: viewerRequest,
      ride_requests: rideRequests,
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load trip.' });
  }
}

module.exports = {
  createTripHandler,
  listTripsHandler,
  getTripByIdHandler,
};
