const db = require('../db');

async function createNotification({
  userId,
  type,
  title,
  body,
  tripId = null,
  requestId = null,
}, client = db) {
  const result = await client.query(
    `INSERT INTO notifications (
       user_id,
       type,
       title,
       body,
       trip_id,
       request_id
     )
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [userId, type, title, body, tripId, requestId],
  );

  return result.rows[0];
}

async function listNotificationsForUser(userId) {
  const result = await db.query(
    `SELECT
       id,
       user_id,
       type,
       title,
       body,
       trip_id,
       request_id,
       is_read,
       created_at
     FROM notifications
     WHERE user_id = $1
     ORDER BY created_at DESC`,
    [userId],
  );

  return result.rows;
}

async function markAllNotificationsRead(userId) {
  await db.query(
    `UPDATE notifications
     SET is_read = TRUE
     WHERE user_id = $1 AND is_read = FALSE`,
    [userId],
  );
}

async function markNotificationRead(notificationId, userId) {
  const result = await db.query(
    `UPDATE notifications
     SET is_read = TRUE
     WHERE id = $1 AND user_id = $2
     RETURNING *`,
    [notificationId, userId],
  );

  return result.rows[0] || null;
}

module.exports = {
  createNotification,
  listNotificationsForUser,
  markAllNotificationsRead,
  markNotificationRead,
};
