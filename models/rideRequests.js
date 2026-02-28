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

async function findRideRequestById(id) {
  const result = await db.query(
    `SELECT id, trip_id, rider_id, message, status, created_at
     FROM ride_requests
     WHERE id = $1`,
    [id],
  );

  return result.rows[0] || null;
}

async function updateRideRequestStatus(id, status) {
  const result = await db.query(
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

module.exports = {
  createRideRequest,
  findRideRequestById,
  updateRideRequestStatus,
  hasAcceptedRideRequest,
  listAcceptedRidersForTrip,
};
