const { findTripById } = require('../models/trips');
const {
  hasAcceptedRideRequest,
  listAcceptedRidersForTrip,
} = require('../models/rideRequests');
const { listMessagesForTrip, createMessage } = require('../models/messages');

async function resolveMessagingAccess({ tripId, userId, participantId }) {
  const trip = await findTripById(tripId);
  if (!trip) {
    return { error: { code: 404, message: 'Trip not found.' } };
  }

  const isDriver = trip.driver_id === userId;
  if (isDriver) {
    const acceptedRiders = await listAcceptedRidersForTrip(tripId);
    const targetParticipantId = participantId ? Number(participantId) : null;

    if (targetParticipantId) {
      const allowed = acceptedRiders.some((rider) => rider.rider_id === targetParticipantId);
      if (!allowed) {
        return { error: { code: 403, message: 'Drivers may only message accepted riders.' } };
      }
    }

    return {
      trip,
      isDriver: true,
      participantId: targetParticipantId,
      acceptedRiders,
    };
  }

  const accepted = await hasAcceptedRideRequest({
    tripId,
    riderId: userId,
  });

  if (!accepted) {
    return { error: { code: 403, message: 'Messages unlock after a request is accepted.' } };
  }

  return {
    trip,
    isDriver: false,
    participantId: trip.driver_id,
    acceptedRiders: [],
  };
}

async function getMessagesHandler(req, res) {
  try {
    const access = await resolveMessagingAccess({
      tripId: Number(req.params.id),
      userId: req.user.id,
      participantId: req.query.participantId,
    });

    if (access.error) {
      return res.status(access.error.code).json({ error: access.error.message });
    }

    const messages = await listMessagesForTrip({
      tripId: Number(req.params.id),
      viewerId: req.user.id,
      participantId: access.participantId,
      isDriver: access.isDriver,
    });

    return res.json({
      messages,
      can_message: true,
      accepted_riders: access.acceptedRiders,
      participant_id: access.participantId,
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load messages.' });
  }
}

async function createMessageHandler(req, res) {
  const { messageText, receiverId } = req.body;

  if (!messageText || typeof messageText !== 'string' || messageText.trim().length === 0) {
    return res.status(400).json({ error: 'Message text is required.' });
  }

  try {
    const access = await resolveMessagingAccess({
      tripId: Number(req.params.id),
      userId: req.user.id,
      participantId: receiverId,
    });

    if (access.error) {
      return res.status(access.error.code).json({ error: access.error.message });
    }

    let targetReceiverId;
    if (access.isDriver) {
      if (!receiverId) {
        return res.status(400).json({ error: 'Drivers must choose an accepted rider to message.' });
      }
      targetReceiverId = Number(receiverId);
    } else {
      targetReceiverId = access.participantId;
    }

    const message = await createMessage({
      tripId: Number(req.params.id),
      senderId: req.user.id,
      receiverId: targetReceiverId,
      messageText: messageText.trim(),
    });

    return res.status(201).json(message);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to send message.' });
  }
}

module.exports = {
  getMessagesHandler,
  createMessageHandler,
};
