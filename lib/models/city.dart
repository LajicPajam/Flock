import 'dart:math' as math;

enum CollegeCity {
  newYorkNy('new_york_ny', 'New York, NY', 40.7128, -74.0060),
  losAngelesCa('los_angeles_ca', 'Los Angeles, CA', 34.0522, -118.2437),
  chicagoIl('chicago_il', 'Chicago, IL', 41.8781, -87.6298),
  houstonTx('houston_tx', 'Houston, TX', 29.7604, -95.3698),
  phoenixAz('phoenix_az', 'Phoenix, AZ', 33.4484, -112.0740),
  philadelphiaPa('philadelphia_pa', 'Philadelphia, PA', 39.9526, -75.1652),
  sanAntonioTx('san_antonio_tx', 'San Antonio, TX', 29.4241, -98.4936),
  sanDiegoCa('san_diego_ca', 'San Diego, CA', 32.7157, -117.1611),
  dallasTx('dallas_tx', 'Dallas, TX', 32.7767, -96.7970),
  sanJoseCa('san_jose_ca', 'San Jose, CA', 37.3382, -121.8863),
  austinTx('austin_tx', 'Austin, TX', 30.2672, -97.7431),
  jacksonvilleFl('jacksonville_fl', 'Jacksonville, FL', 30.3322, -81.6557),
  fortWorthTx('fort_worth_tx', 'Fort Worth, TX', 32.7555, -97.3308),
  columbusOh('columbus_oh', 'Columbus, OH', 39.9612, -82.9988),
  charlotteNc('charlotte_nc', 'Charlotte, NC', 35.2271, -80.8431),
  indianapolisIn('indianapolis_in', 'Indianapolis, IN', 39.7684, -86.1581),
  seattleWa('seattle_wa', 'Seattle, WA', 47.6062, -122.3321),
  denverCo('denver_co', 'Denver, CO', 39.7392, -104.9903),
  washingtonDc('washington_dc', 'Washington, DC', 38.9072, -77.0369),
  bostonMa('boston_ma', 'Boston, MA', 42.3601, -71.0589),
  nashvilleTn('nashville_tn', 'Nashville, TN', 36.1627, -86.7816),
  detroitMi('detroit_mi', 'Detroit, MI', 42.3314, -83.0458),
  oklahomaCityOk('oklahoma_city_ok', 'Oklahoma City, OK', 35.4676, -97.5164),
  portlandOr('portland_or', 'Portland, OR', 45.5152, -122.6784),
  lasVegasNv('las_vegas_nv', 'Las Vegas, NV', 36.1699, -115.1398),
  memphisTn('memphis_tn', 'Memphis, TN', 35.1495, -90.0490),
  louisvilleKy('louisville_ky', 'Louisville, KY', 38.2527, -85.7585),
  baltimoreMd('baltimore_md', 'Baltimore, MD', 39.2904, -76.6122),
  milwaukeeWi('milwaukee_wi', 'Milwaukee, WI', 43.0389, -87.9065),
  albuquerqueNm('albuquerque_nm', 'Albuquerque, NM', 35.0844, -106.6504),
  tucsonAz('tucson_az', 'Tucson, AZ', 32.2226, -110.9747),
  fresnoCa('fresno_ca', 'Fresno, CA', 36.7378, -119.7871),
  sacramentoCa('sacramento_ca', 'Sacramento, CA', 38.5816, -121.4944),
  kansasCityMo('kansas_city_mo', 'Kansas City, MO', 39.0997, -94.5786),
  atlantaGa('atlanta_ga', 'Atlanta, GA', 33.7490, -84.3880),
  miamiFl('miami_fl', 'Miami, FL', 25.7617, -80.1918),
  minneapolisMn('minneapolis_mn', 'Minneapolis, MN', 44.9778, -93.2650),
  newOrleansLa('new_orleans_la', 'New Orleans, LA', 29.9511, -90.0715),
  tampaFl('tampa_fl', 'Tampa, FL', 27.9506, -82.4572),
  orlandoFl('orlando_fl', 'Orlando, FL', 28.5383, -81.3792),
  clevelandOh('cleveland_oh', 'Cleveland, OH', 41.4993, -81.6944),
  cincinnatiOh('cincinnati_oh', 'Cincinnati, OH', 39.1031, -84.5120),
  pittsburghPa('pittsburgh_pa', 'Pittsburgh, PA', 40.4406, -79.9959),
  stLouisMo('st_louis_mo', 'St. Louis, MO', 38.6270, -90.1994),
  boiseId('boise_id', 'Boise, ID', 43.6150, -116.2023),
  omahaNe('omaha_ne', 'Omaha, NE', 41.2565, -95.9345),
  raleighNc('raleigh_nc', 'Raleigh, NC', 35.7796, -78.6382),
  provoUt('provo_ut', 'Provo, UT', 40.2338, -111.6585),
  loganUt('logan_ut', 'Logan, UT', 41.7369, -111.8338),
  saltLakeCityUt('salt_lake_city_ut', 'Salt Lake City, UT', 40.7608, -111.8910),
  rexburgId('rexburg_id', 'Rexburg, ID', 43.8260, -111.7897),
  tempeAz('tempe_az', 'Tempe, AZ', 33.4255, -111.9400);

