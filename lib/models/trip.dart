import 'city.dart';
import 'ride_request.dart';

String formatDepartureTime(DateTime dt) {
  final local = dt.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${months[local.month - 1]} ${local.day} at $hour:$minute $period';
}

class Trip {
  Trip({
    required this.id,
    required this.driverId,
    required this.originCity,
    required this.destinationCity,
    this.originLabel,
    this.destinationLabel,
    this.originLatitude,
    this.originLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    required this.departureTime,
    required this.seatsAvailable,
    required this.status,
    required this.meetingSpot,
    this.eventCategory,
    this.eventName,
    required this.notes,
    required this.driverName,
    required this.driverPhoneNumber,
    required this.driverProfilePhotoUrl,
    this.driverGender,
    required this.driverIsStudentVerified,
    this.driverVerifiedSchoolName,
    required this.driverCarMake,
    required this.driverCarModel,
    required this.driverCarColor,
    required this.driverCarPlateState,
    required this.driverCarPlateNumber,
    required this.driverCarDescription,
    this.driverCarbonSavedGrams = 0,
    required this.driverAverageRating,
    required this.driverReviewCount,
    this.viewerRequest,
    this.rideRequests = const [],
  });

  final int id;
  final int driverId;
  final String originCity;
  final String destinationCity;
  final String? originLabel;
  final String? destinationLabel;
  final double? originLatitude;
  final double? originLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final DateTime departureTime;
  final int seatsAvailable;
  final String status;
  final String meetingSpot;
  final String? eventCategory;
  final String? eventName;
  final String notes;
  final String driverName;
  final String driverPhoneNumber;
  final String driverProfilePhotoUrl;
  final String? driverGender;
  final bool driverIsStudentVerified;
  final String? driverVerifiedSchoolName;
  final String driverCarMake;
  final String driverCarModel;
  final String driverCarColor;
  final String driverCarPlateState;
  final String driverCarPlateNumber;
  final String driverCarDescription;
  final int driverCarbonSavedGrams;
  final double driverAverageRating;
  final int driverReviewCount;
  final RideRequest? viewerRequest;
  final List<RideRequest> rideRequests;

  bool get isFull => status == 'full' || seatsAvailable <= 0;
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get hasEvent =>
      (eventName != null && eventName!.trim().isNotEmpty) ||
      (eventCategory != null && eventCategory!.trim().isNotEmpty);
  String get originDisplayLabel =>
      (originLabel != null && originLabel!.trim().isNotEmpty)
      ? originLabel!
      : CollegeCity.labelForApiValue(originCity);
  String get destinationDisplayLabel =>
      (destinationLabel != null && destinationLabel!.trim().isNotEmpty)
      ? destinationLabel!
      : CollegeCity.labelForApiValue(destinationCity);
  bool get isHistory =>
      isCancelled ||
      isCompleted ||
      departureTime.toLocal().isBefore(DateTime.now());

  factory Trip.fromJson(Map<String, dynamic> json) {
    final rawRideRequests = json['ride_requests'] as List<dynamic>? ?? const [];

    return Trip(
      id: json['id'] as int,
      driverId: json['driver_id'] as int,
      originCity: json['origin_city'] as String,
      destinationCity: json['destination_city'] as String,
      originLabel: json['origin_label'] as String?,
      destinationLabel: json['destination_label'] as String?,
      originLatitude: (json['origin_latitude'] as num?)?.toDouble(),
      originLongitude: (json['origin_longitude'] as num?)?.toDouble(),
      destinationLatitude: (json['destination_latitude'] as num?)?.toDouble(),
      destinationLongitude: (json['destination_longitude'] as num?)?.toDouble(),
      departureTime: DateTime.parse(json['departure_time'] as String),
      seatsAvailable: json['seats_available'] as int,
      status: json['status'] as String? ?? 'open',
      meetingSpot: json['meeting_spot'] as String? ?? '',
      eventCategory: json['event_category'] as String?,
      eventName: json['event_name'] as String?,
      notes: json['notes'] as String? ?? '',
      driverName: json['driver_name'] as String? ?? 'Driver',
      driverPhoneNumber: json['driver_phone_number'] as String? ?? '',
      driverProfilePhotoUrl: json['driver_profile_photo_url'] as String? ?? '',
      driverGender: json['driver_gender'] as String?,
      driverIsStudentVerified:
          json['driver_is_student_verified'] as bool? ?? false,
      driverVerifiedSchoolName: json['driver_verified_school_name'] as String?,
      driverCarMake: json['driver_car_make'] as String? ?? '',
      driverCarModel: json['driver_car_model'] as String? ?? '',
      driverCarColor: json['driver_car_color'] as String? ?? '',
      driverCarPlateState: json['driver_car_plate_state'] as String? ?? '',
      driverCarPlateNumber: json['driver_car_plate_number'] as String? ?? '',
      driverCarDescription: json['driver_car_description'] as String? ?? '',
      driverCarbonSavedGrams: json['driver_carbon_saved_grams'] as int? ?? 0,
      driverAverageRating:
          (json['driver_average_rating'] as num?)?.toDouble() ?? 0,
      driverReviewCount: json['driver_review_count'] as int? ?? 0,
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
