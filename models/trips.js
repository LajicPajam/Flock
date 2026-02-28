const db = require('../db');

const TRIP_SELECT_FIELDS = `SELECT
  t.id,
  t.driver_id,
  t.origin_city,
  t.destination_city,
  t.departure_time,
  t.seats_available,
  t.status,
  t.meeting_spot,
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
  u.car_description AS driver_car_description,
  COALESCE(rs.average_rating, 0) AS driver_average_rating,
  COALESCE(rs.review_count, 0) AS driver_review_count
FROM trips t
JOIN users u ON u.id = t.driver_id
LEFT JOIN (
  SELECT
    reviewee_id,
    COALESCE(ROUND(AVG(rating)::numeric, 1), 0)::float AS average_rating,
    COUNT(*)::int AS review_count
  FROM reviews
  GROUP BY reviewee_id
) rs ON rs.reviewee_id = t.driver_id`;

async function createTrip({
  driverId,
  originCity,
  destinationCity,
  departureTime,
  seatsAvailable,
  meetingSpot,
  notes,
}) {
  const result = await db.query(
    `INSERT INTO trips (
       driver_id,
       origin_city,
       destination_city,
       departure_time,
       seats_available,
       status,
       meeting_spot,
       notes
     )
     VALUES ($1, $2, $3, $4, $5, 'open', $6, $7)
     RETURNING *`,
    [
      driverId,
      originCity,
      destinationCity,
      departureTime,
      seatsAvailable,
      meetingSpot?.trim() || null,
      notes || null,
    ],
  );

  return result.rows[0];
}

async function updateTrip({
  tripId,
  driverId,
  originCity,
  destinationCity,
  departureTime,
  seatsAvailable,
  meetingSpot,
  notes,
}) {
  const result = await db.query(
    `UPDATE trips
     SET
       origin_city = $3,
       destination_city = $4,
       departure_time = $5,
       seats_available = $6,
       meeting_spot = $7,
       status = CASE
         WHEN status = 'cancelled' THEN 'cancelled'
         WHEN status = 'completed' THEN 'completed'
         WHEN $6 = 0 THEN 'full'
         ELSE 'open'
       END,
       notes = $8
     WHERE id = $1 AND driver_id = $2
     RETURNING *`,
    [
      tripId,
      driverId,
      originCity,
      destinationCity,
      departureTime,
      seatsAvailable,
      meetingSpot?.trim() || null,
      notes || null,
    ],
  );

  return result.rows[0] || null;
}

async function listTrips() {
  const result = await db.query(
    `${TRIP_SELECT_FIELDS}
     ORDER BY t.departure_time ASC, t.created_at DESC`,
  );

  return result.rows;
}

async function findTripById(id, client = db) {
  const result = await client.query(
    `${TRIP_SELECT_FIELDS}
     WHERE t.id = $1`,
    [id],
  );

  return result.rows[0] || null;
}

async function findTripRowById(id, client = db) {
  const result = await client.query(
    `SELECT id, driver_id, seats_available, status, departure_time, meeting_spot
     FROM trips
     WHERE id = $1`,
    [id],
  );

  return result.rows[0] || null;
}

async function updateTripSeatState({
  tripId,
  seatsAvailable,
  status,
}, client = db) {
  const result = await client.query(
    `UPDATE trips
     SET
       seats_available = $2,
       status = $3
     WHERE id = $1
     RETURNING id, driver_id, seats_available, status, departure_time, meeting_spot`,
    [tripId, seatsAvailable, status],
  );

  return result.rows[0] || null;
}

async function cancelTrip({ tripId, driverId }) {
  const result = await db.query(
    `UPDATE trips
     SET status = 'cancelled'
     WHERE id = $1 AND driver_id = $2
     RETURNING *`,
    [tripId, driverId],
  );

  return result.rows[0] || null;
}

async function completeTrip({ tripId, driverId }) {
  const result = await db.query(
    `UPDATE trips
     SET status = 'completed'
     WHERE id = $1 AND driver_id = $2 AND status <> 'cancelled'
     RETURNING *`,
    [tripId, driverId],
  );

  return result.rows[0] || null;
}

async function listTripsForDriver(driverId) {
  const result = await db.query(
    `${TRIP_SELECT_FIELDS}
     WHERE t.driver_id = $1
     ORDER BY t.departure_time DESC, t.created_at DESC`,
    [driverId],
  );

  return result.rows;
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
  updateTrip,
  listTrips,
  findTripById,
  findTripRowById,
  updateTripSeatState,
  cancelTrip,
  completeTrip,
  listTripsForDriver,
  listRideRequestsForTrip,
  findViewerRequest,
};
