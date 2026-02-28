const db = require('../db');

// Approximate driving distances in km between supported city pairs
const CITY_DISTANCES_KM = {
  'provo_ut:logan_ut': 217,
  'provo_ut:salt_lake_city_ut': 72,
  'provo_ut:rexburg_id': 443,
  'provo_ut:tempe_az': 1062,
  'logan_ut:salt_lake_city_ut': 132,
  'logan_ut:rexburg_id': 257,
  'logan_ut:tempe_az': 1255,
  'salt_lake_city_ut:rexburg_id': 346,
  'salt_lake_city_ut:tempe_az': 1014,
  'rexburg_id:tempe_az': 1400,
};

const CO2_GRAMS_PER_KM = 110;

function getDistanceKm(origin, destination) {
  return (
    CITY_DISTANCES_KM[`${origin}:${destination}`] ||
    CITY_DISTANCES_KM[`${destination}:${origin}`] ||
    0
  );
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
     WHERE rr.rider_id = $1 AND rr.status = 'accepted' AND t.departure_time < NOW()`,
    [userId],
  );

  const driverResult = await db.query(
    `SELECT t.origin_city, t.destination_city
     FROM trips t
     WHERE t.driver_id = $1 AND t.departure_time < NOW()
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
     WHERE rr.rider_id = ANY($1) AND rr.status = 'accepted' AND t.departure_time < NOW()`,
    [userIds],
  );

  const driverResult = await db.query(
    `SELECT t.driver_id AS user_id, t.origin_city, t.destination_city
     FROM trips t
     WHERE t.driver_id = ANY($1) AND t.departure_time < NOW()
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

module.exports = {
  getDistanceKm,
  getCarbonSavedForUser,
  getCarbonSavedForUsers,
  CO2_GRAMS_PER_KM,
};
