const { listAcceptedRidersForTrip } = require('../models/rideRequests');
const { createReview, listReviewsForUser } = require('../models/reviews');
const { findTripById, findViewerRequest } = require('../models/trips');

function isTripInPast(trip) {
  return new Date(trip.departure_time).getTime() < Date.now();
}

async function createTripReviewHandler(req, res) {
  const { revieweeId, rating, comment } = req.body;
  const revieweeIdNumber = Number(revieweeId);
  const ratingNumber = Number(rating);

  if (!revieweeIdNumber || !Number.isInteger(ratingNumber)) {
    return res.status(400).json({
      error: 'Reviewee and integer rating are required.',
    });
  }

  if (ratingNumber < 1 || ratingNumber > 5) {
    return res.status(400).json({ error: 'Rating must be between 1 and 5.' });
  }

  try {
    const trip = await findTripById(req.params.id);
    if (!trip) {
      return res.status(404).json({ error: 'Trip not found.' });
    }

    if (!isTripInPast(trip)) {
      return res.status(403).json({
        error: 'Reviews unlock after the trip departure time has passed.',
      });
    }

    if (revieweeIdNumber === req.user.id) {
      return res.status(400).json({ error: 'You cannot review yourself.' });
    }

    if (trip.driver_id === req.user.id) {
      const acceptedRiders = await listAcceptedRidersForTrip(trip.id);
      const canReview = acceptedRiders.some(
        (rider) => rider.rider_id === revieweeIdNumber,
      );

      if (!canReview) {
        return res.status(403).json({
          error: 'Drivers may only review riders they accepted for this trip.',
        });
      }
    } else {
      const viewerRequest = await findViewerRequest(trip.id, req.user.id);
      if (!viewerRequest || viewerRequest.status !== 'accepted') {
        return res.status(403).json({
          error: 'Only accepted riders can review the driver.',
        });
      }

      if (revieweeIdNumber !== trip.driver_id) {
        return res.status(403).json({
          error: 'Accepted riders may only review the driver for this trip.',
        });
      }
    }

    const review = await createReview({
      tripId: trip.id,
      reviewerId: req.user.id,
      revieweeId: revieweeIdNumber,
      rating: ratingNumber,
      comment: comment?.trim() || null,
    });

    return res.status(201).json(review);
  } catch (error) {
    if (error.code === '23505') {
      return res.status(409).json({
        error: 'You have already reviewed this person for this trip.',
      });
    }

    return res.status(500).json({ error: 'Unable to save review.' });
  }
}

async function getUserReviewsHandler(req, res) {
  try {
    const userId = Number(req.params.id);
    if (!userId) {
      return res.status(400).json({ error: 'Valid user id is required.' });
    }

    const result = await listReviewsForUser(userId);
    return res.json(result);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load reviews.' });
  }
}

module.exports = {
  createTripReviewHandler,
  getUserReviewsHandler,
};
