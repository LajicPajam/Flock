const db = require('../db');

const TRIP_SELECT_FIELDS = `SELECT
  t.id,
  t.driver_id,
  t.origin_city,
  t.destination_city,
  t.origin_label,
  t.destination_label,
  t.origin_latitude,
  t.origin_longitude,
  t.destination_latitude,
  t.destination_longitude,
  t.departure_time,
  t.seats_available,
  t.status,
  t.meeting_spot,
  t.event_category,
  t.event_name,
  t.notes,
  t.created_at,
  u.name AS driver_name,
  u.phone_number AS driver_phone_number,
  u.profile_photo_url AS driver_profile_photo_url,
  u.gender AS driver_gender,
  u.is_student_verified AS driver_is_student_verified,
  u.verified_school_name AS driver_verified_school_name,
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
  originLabel,
  destinationLabel,
  originLatitude,
  originLongitude,
  destinationLatitude,
  destinationLongitude,
  departureTime,
  seatsAvailable,
  meetingSpot,
  eventCategory,
  eventName,
  notes,
}) {
  const result = await db.query(
    `INSERT INTO trips (
       driver_id,
       origin_city,
       destination_city,
       origin_label,
       destination_label,
       origin_latitude,
       origin_longitude,
       destination_latitude,
       destination_longitude,
       departure_time,
       seats_available,
       status,
       meeting_spot,
       event_category,
       event_name,
       notes
     )
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'open', $12, $13, $14, $15)
     RETURNING *`,
    [
      driverId,
      originCity,
      destinationCity,
      originLabel?.trim() || null,
      destinationLabel?.trim() || null,
      originLatitude ?? null,
      originLongitude ?? null,
      destinationLatitude ?? null,
      destinationLongitude ?? null,
      departureTime,
      seatsAvailable,
      meetingSpot?.trim() || null,
      eventCategory?.trim() || null,
      eventName?.trim() || null,
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
  originLabel,
  destinationLabel,
  originLatitude,
  originLongitude,
  destinationLatitude,
  destinationLongitude,
  departureTime,
  seatsAvailable,
  meetingSpot,
  eventCategory,
  eventName,
  notes,
}) {
  const result = await db.query(
    `UPDATE trips
     SET
       origin_city = $3,
       destination_city = $4,
       origin_label = $5,
       destination_label = $6,
       origin_latitude = $7,
       origin_longitude = $8,
       destination_latitude = $9,
       destination_longitude = $10,
       departure_time = $11,
       seats_available = $12,
       meeting_spot = $13,
       event_category = $14,
       event_name = $15,
       status = CASE
         WHEN status = 'cancelled' THEN 'cancelled'
         WHEN status = 'completed' THEN 'completed'
         WHEN $12 = 0 THEN 'full'
         ELSE 'open'
       END,
       notes = $16
     WHERE id = $1 AND driver_id = $2
     RETURNING *`,
    [
      tripId,
      driverId,
      originCity,
      destinationCity,
      originLabel?.trim() || null,
      destinationLabel?.trim() || null,
      originLatitude ?? null,
      originLongitude ?? null,
      destinationLatitude ?? null,
      destinationLongitude ?? null,
      departureTime,
      seatsAvailable,
      meetingSpot?.trim() || null,
      eventCategory?.trim() || null,
      eventName?.trim() || null,
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
    `SELECT id, driver_id, seats_available, status, departure_time, meeting_spot,
            origin_label, destination_label,
            origin_latitude, origin_longitude,
            destination_latitude, destination_longitude
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
     RETURNING id, driver_id, seats_available, status, departure_time, meeting_spot,
               origin_label, destination_label,
               origin_latitude, origin_longitude,
               destination_latitude, destination_longitude`,
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
       u.profile_photo_url AS rider_profile_photo_url,
       u.major AS rider_major,
       u.academic_year AS rider_academic_year,
       u.vibe AS rider_vibe,
       u.favorite_playlist AS rider_favorite_playlist,
       COALESCE(rs.average_rating, 0) AS rider_average_rating
     FROM ride_requests rr
     JOIN users u ON u.id = rr.rider_id
     LEFT JOIN (
       SELECT
         reviewee_id,
         COALESCE(ROUND(AVG(rating)::numeric, 1), 0)::float AS average_rating
       FROM reviews
       GROUP BY reviewee_id
     ) rs ON rs.reviewee_id = rr.rider_id
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

async function autoCompleteExpiredTrips() {
  await db.query(
    `UPDATE trips
     SET status = 'completed'
     WHERE status IN ('open', 'full')
       AND departure_time < NOW()
       AND EXISTS (
         SELECT 1 FROM ride_requests rr
         WHERE rr.trip_id = trips.id AND rr.status = 'accepted'
       )`,
  );
}

async function setTripStatus(tripId, status) {
  const result = await db.query(
    `UPDATE trips SET status = $2 WHERE id = $1 RETURNING *`,
    [tripId, status],
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
  autoCompleteExpiredTrips,
  setTripStatus,
};
