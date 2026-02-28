enum CollegeCity {
  provoUt('provo_ut', 'Provo, UT (BYU)'),
  loganUt('logan_ut', 'Logan, UT (USU)'),
  saltLakeCityUt('salt_lake_city_ut', 'Salt Lake City, UT (University of Utah)'),
  rexburgId('rexburg_id', 'Rexburg, ID (BYU-Idaho)'),
  tempeAz('tempe_az', 'Tempe, AZ (ASU)');

  const CollegeCity(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static CollegeCity fromApiValue(String value) {
    return CollegeCity.values.firstWhere((city) => city.apiValue == value);
  }
}
