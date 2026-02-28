const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const { createUser, findUserByEmail } = require('../models/users');

function sanitizeUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone_number: user.phone_number,
    profile_photo_url: user.profile_photo_url,
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

function buildToken(user) {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      name: user.name,
    },
    process.env.JWT_SECRET,
    { expiresIn: '7d' },
  );
}

async function register(req, res) {
  const {
    name,
    email,
    password,
    phoneNumber,
    profilePhotoUrl,
    isDriver,
    carMake,
    carModel,
    carColor,
    carPlateState,
    carPlateNumber,
    carDescription,
  } = req.body;

  if (!name || !email || !password || !phoneNumber || !profilePhotoUrl) {
    return res.status(400).json({ error: 'Name, email, password, phone number, and profile photo URL are required.' });
  }

  if (isDriver) {
    if (!carMake || !carModel || !carColor || !carPlateState || !carPlateNumber) {
      return res.status(400).json({
        error: 'Registered drivers must include car make, model, color, plate state, and plate number.',
      });
    }
  }

  try {
    const existingUser = await findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({ error: 'Email is already in use.' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await createUser({
      name,
      email,
      passwordHash,
      phoneNumber,
      profilePhotoUrl,
      isDriver: Boolean(isDriver),
      carMake: carMake?.trim() || null,
      carModel: carModel?.trim() || null,
      carColor: carColor?.trim() || null,
      carPlateState: carPlateState?.trim() || null,
      carPlateNumber: carPlateNumber?.trim() || null,
      carDescription: carDescription?.trim() || null,
    });

    return res.status(201).json({
      token: buildToken(user),
      user: sanitizeUser(user),
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to register user.' });
  }
}

async function login(req, res) {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required.' });
  }

  try {
    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }

    const passwordMatches = await bcrypt.compare(password, user.password_hash);
    if (!passwordMatches) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }

    return res.json({
      token: buildToken(user),
      user: sanitizeUser(user),
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to log in.' });
  }
}

module.exports = {
  register,
  login,
};
