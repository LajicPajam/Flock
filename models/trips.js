const db = require('../db');

async function createTrip({
  driverId,
  originCity,
  destinationCity,
  departureTime,
  seatsAvailable,
  notes,
}) {
  const result = await db.query(
    `INSERT INTO trips (driver_id, origin_city, destination_city, departure_time, seats_available, notes)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [driverId, originCity, destinationCity, departureTime, seatsAvailable, notes || null],
  );

  return result.rows[0];
}

async function listTrips() {
  const result = await db.query(
    `SELECT
       t.id,
       t.driver_id,
       t.origin_city,
       t.destination_city,
       t.departure_time,
       t.seats_available,
       t.notes,
       t.created_at,
       u.name AS driver_name,
       u.phone_number AS driver_phone_number,
       u.profile_photo_url AS driver_profile_photo_url,
       u.car_make AS driver_car_make,
       u.car_model AS driver_car_model,
       u.car_color AS driver_car_color,
       u.car_plate_state AS driver_car_plate_state,
       u.car_plate_number AS driver_car_plate_number,
       u.car_description AS driver_car_description
     FROM trips t
     JOIN users u ON u.id = t.driver_id
     ORDER BY t.departure_time ASC, t.created_at DESC`,
  );

  return result.rows;
}

async function findTripById(id) {
  const result = await db.query(
    `SELECT
       t.id,
       t.driver_id,
       t.origin_city,
       t.destination_city,
       t.departure_time,
       t.seats_available,
       t.notes,
       t.created_at,
       u.name AS driver_name,
       u.phone_number AS driver_phone_number,
       u.profile_photo_url AS driver_profile_photo_url,
       u.car_make AS driver_car_make,
       u.car_model AS driver_car_model,
       u.car_color AS driver_car_color,
       u.car_plate_state AS driver_car_plate_state,
       u.car_plate_number AS driver_car_plate_number,
       u.car_description AS driver_car_description
     FROM trips t
     JOIN users u ON u.id = t.driver_id
     WHERE t.id = $1`,
    [id],
  );

  return result.rows[0] || null;
}

async function listRideRequestsForTrip(tripId) {
  const result = await db.query(
    `SELECT
       rr.id,
       rr.trip_id,
       rr.rider_id,
       rr.message,
       rr.status,
       rr.created_at,
       u.name AS rider_name,
       u.phone_number AS rider_phone_number,
       u.profile_photo_url AS rider_profile_photo_url
     FROM ride_requests rr
     JOIN users u ON u.id = rr.rider_id
     WHERE rr.trip_id = $1
     ORDER BY rr.created_at ASC`,
    [tripId],
  );

  return result.rows;
}

async function findViewerRequest(tripId, riderId) {
  const result = await db.query(
    `SELECT id, trip_id, rider_id, message, status, created_at
     FROM ride_requests
     WHERE trip_id = $1 AND rider_id = $2`,
    [tripId, riderId],
  );

  return result.rows[0] || null;
}

module.exports = {
  createTrip,
  listTrips,
  findTripById,
  listRideRequestsForTrip,
  findViewerRequest,
};
