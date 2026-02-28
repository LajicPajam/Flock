const {
  findUserById,
  updateDriverProfile,
  updateUserProfile,
} = require('../models/users');
const { listTripsForDriver } = require('../models/trips');
const {
  listRideRequestsForRider,
} = require('../models/rideRequests');
const {
  listNotificationsForUser,
  markAllNotificationsRead,
  markNotificationRead,
} = require('../models/notifications');

function sanitizeUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone_number: user.phone_number,
    profile_photo_url: user.profile_photo_url,
    major: user.major,
    academic_year: user.academic_year,
    vibe: user.vibe,
    favorite_playlist: user.favorite_playlist,
    is_driver: user.is_driver,
    car_make: user.car_make,
    car_model: user.car_model,
    car_color: user.car_color,
    car_plate_state: user.car_plate_state,
    car_plate_number: user.car_plate_number,
    car_description: user.car_description,
    created_at: user.created_at,
  };
}

async function getCurrentUserHandler(req, res) {
  try {
    const user = await findUserById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    return res.json({ user: sanitizeUser(user) });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load profile.' });
  }
}

async function updateDriverProfileHandler(req, res) {
  const {
    carMake,
    carModel,
    carColor,
    carPlateState,
    carPlateNumber,
    carDescription,
  } = req.body;

  if (!carMake || !carModel || !carColor || !carPlateState || !carPlateNumber) {
    return res.status(400).json({
      error: 'Car make, model, color, plate state, and plate number are required.',
    });
  }

  try {
    const user = await updateDriverProfile({
      userId: req.user.id,
      carMake: carMake.trim(),
      carModel: carModel.trim(),
      carColor: carColor.trim(),
      carPlateState: carPlateState.trim(),
      carPlateNumber: carPlateNumber.trim(),
      carDescription: carDescription?.trim() || null,
    });

    return res.json({ user: sanitizeUser(user) });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to save driver profile.' });
  }
}

async function updateCurrentUserHandler(req, res) {
  const {
    name,
    phoneNumber,
    profilePhotoUrl,
    major,
    academicYear,
    vibe,
    favoritePlaylist,
    carMake,
    carModel,
    carColor,
    carPlateState,
    carPlateNumber,
    carDescription,
  } = req.body;

  if (!name || !phoneNumber || !profilePhotoUrl) {
    return res.status(400).json({
      error: 'Name, phone number, and profile photo are required.',
    });
  }

  const driverFields = [
    carMake?.trim() || '',
    carModel?.trim() || '',
    carColor?.trim() || '',
    carPlateState?.trim() || '',
    carPlateNumber?.trim() || '',
  ];

  const anyDriverField = driverFields.some((value) => value.isNotEmpty);
  const allDriverFields = driverFields.every((value) => value.isNotEmpty);

  if (anyDriverField && !allDriverFields) {
    return res.status(400).json({
      error: 'To stay registered as a driver, fill in all required car fields.',
    });
  }

  try {
    const user = await updateUserProfile({
      userId: req.user.id,
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
      profilePhotoUrl: profilePhotoUrl.trim(),
      major: major?.trim() || null,
      academicYear: academicYear?.trim() || null,
      vibe: vibe?.trim() || null,
      favoritePlaylist: favoritePlaylist?.trim() || null,
      carMake: allDriverFields ? carMake.trim() : null,
      carModel: allDriverFields ? carModel.trim() : null,
      carColor: allDriverFields ? carColor.trim() : null,
      carPlateState: allDriverFields ? carPlateState.trim() : null,
      carPlateNumber: allDriverFields ? carPlateNumber.trim() : null,
      carDescription: carDescription?.trim() || null,
    });

    return res.json({ user: sanitizeUser(user) });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to update profile.' });
  }
}

async function getMyTripsHandler(req, res) {
  try {
    const trips = await listTripsForDriver(req.user.id);
    return res.json({ trips });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load your trips.' });
  }
}

async function getMyRequestsHandler(req, res) {
  try {
    const requests = await listRideRequestsForRider(req.user.id);
    return res.json({ requests });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load your requests.' });
  }
}

async function getNotificationsHandler(req, res) {
  try {
    const notifications = await listNotificationsForUser(req.user.id);
    return res.json({
      notifications,
      unreadCount: notifications.filter((item) => !item.is_read).length,
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to load notifications.' });
  }
}

async function markAllNotificationsReadHandler(req, res) {
  try {
    await markAllNotificationsRead(req.user.id);
    return res.json({ ok: true });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to update notifications.' });
  }
}

async function markNotificationReadHandler(req, res) {
  try {
    const notification = await markNotificationRead(
      Number(req.params.id),
      req.user.id,
    );
    if (!notification) {
      return res.status(404).json({ error: 'Notification not found.' });
    }

    return res.json(notification);
  } catch (error) {
    return res.status(500).json({ error: 'Unable to update notification.' });
  }
}

module.exports = {
  getCurrentUserHandler,
  updateDriverProfileHandler,
  updateCurrentUserHandler,
  getMyTripsHandler,
  getMyRequestsHandler,
  getNotificationsHandler,
  markAllNotificationsReadHandler,
  markNotificationReadHandler,
};
