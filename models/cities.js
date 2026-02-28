const CITY_ENUM = Object.freeze({
  PROVO_UT: 'provo_ut',
  LOGAN_UT: 'logan_ut',
  SALT_LAKE_CITY_UT: 'salt_lake_city_ut',
  REXBURG_ID: 'rexburg_id',
  TEMPE_AZ: 'tempe_az',
});

const SUPPORTED_CITIES = Object.freeze(Object.values(CITY_ENUM));

function isValidCity(city) {
  return SUPPORTED_CITIES.includes(city);
}

module.exports = {
  CITY_ENUM,
  SUPPORTED_CITIES,
  isValidCity,
};
