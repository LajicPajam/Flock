const CITY_DETAILS = Object.freeze([
  { key: 'NEW_YORK_NY', apiValue: 'new_york_ny', label: 'New York, NY', latitude: 40.7128, longitude: -74.0060 },
  { key: 'LOS_ANGELES_CA', apiValue: 'los_angeles_ca', label: 'Los Angeles, CA', latitude: 34.0522, longitude: -118.2437 },
  { key: 'CHICAGO_IL', apiValue: 'chicago_il', label: 'Chicago, IL', latitude: 41.8781, longitude: -87.6298 },
  { key: 'HOUSTON_TX', apiValue: 'houston_tx', label: 'Houston, TX', latitude: 29.7604, longitude: -95.3698 },
  { key: 'PHOENIX_AZ', apiValue: 'phoenix_az', label: 'Phoenix, AZ', latitude: 33.4484, longitude: -112.0740 },
  { key: 'PHILADELPHIA_PA', apiValue: 'philadelphia_pa', label: 'Philadelphia, PA', latitude: 39.9526, longitude: -75.1652 },
  { key: 'SAN_ANTONIO_TX', apiValue: 'san_antonio_tx', label: 'San Antonio, TX', latitude: 29.4241, longitude: -98.4936 },
  { key: 'SAN_DIEGO_CA', apiValue: 'san_diego_ca', label: 'San Diego, CA', latitude: 32.7157, longitude: -117.1611 },
  { key: 'DALLAS_TX', apiValue: 'dallas_tx', label: 'Dallas, TX', latitude: 32.7767, longitude: -96.7970 },
  { key: 'SAN_JOSE_CA', apiValue: 'san_jose_ca', label: 'San Jose, CA', latitude: 37.3382, longitude: -121.8863 },
  { key: 'AUSTIN_TX', apiValue: 'austin_tx', label: 'Austin, TX', latitude: 30.2672, longitude: -97.7431 },
  { key: 'JACKSONVILLE_FL', apiValue: 'jacksonville_fl', label: 'Jacksonville, FL', latitude: 30.3322, longitude: -81.6557 },
  { key: 'FORT_WORTH_TX', apiValue: 'fort_worth_tx', label: 'Fort Worth, TX', latitude: 32.7555, longitude: -97.3308 },
  { key: 'COLUMBUS_OH', apiValue: 'columbus_oh', label: 'Columbus, OH', latitude: 39.9612, longitude: -82.9988 },
  { key: 'CHARLOTTE_NC', apiValue: 'charlotte_nc', label: 'Charlotte, NC', latitude: 35.2271, longitude: -80.8431 },
  { key: 'INDIANAPOLIS_IN', apiValue: 'indianapolis_in', label: 'Indianapolis, IN', latitude: 39.7684, longitude: -86.1581 },
  { key: 'SEATTLE_WA', apiValue: 'seattle_wa', label: 'Seattle, WA', latitude: 47.6062, longitude: -122.3321 },
  { key: 'DENVER_CO', apiValue: 'denver_co', label: 'Denver, CO', latitude: 39.7392, longitude: -104.9903 },
  { key: 'WASHINGTON_DC', apiValue: 'washington_dc', label: 'Washington, DC', latitude: 38.9072, longitude: -77.0369 },
  { key: 'BOSTON_MA', apiValue: 'boston_ma', label: 'Boston, MA', latitude: 42.3601, longitude: -71.0589 },
  { key: 'NASHVILLE_TN', apiValue: 'nashville_tn', label: 'Nashville, TN', latitude: 36.1627, longitude: -86.7816 },
  { key: 'DETROIT_MI', apiValue: 'detroit_mi', label: 'Detroit, MI', latitude: 42.3314, longitude: -83.0458 },
  { key: 'OKLAHOMA_CITY_OK', apiValue: 'oklahoma_city_ok', label: 'Oklahoma City, OK', latitude: 35.4676, longitude: -97.5164 },
  { key: 'PORTLAND_OR', apiValue: 'portland_or', label: 'Portland, OR', latitude: 45.5152, longitude: -122.6784 },
  { key: 'LAS_VEGAS_NV', apiValue: 'las_vegas_nv', label: 'Las Vegas, NV', latitude: 36.1699, longitude: -115.1398 },
  { key: 'MEMPHIS_TN', apiValue: 'memphis_tn', label: 'Memphis, TN', latitude: 35.1495, longitude: -90.0490 },
  { key: 'LOUISVILLE_KY', apiValue: 'louisville_ky', label: 'Louisville, KY', latitude: 38.2527, longitude: -85.7585 },
  { key: 'BALTIMORE_MD', apiValue: 'baltimore_md', label: 'Baltimore, MD', latitude: 39.2904, longitude: -76.6122 },
  { key: 'MILWAUKEE_WI', apiValue: 'milwaukee_wi', label: 'Milwaukee, WI', latitude: 43.0389, longitude: -87.9065 },
  { key: 'ALBUQUERQUE_NM', apiValue: 'albuquerque_nm', label: 'Albuquerque, NM', latitude: 35.0844, longitude: -106.6504 },
  { key: 'TUCSON_AZ', apiValue: 'tucson_az', label: 'Tucson, AZ', latitude: 32.2226, longitude: -110.9747 },
  { key: 'FRESNO_CA', apiValue: 'fresno_ca', label: 'Fresno, CA', latitude: 36.7378, longitude: -119.7871 },
  { key: 'SACRAMENTO_CA', apiValue: 'sacramento_ca', label: 'Sacramento, CA', latitude: 38.5816, longitude: -121.4944 },
  { key: 'KANSAS_CITY_MO', apiValue: 'kansas_city_mo', label: 'Kansas City, MO', latitude: 39.0997, longitude: -94.5786 },
  { key: 'ATLANTA_GA', apiValue: 'atlanta_ga', label: 'Atlanta, GA', latitude: 33.7490, longitude: -84.3880 },
  { key: 'MIAMI_FL', apiValue: 'miami_fl', label: 'Miami, FL', latitude: 25.7617, longitude: -80.1918 },
  { key: 'MINNEAPOLIS_MN', apiValue: 'minneapolis_mn', label: 'Minneapolis, MN', latitude: 44.9778, longitude: -93.2650 },
  { key: 'NEW_ORLEANS_LA', apiValue: 'new_orleans_la', label: 'New Orleans, LA', latitude: 29.9511, longitude: -90.0715 },
  { key: 'TAMPA_FL', apiValue: 'tampa_fl', label: 'Tampa, FL', latitude: 27.9506, longitude: -82.4572 },
  { key: 'ORLANDO_FL', apiValue: 'orlando_fl', label: 'Orlando, FL', latitude: 28.5383, longitude: -81.3792 },
  { key: 'CLEVELAND_OH', apiValue: 'cleveland_oh', label: 'Cleveland, OH', latitude: 41.4993, longitude: -81.6944 },
  { key: 'CINCINNATI_OH', apiValue: 'cincinnati_oh', label: 'Cincinnati, OH', latitude: 39.1031, longitude: -84.5120 },
  { key: 'PITTSBURGH_PA', apiValue: 'pittsburgh_pa', label: 'Pittsburgh, PA', latitude: 40.4406, longitude: -79.9959 },
  { key: 'ST_LOUIS_MO', apiValue: 'st_louis_mo', label: 'St. Louis, MO', latitude: 38.6270, longitude: -90.1994 },
  { key: 'BOISE_ID', apiValue: 'boise_id', label: 'Boise, ID', latitude: 43.6150, longitude: -116.2023 },
  { key: 'OMAHA_NE', apiValue: 'omaha_ne', label: 'Omaha, NE', latitude: 41.2565, longitude: -95.9345 },
  { key: 'RALEIGH_NC', apiValue: 'raleigh_nc', label: 'Raleigh, NC', latitude: 35.7796, longitude: -78.6382 },
  { key: 'PROVO_UT', apiValue: 'provo_ut', label: 'Provo, UT', latitude: 40.2338, longitude: -111.6585 },
  { key: 'LOGAN_UT', apiValue: 'logan_ut', label: 'Logan, UT', latitude: 41.7369, longitude: -111.8338 },
  { key: 'SALT_LAKE_CITY_UT', apiValue: 'salt_lake_city_ut', label: 'Salt Lake City, UT', latitude: 40.7608, longitude: -111.8910 },
  { key: 'REXBURG_ID', apiValue: 'rexburg_id', label: 'Rexburg, ID', latitude: 43.8260, longitude: -111.7897 },
  { key: 'TEMPE_AZ', apiValue: 'tempe_az', label: 'Tempe, AZ', latitude: 33.4255, longitude: -111.9400 },
]);

const CITY_ENUM = Object.freeze(
  Object.fromEntries(CITY_DETAILS.map((city) => [city.key, city.apiValue])),
);

const SUPPORTED_CITIES = Object.freeze(
  CITY_DETAILS.map((city) => city.apiValue),
);

const TRIP_CITIES = Object.freeze([
  'provo_ut',
  'logan_ut',
  'salt_lake_city_ut',
  'rexburg_id',
  'tempe_az',
]);

function isValidTripCity(city) {
  return TRIP_CITIES.includes(city);
}

const CITY_LOOKUP = Object.freeze(
  Object.fromEntries(CITY_DETAILS.map((city) => [city.apiValue, city])),
);

function isValidCity(city) {
  return SUPPORTED_CITIES.includes(city);
}

function getCityByValue(city) {
  return CITY_LOOKUP[city] || null;
}

module.exports = {
  CITY_DETAILS,
  CITY_ENUM,
  SUPPORTED_CITIES,
  TRIP_CITIES,
  CITY_LOOKUP,
  isValidCity,
  isValidTripCity,
  getCityByValue,
};
