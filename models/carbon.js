const db = require('../db');
const { getCityByValue } = require('./cities');

const CO2_GRAMS_PER_KM = 110;
const EARTH_RADIUS_KM = 6371;
const DRIVING_DISTANCE_MULTIPLIER = 1.18;

function toRadians(degrees) {
  return (degrees * Math.PI) / 180;
}

function getDistanceKm(origin, destination) {
  if (origin === destination) {
    return 0;
  }

  const from = getCityByValue(origin);
  const to = getCityByValue(destination);

  if (!from || !to) {
    return 0;
  }

  const latitudeDelta = toRadians(to.latitude - from.latitude);
  const longitudeDelta = toRadians(to.longitude - from.longitude);
  const fromLatitude = toRadians(from.latitude);
  const toLatitude = toRadians(to.latitude);

  const haversine =
    Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(fromLatitude) *
      Math.cos(toLatitude) *
      Math.sin(longitudeDelta / 2) ** 2;

  const straightLineKm =
    2 * EARTH_RADIUS_KM * Math.atan2(Math.sqrt(haversine), Math.sqrt(1 - haversine));

  return Math.round(straightLineKm * DRIVING_DISTANCE_MULTIPLIER);
}

/**
 * Returns { total_co2_saved_grams, total_distance_km, completed_rides }
 * for a single user. Counts both rides as an accepted rider and trips
 * driven with at least one accepted rider, where departure_time is past.
 */
async function getCarbonSavedForUser(userId) {
  const riderResult = await db.query(
    `SELECT t.origin_city, t.destination_city
     FROM ride_requests rr
     JOIN trips t ON rr.trip_id = t.id
     WHERE rr.rider_id = $1 AND rr.status = 'accepted'
       AND (t.status = 'completed' OR t.departure_time < NOW())`,
    [userId],
  );

  const driverResult = await db.query(
    `SELECT t.origin_city, t.destination_city
     FROM trips t
     WHERE t.driver_id = $1
       AND (t.status = 'completed' OR t.departure_time < NOW())
       AND EXISTS (
         SELECT 1 FROM ride_requests rr
         WHERE rr.trip_id = t.id AND rr.status = 'accepted'
       )`,
    [userId],
  );

  const allRides = [...riderResult.rows, ...driverResult.rows];
  let totalCO2Grams = 0;
  let totalDistanceKm = 0;

  for (const ride of allRides) {
    const distance = getDistanceKm(ride.origin_city, ride.destination_city);
    totalDistanceKm += distance;
    totalCO2Grams += distance * CO2_GRAMS_PER_KM;
  }

  return {
    total_co2_saved_grams: totalCO2Grams,
    total_distance_km: totalDistanceKm,
    completed_rides: allRides.length,
  };
}

/**
 * Batch-compute carbon saved for an array of user IDs.
 * Returns { [userId]: gramsOfCO2Saved }.
 */
async function getCarbonSavedForUsers(userIds) {
  if (userIds.length === 0) return {};

  const riderResult = await db.query(
    `SELECT rr.rider_id AS user_id, t.origin_city, t.destination_city
     FROM ride_requests rr
     JOIN trips t ON rr.trip_id = t.id
     WHERE rr.rider_id = ANY($1) AND rr.status = 'accepted'
       AND (t.status = 'completed' OR t.departure_time < NOW())`,
    [userIds],
  );

  const driverResult = await db.query(
    `SELECT t.driver_id AS user_id, t.origin_city, t.destination_city
     FROM trips t
     WHERE t.driver_id = ANY($1)
       AND (t.status = 'completed' OR t.departure_time < NOW())
       AND EXISTS (
         SELECT 1 FROM ride_requests rr
         WHERE rr.trip_id = t.id AND rr.status = 'accepted'
       )`,
    [userIds],
  );

  const result = {};
  for (const uid of userIds) {
    result[uid] = 0;
  }

  for (const row of [...riderResult.rows, ...driverResult.rows]) {
    const distance = getDistanceKm(row.origin_city, row.destination_city);
    result[row.user_id] = (result[row.user_id] || 0) + distance * CO2_GRAMS_PER_KM;
  }

  return result;
}

/**
 * Returns app-wide totals:
 * { total_co2_saved_grams, total_distance_km, completed_rides }
 */
async function getOverallCarbonStats() {
  const riderResult = await db.query(
    `SELECT t.origin_city, t.destination_city
     FROM ride_requests rr
     JOIN trips t ON rr.trip_id = t.id
     WHERE rr.status = 'accepted'
       AND (t.status = 'completed' OR t.departure_time < NOW())`,
  );

  const driverResult = await db.query(
    `SELECT t.origin_city, t.destination_city
     FROM trips t
     WHERE (t.status = 'completed' OR t.departure_time < NOW())
       AND EXISTS (
         SELECT 1 FROM ride_requests rr
         WHERE rr.trip_id = t.id AND rr.status = 'accepted'
       )`,
  );

  const allRides = [...riderResult.rows, ...driverResult.rows];
  let totalCO2Grams = 0;
  let totalDistanceKm = 0;

  for (const ride of allRides) {
    const distance = getDistanceKm(ride.origin_city, ride.destination_city);
    totalDistanceKm += distance;
    totalCO2Grams += distance * CO2_GRAMS_PER_KM;
  }

  return {
    total_co2_saved_grams: totalCO2Grams,
    total_distance_km: totalDistanceKm,
    completed_rides: allRides.length,
  };
}

module.exports = {
  getDistanceKm,
  getCarbonSavedForUser,
  getCarbonSavedForUsers,
  getOverallCarbonStats,
  CO2_GRAMS_PER_KM,
};
