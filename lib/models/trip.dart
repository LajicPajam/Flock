import 'ride_request.dart';

class Trip {
  Trip({
    required this.id,
    required this.driverId,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.seatsAvailable,
    required this.notes,
    required this.driverName,
    required this.driverPhoneNumber,
    required this.driverProfilePhotoUrl,
    required this.driverCarMake,
    required this.driverCarModel,
    required this.driverCarColor,
    required this.driverCarPlateState,
    required this.driverCarPlateNumber,
    required this.driverCarDescription,
    this.viewerRequest,
    this.rideRequests = const [],
  });

  final int id;
  final int driverId;
  final String originCity;
  final String destinationCity;
  final DateTime departureTime;
  final int seatsAvailable;
  final String notes;
  final String driverName;
  final String driverPhoneNumber;
  final String driverProfilePhotoUrl;
  final String driverCarMake;
  final String driverCarModel;
  final String driverCarColor;
  final String driverCarPlateState;
  final String driverCarPlateNumber;
  final String driverCarDescription;
  final RideRequest? viewerRequest;
  final List<RideRequest> rideRequests;

  factory Trip.fromJson(Map<String, dynamic> json) {
    final rawRideRequests = json['ride_requests'] as List<dynamic>? ?? const [];

    return Trip(
      id: json['id'] as int,
      driverId: json['driver_id'] as int,
      originCity: json['origin_city'] as String,
      destinationCity: json['destination_city'] as String,
      departureTime: DateTime.parse(json['departure_time'] as String),
      seatsAvailable: json['seats_available'] as int,
      notes: json['notes'] as String? ?? '',
      driverName: json['driver_name'] as String? ?? 'Driver',
      driverPhoneNumber: json['driver_phone_number'] as String? ?? '',
      driverProfilePhotoUrl: json['driver_profile_photo_url'] as String? ?? '',
      driverCarMake: json['driver_car_make'] as String? ?? '',
      driverCarModel: json['driver_car_model'] as String? ?? '',
      driverCarColor: json['driver_car_color'] as String? ?? '',
      driverCarPlateState: json['driver_car_plate_state'] as String? ?? '',
      driverCarPlateNumber: json['driver_car_plate_number'] as String? ?? '',
      driverCarDescription: json['driver_car_description'] as String? ?? '',
      viewerRequest: json['viewer_request'] == null
          ? null
          : RideRequest.fromJson(
              json['viewer_request'] as Map<String, dynamic>,
            ),
      rideRequests: rawRideRequests
          .map(
            (request) => RideRequest.fromJson(request as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
