const { getOptionalUser } = require('../middleware/auth');
const { getCarbonSavedForUser, getCarbonSavedForUsers } = require('../models/carbon');
const { isValidCity } = require('../models/cities');
const { findUserById } = require('../models/users');
const {
  createTrip,
  updateTrip,
  cancelTrip,
  completeTrip,
  listTrips,
  findTripById,
  listTripsForDriver,
  listRideRequestsForTrip,
  findViewerRequest,
} = require('../models/trips');
const { createNotification } = require('../models/notifications');

async function createTripHandler(req, res) {
  const {
    originCity,
    destinationCity,
    departureTime,
    seatsAvailable,
    meetingSpot,
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
      meetingSpot,
      notes,
    });

    return res.status(201).json(trip);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to create trip.' });
  }
}

async function updateTripHandler(req, res) {
  const {
    originCity,
    destinationCity,
    departureTime,
    seatsAvailable,
    meetingSpot,
    notes,
  } = req.body;

  if (!originCity || !destinationCity || !departureTime || !seatsAvailable) {
    return res.status(400).json({
      error:
        'Origin, destination, departure time, and seats available are required.',
    });
  }

  if (
    !isValidCity(originCity) ||
    !isValidCity(destinationCity) ||
    originCity === destinationCity
  ) {
    return res.status(400).json({
      error: 'Trip cities must be different supported cities.',
    });
  }

  if (Number(seatsAvailable) < 0) {
    return res.status(400).json({ error: 'Seats available cannot be negative.' });
  }

  try {
    const trip = await findTripById(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'Trip not found.' });
    }

    if (trip.driver_id !== req.user.id) {
      return res.status(403).json({
        error: 'Only the driver who posted this trip can edit it.',
      });
    }

    const updatedTrip = await updateTrip({
      tripId: Number(req.params.id),
      driverId: req.user.id,
      originCity,
      destinationCity,
      departureTime,
      seatsAvailable: Number(seatsAvailable),
      meetingSpot,
      notes,
    });

    return res.json(updatedTrip);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to update trip.' });
  }
}

async function listTripsHandler(_req, res) {
  try {
    const trips = await listTrips();
    const driverIds = [...new Set(trips.map((t) => t.driver_id))];
    const carbonMap = await getCarbonSavedForUsers(driverIds);
    const enriched = trips.map((t) => ({
      ...t,
      driver_carbon_saved_grams: carbonMap[t.driver_id] || 0,
    }));
    return res.json(enriched);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load trips.' });
  }
}

async function listMyTripsHandler(req, res) {
  try {
    const trips = await listTripsForDriver(req.user.id);
    return res.json(trips);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load your trips.' });
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

    const canViewCarInfo =
      Boolean(viewer && viewer.id === trip.driver_id) ||
      viewerRequest?.status === 'accepted';

    const safeTrip = canViewCarInfo
      ? trip
      : {
          ...trip,
          driver_car_make: null,
          driver_car_model: null,
          driver_car_color: null,
          driver_car_plate_state: null,
          driver_car_plate_number: null,
          driver_car_description: null,
        };

    const driverCarbon = await getCarbonSavedForUser(trip.driver_id);

    return res.json({
      ...safeTrip,
      driver_carbon_saved_grams: driverCarbon.total_co2_saved_grams,
      viewer_request: viewerRequest,
      ride_requests: rideRequests,
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load trip.' });
  }
}

async function cancelTripHandler(req, res) {
  try {
    const trip = await findTripById(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'Trip not found.' });
    }

    if (trip.driver_id !== req.user.id) {
      return res.status(403).json({ error: 'Only the driver can cancel this trip.' });
    }

    if (trip.status === 'cancelled') {
      return res.status(400).json({ error: 'This trip is already cancelled.' });
    }

    const updatedTrip = await cancelTrip({
      tripId: Number(req.params.id),
      driverId: req.user.id,
    });

    const rideRequests = await listRideRequestsForTrip(Number(req.params.id));
    await Promise.all(
      rideRequests
          .filter((request) => request.status === 'accepted')
          .map((request) =>
            createNotification({
              userId: request.rider_id,
              type: 'trip_cancelled',
              title: 'Trip cancelled',
              body: 'A driver cancelled one of your upcoming trips.',
              tripId: Number(req.params.id),
              requestId: request.id,
            }),
          ),
    );

    return res.json(updatedTrip);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to cancel trip.' });
  }
}

async function completeTripHandler(req, res) {
  try {
    const trip = await findTripById(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'Trip not found.' });
    }

    if (trip.driver_id !== req.user.id) {
      return res.status(403).json({ error: 'Only the driver can complete this trip.' });
    }

    if (trip.status === 'completed') {
      return res.status(400).json({ error: 'This trip is already completed.' });
    }

    if (trip.status === 'cancelled') {
      return res.status(400).json({ error: 'Cancelled trips cannot be completed.' });
    }

    if (new Date(trip.departure_time) > new Date()) {
      return res.status(400).json({ error: 'Trips can only be completed after departure time.' });
    }

    const updatedTrip = await completeTrip({
      tripId: Number(req.params.id),
      driverId: req.user.id,
    });

    const rideRequests = await listRideRequestsForTrip(Number(req.params.id));
    await Promise.all(
      rideRequests
          .filter((request) => request.status === 'accepted')
          .map((request) =>
            createNotification({
              userId: request.rider_id,
              type: 'trip_completed',
              title: 'Trip completed',
              body: 'Your completed trip is now in history. Leave a review if you have not yet.',
              tripId: Number(req.params.id),
              requestId: request.id,
            }),
          ),
    );

    return res.json(updatedTrip);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to complete trip.' });
  }
}

module.exports = {
  createTripHandler,
  updateTripHandler,
  cancelTripHandler,
  completeTripHandler,
  listTripsHandler,
  listMyTripsHandler,
  getTripByIdHandler,
};
