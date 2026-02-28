const db = require('../db');

async function listMessagesForTrip({ tripId, viewerId, participantId, isDriver }) {
  if (isDriver && !participantId) {
    const result = await db.query(
      `SELECT
         m.id,
         m.trip_id,
         m.sender_id,
         m.receiver_id,
         m.message_text,
         m.created_at,
         sender.name AS sender_name,
         receiver.name AS receiver_name
       FROM messages m
       JOIN users sender ON sender.id = m.sender_id
       JOIN users receiver ON receiver.id = m.receiver_id
       WHERE m.trip_id = $1
       ORDER BY m.created_at ASC`,
      [tripId],
    );
    return result.rows;
  }

  const otherUserId = participantId;
  const result = await db.query(
    `SELECT
       m.id,
       m.trip_id,
       m.sender_id,
       m.receiver_id,
       m.message_text,
       m.created_at,
       sender.name AS sender_name,
       receiver.name AS receiver_name
     FROM messages m
     JOIN users sender ON sender.id = m.sender_id
     JOIN users receiver ON receiver.id = m.receiver_id
     WHERE m.trip_id = $1
       AND (
         (m.sender_id = $2 AND m.receiver_id = $3)
         OR
         (m.sender_id = $3 AND m.receiver_id = $2)
       )
     ORDER BY m.created_at ASC`,
    [tripId, viewerId, otherUserId],
  );

  return result.rows;
}

async function createMessage({ tripId, senderId, receiverId, messageText }) {
  const result = await db.query(
    `INSERT INTO messages (trip_id, sender_id, receiver_id, message_text)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [tripId, senderId, receiverId, messageText],
  );

  return result.rows[0];
}

module.exports = {
  listMessagesForTrip,
  createMessage,
};
