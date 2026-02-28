const db = require('../db');

async function createRideRequest({ tripId, riderId, message }) {
  const result = await db.query(
    `INSERT INTO ride_requests (trip_id, rider_id, message)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [tripId, riderId, message],
  );

  return result.rows[0];
}

async function findRideRequestById(id, client = db) {
  const result = await client.query(
    `SELECT id, trip_id, rider_id, message, status, created_at
     FROM ride_requests
     WHERE id = $1`,
    [id],
  );

  return result.rows[0] || null;
}

async function updateRideRequestStatus(id, status, client = db) {
  const result = await client.query(
    `UPDATE ride_requests
     SET status = $2
     WHERE id = $1
     RETURNING *`,
    [id, status],
  );

  return result.rows[0] || null;
}

async function hasAcceptedRideRequest({ tripId, riderId }) {
  const result = await db.query(
    `SELECT 1
     FROM ride_requests
     WHERE trip_id = $1 AND rider_id = $2 AND status = 'accepted'`,
    [tripId, riderId],
  );

  return result.rows.length > 0;
}

async function listAcceptedRidersForTrip(tripId) {
  const result = await db.query(
    `SELECT
       rr.id,
       rr.rider_id,
       rr.message,
       rr.status,
       rr.created_at,
       u.name AS rider_name
     FROM ride_requests rr
     JOIN users u ON u.id = rr.rider_id
     WHERE rr.trip_id = $1 AND rr.status = 'accepted'
     ORDER BY rr.created_at ASC`,
    [tripId],
  );

  return result.rows;
}

async function deleteRideRequest(id, client = db) {
  const result = await client.query(
    `DELETE FROM ride_requests
     WHERE id = $1
     RETURNING id, trip_id, rider_id, message, status, created_at`,
    [id],
  );

  return result.rows[0] || null;
}

async function listRideRequestsForRider(riderId) {
  const result = await db.query(
    `SELECT
       rr.id AS request_id,
       rr.trip_id,
       rr.rider_id,
       rr.message,
       rr.status,
       rr.created_at,
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
       t.meeting_spot,
       t.seats_available,
       t.status AS trip_status,
       u.name AS driver_name,
       COALESCE(rs.average_rating, 0) AS driver_average_rating,
       COALESCE(rs.review_count, 0) AS driver_review_count
     FROM ride_requests rr
     JOIN trips t ON t.id = rr.trip_id
     JOIN users u ON u.id = t.driver_id
     LEFT JOIN (
       SELECT
         reviewee_id,
         COALESCE(ROUND(AVG(rating)::numeric, 1), 0)::float AS average_rating,
         COUNT(*)::int AS review_count
       FROM reviews
       GROUP BY reviewee_id
     ) rs ON rs.reviewee_id = t.driver_id
     WHERE rr.rider_id = $1
     ORDER BY rr.created_at DESC`,
    [riderId],
  );

  return result.rows;
}

async function listPendingIncomingRequestsForDriver(driverId) {
  const result = await db.query(
    `SELECT
       rr.id AS request_id,
       rr.trip_id,
       rr.rider_id,
       rr.message,
       rr.status,
       rr.created_at,
       t.origin_city,
       t.destination_city,
       t.origin_label,
       t.destination_label,
       t.departure_time,
       u.name AS rider_name
     FROM ride_requests rr
     JOIN trips t ON t.id = rr.trip_id
     JOIN users u ON u.id = rr.rider_id
     WHERE t.driver_id = $1 AND rr.status = 'pending' AND t.status <> 'cancelled'
     ORDER BY rr.created_at DESC`,
    [driverId],
  );

  return result.rows;
}

async function listRiderDecisionUpdates(riderId) {
  const result = await db.query(
    `SELECT
       rr.id AS request_id,
       rr.trip_id,
       rr.rider_id,
       rr.message,
       rr.status,
       rr.created_at,
       t.origin_city,
       t.destination_city,
       t.origin_label,
       t.destination_label,
       t.departure_time,
       t.status AS trip_status,
       u.name AS driver_name
     FROM ride_requests rr
     JOIN trips t ON t.id = rr.trip_id
     JOIN users u ON u.id = t.driver_id
     WHERE rr.rider_id = $1 AND rr.status IN ('accepted', 'rejected')
     ORDER BY rr.created_at DESC`,
    [riderId],
  );

  return result.rows;
}

module.exports = {
  createRideRequest,
  findRideRequestById,
  updateRideRequestStatus,
  hasAcceptedRideRequest,
  listAcceptedRidersForTrip,
  deleteRideRequest,
  listRideRequestsForRider,
  listPendingIncomingRequestsForDriver,
  listRiderDecisionUpdates,
};
