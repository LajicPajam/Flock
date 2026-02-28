const db = require('../db');

const USER_RETURN_FIELDS = `id,
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
       student_email,
       pending_student_email,
       student_verification_code,
       is_student_verified,
       verified_school_name,
       student_verified_at,
       student_verification_expires_at,
       created_at`;

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
     RETURNING ${USER_RETURN_FIELDS}`,
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
       ${USER_RETURN_FIELDS},
       password_hash
     FROM users
     WHERE email = $1`,
    [email.toLowerCase()],
  );

  return result.rows[0] || null;
}

async function findUserById(id) {
  const result = await db.query(
    `SELECT
       ${USER_RETURN_FIELDS}
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
     RETURNING ${USER_RETURN_FIELDS}`,
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
     RETURNING ${USER_RETURN_FIELDS}`,
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

async function beginStudentVerification({
  userId,
  studentEmail,
  verificationCode,
  expiresAt,
}) {
  const result = await db.query(
    `UPDATE users
     SET
       pending_student_email = $2,
       student_verification_code = $3,
       student_verification_expires_at = $4
     WHERE id = $1
     RETURNING ${USER_RETURN_FIELDS}`,
    [userId, studentEmail, verificationCode, expiresAt],
  );

  return result.rows[0] || null;
}

async function completeStudentVerification({
  userId,
  studentEmail,
  verifiedSchoolName,
}) {
  const result = await db.query(
    `UPDATE users
     SET
       student_email = $2,
       pending_student_email = NULL,
       student_verification_code = NULL,
       student_verification_expires_at = NULL,
       is_student_verified = TRUE,
       verified_school_name = $3,
       student_verified_at = NOW()
     WHERE id = $1
     RETURNING ${USER_RETURN_FIELDS}`,
    [userId, studentEmail, verifiedSchoolName],
  );

  return result.rows[0] || null;
}

module.exports = {
  createUser,
  findUserByEmail,
  findUserById,
  updateDriverProfile,
  updateUserProfile,
  beginStudentVerification,
  completeStudentVerification,
};