  /// Cities supported by Flock for trip origins/destinations.
  static const supportedCities = [
    CollegeCity.provoUt,
    CollegeCity.loganUt,
    CollegeCity.saltLakeCityUt,
    CollegeCity.rexburgId,
    CollegeCity.tempeAz,
  ];

  const CollegeCity(this.apiValue, this.label, this.latitude, this.longitude);

  final String apiValue;
  final String label;
  final double latitude;
  final double longitude;

  static CollegeCity fromApiValue(String value) {
    return CollegeCity.values.firstWhere((city) => city.apiValue == value);
  }

  static String labelForApiValue(String value) {
    return fromApiValue(value).label;
  }

  static CollegeCity nearestTo(double latitude, double longitude) {
    CollegeCity nearest = CollegeCity.values.first;
    double nearestDistance = double.infinity;

    for (final city in CollegeCity.values) {
      final distance = distanceKmBetween(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = city;
      }
    }

    return nearest;
  }

  /// Returns the nearest supported city to the given coordinates.
  static CollegeCity nearestSupportedTo(double latitude, double longitude) {
    CollegeCity nearest = supportedCities.first;
    double nearestDistance = double.infinity;

    for (final city in supportedCities) {
      final distance = distanceKmBetween(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = city;
      }
    }

    return nearest;
  }

