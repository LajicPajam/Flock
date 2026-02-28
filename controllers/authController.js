const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const { createUser, findUserByEmail } = require('../models/users');

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
  } = req.body;

  if (!name || !email || !password || !phoneNumber || !profilePhotoUrl) {
    return res.status(400).json({ error: 'Name, email, password, phone number, and profile photo URL are required.' });
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
    });

    return res.status(201).json({
      token: buildToken(user),
      user,
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
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone_number: user.phone_number,
        profile_photo_url: user.profile_photo_url,
        created_at: user.created_at,
      },
    });
  } catch (error) {
    return res.status(500).json({ error: 'Unable to log in.' });
  }
}

module.exports = {
  register,
  login,
};
