const db = require('../db');

async function createUser({
  name,
  email,
  passwordHash,
  phoneNumber,
  profilePhotoUrl,
  major = null,
  academicYear = null,
  vibe = null,
  favoritePlaylist = null,
  isDriver = false,
  carMake = null,
  carModel = null,
  carColor = null,
  carPlateState = null,
  carPlateNumber = null,
  carDescription = null,
}) {
  const result = await db.query(
    `INSERT INTO users (
       name,
       email,
       password_hash,
       phone_number,
       profile_photo_url,
       major,
       academic_year,
       vibe,
       favorite_playlist,
       is_driver,
       car_make,
       car_model,
       car_color,
       car_plate_state,
       car_plate_number,
       car_description
     )
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
     RETURNING
       id,
       name,
       email,
       phone_number,
       profile_photo_url,
       major,
       academic_year,
       vibe,
       favorite_playlist,
       is_driver,
       car_make,
       car_model,
       car_color,
       car_plate_state,
       car_plate_number,
       car_description,
       created_at`,
    [
      name,
      email.toLowerCase(),
      passwordHash,
      phoneNumber,
      profilePhotoUrl,
      major,
      academicYear,
      vibe,
      favoritePlaylist,
      isDriver,
      carMake,
      carModel,
      carColor,
      carPlateState,
      carPlateNumber,
      carDescription,
    ],
  );

  return result.rows[0];
}

async function findUserByEmail(email) {
  const result = await db.query(
    `SELECT
       id,
       name,
       email,
       password_hash,
       phone_number,
       profile_photo_url,
       major,
       academic_year,
       vibe,
       favorite_playlist,
       is_driver,
       car_make,
       car_model,
       car_color,
       car_plate_state,
       car_plate_number,
       car_description,
       created_at
     FROM users
     WHERE email = $1`,
    [email.toLowerCase()],
  );

  return result.rows[0] || null;
}

async function findUserById(id) {
  const result = await db.query(
    `SELECT
       id,
       name,
       email,
       phone_number,
       profile_photo_url,
       major,
       academic_year,
       vibe,
       favorite_playlist,
       is_driver,
       car_make,
       car_model,
       car_color,
       car_plate_state,
       car_plate_number,
       car_description,
       created_at
     FROM users
     WHERE id = $1`,
    [id],
  );

  return result.rows[0] || null;
}

async function updateDriverProfile({
  userId,
  carMake,
  carModel,
  carColor,
  carPlateState,
  carPlateNumber,
  carDescription,
}) {
  const result = await db.query(
    `UPDATE users
     SET
       is_driver = TRUE,
       car_make = $2,
       car_model = $3,
       car_color = $4,
       car_plate_state = $5,
       car_plate_number = $6,
       car_description = $7
     WHERE id = $1
     RETURNING
       id,
       name,
       email,
       phone_number,
       profile_photo_url,
       major,
       academic_year,
       vibe,
       favorite_playlist,
       is_driver,
       car_make,
       car_model,
       car_color,
       car_plate_state,
       car_plate_number,
       car_description,
       created_at`,
    [
      userId,
      carMake,
      carModel,
      carColor,
      carPlateState,
      carPlateNumber,
      carDescription,
    ],
  );

  return result.rows[0] || null;
}

async function updateUserProfile({
  userId,
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
}) {
  const result = await db.query(
    `UPDATE users
     SET
       name = $2,
       phone_number = $3,
       profile_photo_url = $4,
       major = $5,
       academic_year = $6,
       vibe = $7,
       favorite_playlist = $8,
       car_make = $9,
       car_model = $10,
       car_color = $11,
       car_plate_state = $12,
       car_plate_number = $13,
       car_description = $14,
       is_driver = CASE
         WHEN $9 IS NOT NULL AND $10 IS NOT NULL AND $11 IS NOT NULL AND $12 IS NOT NULL AND $13 IS NOT NULL
           THEN TRUE
         ELSE FALSE
       END
     WHERE id = $1
     RETURNING
       id,
       name,
       email,
       phone_number,
       profile_photo_url,
       major,
       academic_year,
       vibe,
       favorite_playlist,
       is_driver,
       car_make,
       car_model,
       car_color,
       car_plate_state,
       car_plate_number,
       car_description,
       created_at`,
    [
      userId,
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
    ],
  );

  return result.rows[0] || null;
}

module.exports = {
  createUser,
  findUserByEmail,
  findUserById,
  updateDriverProfile,
  updateUserProfile,
};
