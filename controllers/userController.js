const {
  findUserById,
  updateDriverProfile,
  updateUserProfile,
  beginStudentVerification,
  completeStudentVerification,
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
    gender: user.gender,
    student_email: user.student_email,
    pending_student_email: user.pending_student_email,
    is_student_verified: user.is_student_verified,
    verified_school_name: user.verified_school_name,
    student_verified_at: user.student_verified_at,
    student_verification_expires_at: user.student_verification_expires_at,
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

const EDU_EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.edu$/i;
const VERIFICATION_WINDOW_MS = 10 * 60 * 1000;

function isEduEmail(value) {
  return EDU_EMAIL_REGEX.test(value);
}

function deriveSchoolName(email) {
  const domain = email.toLowerCase().split('@')[1] || '';
  const parts = domain.split('.').filter(Boolean);
  const eduIndex = parts.lastIndexOf('edu');
  const base = eduIndex > 0 ? parts[eduIndex - 1] : parts[0] || 'Student';

  return base
    .split(/[-_]+/)
    .filter(Boolean)
    .map((part) => {
      if (/^[a-z]+$/i.test(part) && part.length <= 4) {
        return part.toUpperCase();
      }

      return part[0].toUpperCase() + part.slice(1);
    })
    .join(' ');
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
    gender,
  } = req.body;

  if (!carMake || !carModel || !carColor || !carPlateState || !carPlateNumber) {
    return res.status(400).json({
      error: 'Car make, model, color, plate state, and plate number are required.',
    });
  }

  if (!gender || !['male', 'female'].includes(String(gender).toLowerCase())) {
    return res.status(400).json({
      error: 'Drivers must set gender to male or female.',
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
      gender: gender.trim().toLowerCase(),
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
    gender,
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

  const anyDriverField = driverFields.some((value) => value.length > 0);
  const allDriverFields = driverFields.every((value) => value.length > 0);

  if (anyDriverField && !allDriverFields) {
    return res.status(400).json({
      error: 'To stay registered as a driver, fill in all required car fields.',
    });
  }

  const normalizedGender = gender?.trim().toLowerCase() || null;
  if (allDriverFields && !normalizedGender) {
    return res.status(400).json({
      error: 'Drivers must set gender to male or female.',
    });
  }

  if (normalizedGender && !['male', 'female'].includes(normalizedGender)) {
    return res.status(400).json({
      error: 'Gender must be either male or female.',
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
      gender: normalizedGender,
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

async function startStudentVerificationHandler(req, res) {
  const rawStudentEmail = String(req.body.studentEmail || '').trim().toLowerCase();

  if (!rawStudentEmail) {
    return res.status(400).json({ error: 'A .edu email is required.' });
  }

  if (!isEduEmail(rawStudentEmail)) {
    return res.status(400).json({
      error: 'Use a valid .edu email to verify your student status.',
    });
  }

  try {
    const currentUser = await findUserById(req.user.id);
    if (!currentUser) {
      return res.status(404).json({ error: 'User not found.' });
    }

    if (
      currentUser.is_student_verified &&
      currentUser.student_email &&
      currentUser.student_email.toLowerCase() === rawStudentEmail
    ) {
      return res.json({
        user: sanitizeUser(currentUser),
        message: 'That school email is already verified.',
      });
    }

    const verificationCode = String(
      Math.floor(100000 + Math.random() * 900000),
    );
    const expiresAt = new Date(Date.now() + VERIFICATION_WINDOW_MS);

    const updatedUser = await beginStudentVerification({
      userId: req.user.id,
      studentEmail: rawStudentEmail,
      verificationCode,
      expiresAt,
    });

    return res.json({
      user: sanitizeUser(updatedUser),
      message:
        'Verification code generated. In local development, use the code shown in the app.',
      dev_verification_code: verificationCode,
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to start student verification.' });
  }
}

async function confirmStudentVerificationHandler(req, res) {
  const code = String(req.body.code || '').trim();

  if (!code) {
    return res.status(400).json({ error: 'Enter the verification code.' });
  }

  try {
    const currentUser = await findUserById(req.user.id);
    if (!currentUser) {
      return res.status(404).json({ error: 'User not found.' });
    }

    if (!currentUser.pending_student_email || !currentUser.student_verification_code) {
      return res.status(400).json({
        error: 'Request a verification code before confirming.',
      });
    }

    if (currentUser.student_verification_code !== code) {
      return res.status(400).json({ error: 'That verification code is incorrect.' });
    }

    if (
      !currentUser.student_verification_expires_at ||
      new Date(currentUser.student_verification_expires_at).getTime() < Date.now()
    ) {
      return res.status(400).json({
        error: 'That verification code expired. Request a new one.',
      });
    }

    const updatedUser = await completeStudentVerification({
      userId: req.user.id,
      studentEmail: currentUser.pending_student_email,
      verifiedSchoolName: deriveSchoolName(currentUser.pending_student_email),
    });

    return res.json({
      user: sanitizeUser(updatedUser),
      message: 'Student email verified.',
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to verify your student email.' });
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
  startStudentVerificationHandler,
  confirmStudentVerificationHandler,
};