  static double distanceKmBetween(
    double fromLatitude,
    double fromLongitude,
    double toLatitude,
    double toLongitude,
  ) {
    const earthRadiusKm = 6371.0;
    final latitudeDelta = _toRadians(toLatitude - fromLatitude);
    final longitudeDelta = _toRadians(toLongitude - fromLongitude);
    final fromLatitudeRad = _toRadians(fromLatitude);
    final toLatitudeRad = _toRadians(toLatitude);

    final latitudeTerm = math.sin(latitudeDelta / 2);
    final longitudeTerm = math.sin(longitudeDelta / 2);
    final haversine =
        (latitudeTerm * latitudeTerm) +
        math.cos(fromLatitudeRad) *
            math.cos(toLatitudeRad) *
            (longitudeTerm * longitudeTerm);

    final arc = 2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));

    return earthRadiusKm * arc;
  }

  static double distanceKmToSegment({
    required double pointLatitude,
    required double pointLongitude,
    required double segmentStartLatitude,
    required double segmentStartLongitude,
    required double segmentEndLatitude,
    required double segmentEndLongitude,
  }) {
    final projection = _projectOntoSegment(
      pointLatitude: pointLatitude,
      pointLongitude: pointLongitude,
      segmentStartLatitude: segmentStartLatitude,
      segmentStartLongitude: segmentStartLongitude,
      segmentEndLatitude: segmentEndLatitude,
      segmentEndLongitude: segmentEndLongitude,
    );
    return projection.distanceKm;
  }

  static double segmentFractionForPoint({
    required double pointLatitude,
    required double pointLongitude,
    required double segmentStartLatitude,
    required double segmentStartLongitude,
    required double segmentEndLatitude,
    required double segmentEndLongitude,
  }) {
    final projection = _projectOntoSegment(
      pointLatitude: pointLatitude,
      pointLongitude: pointLongitude,
      segmentStartLatitude: segmentStartLatitude,
      segmentStartLongitude: segmentStartLongitude,
      segmentEndLatitude: segmentEndLatitude,
      segmentEndLongitude: segmentEndLongitude,
    );
    return projection.fraction;
  }

  static _SegmentProjection _projectOntoSegment({
    required double pointLatitude,
    required double pointLongitude,
    required double segmentStartLatitude,
    required double segmentStartLongitude,
    required double segmentEndLatitude,
    required double segmentEndLongitude,
  }) {
    final originLatitude = (segmentStartLatitude + segmentEndLatitude) / 2;
    final originLongitude = (segmentStartLongitude + segmentEndLongitude) / 2;

    final point = _toPlanarKm(
      latitude: pointLatitude,
      longitude: pointLongitude,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
    );
    final start = _toPlanarKm(
      latitude: segmentStartLatitude,
      longitude: segmentStartLongitude,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
    );
    final end = _toPlanarKm(
      latitude: segmentEndLatitude,
      longitude: segmentEndLongitude,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
    );

    final segmentX = end.x - start.x;
    final segmentY = end.y - start.y;
    final segmentLengthSquared = (segmentX * segmentX) + (segmentY * segmentY);

    if (segmentLengthSquared == 0) {
      final distance = math.sqrt(
        math.pow(point.x - start.x, 2) + math.pow(point.y - start.y, 2),
      );
      return _SegmentProjection(distanceKm: distance, fraction: 0);
    }

    final rawFraction =
        (((point.x - start.x) * segmentX) + ((point.y - start.y) * segmentY)) /
        segmentLengthSquared;
    final clampedFraction = rawFraction.clamp(0.0, 1.0);
    final projectedX = start.x + (segmentX * clampedFraction);
    final projectedY = start.y + (segmentY * clampedFraction);
    final distance = math.sqrt(
      math.pow(point.x - projectedX, 2) + math.pow(point.y - projectedY, 2),
    );

    return _SegmentProjection(
      distanceKm: distance,
      fraction: rawFraction.clamp(0.0, 1.0),
    );
  }

  static _PlanarPoint _toPlanarKm({
    required double latitude,
    required double longitude,
    required double originLatitude,
    required double originLongitude,
  }) {
    const kmPerDegreeLatitude = 111.32;
    final kmPerDegreeLongitude =
        111.32 * math.cos(_toRadians(originLatitude)).abs();

    return _PlanarPoint(
      x: (longitude - originLongitude) * kmPerDegreeLongitude,
      y: (latitude - originLatitude) * kmPerDegreeLatitude,
    );
  }

  static double _toRadians(double degrees) => degrees * (math.pi / 180);
}

class _PlanarPoint {
  const _PlanarPoint({required this.x, required this.y});

  final double x;
  final double y;
}

class _SegmentProjection {
  const _SegmentProjection({required this.distanceKm, required this.fraction});

  final double distanceKm;
  final double fraction;
}

class LocationSelection {
  const LocationSelection({
    required this.city,
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final CollegeCity city;
  final String label;
  final double latitude;
  final double longitude;

  String get apiValue => city.apiValue;

  factory LocationSelection.fromCity(CollegeCity city) {
    return LocationSelection(
      city: city,
      label: city.label,
      latitude: city.latitude,
      longitude: city.longitude,
    );
  }
}
