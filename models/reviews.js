const db = require('../db');

async function createReview({
  tripId,
  reviewerId,
  revieweeId,
  rating,
  comment,
}) {
  const result = await db.query(
    `INSERT INTO reviews (trip_id, reviewer_id, reviewee_id, rating, comment)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, trip_id, reviewer_id, reviewee_id, rating, comment, created_at`,
    [tripId, reviewerId, revieweeId, rating, comment || null],
  );

  return result.rows[0];
}

async function listReviewsForUser(userId) {
  const reviewsResult = await db.query(
    `SELECT
       r.id,
       r.trip_id,
       r.reviewer_id,
       r.reviewee_id,
       r.rating,
       r.comment,
       r.created_at,
       reviewer.name AS reviewer_name
     FROM reviews r
     JOIN users reviewer ON reviewer.id = r.reviewer_id
     WHERE r.reviewee_id = $1
     ORDER BY r.created_at DESC`,
    [userId],
  );

  const summaryResult = await db.query(
    `SELECT
       COUNT(*)::int AS review_count,
       COALESCE(ROUND(AVG(rating)::numeric, 1), 0) AS average_rating
     FROM reviews
     WHERE reviewee_id = $1`,
    [userId],
  );

  return {
    reviews: reviewsResult.rows,
    summary: summaryResult.rows[0],
  };
}

module.exports = {
  createReview,
  listReviewsForUser,
};
