const db = require('../db');

async function createUser({
  name,
  email,
  passwordHash,
  phoneNumber,
  profilePhotoUrl,
}) {
  const result = await db.query(
    `INSERT INTO users (name, email, password_hash, phone_number, profile_photo_url)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, name, email, phone_number, profile_photo_url, created_at`,
    [name, email.toLowerCase(), passwordHash, phoneNumber, profilePhotoUrl],
  );

  return result.rows[0];
}

async function findUserByEmail(email) {
  const result = await db.query(
    `SELECT id, name, email, password_hash, phone_number, profile_photo_url, created_at
     FROM users
     WHERE email = $1`,
    [email.toLowerCase()],
  );

  return result.rows[0] || null;
}

async function findUserById(id) {
  const result = await db.query(
    `SELECT id, name, email, phone_number, profile_photo_url, created_at
     FROM users
     WHERE id = $1`,
    [id],
  );

  return result.rows[0] || null;
}

module.exports = {
  createUser,
  findUserByEmail,
  findUserById,
};
