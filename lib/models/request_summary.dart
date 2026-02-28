class RequestSummary {
  RequestSummary({
    required this.requestId,
    required this.tripId,
    required this.status,
    required this.message,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.tripStatus,
    this.meetingSpot,
    this.driverId,
    this.riderId,
    this.driverName,
    this.riderName,
    this.seatsAvailable,
    this.driverAverageRating = 0,
    this.driverReviewCount = 0,
  });

  final int requestId;
  final int tripId;
  final String status;
  final String message;
  final String originCity;
  final String destinationCity;
  final DateTime departureTime;
  final String tripStatus;
  final String? meetingSpot;
  final int? driverId;
  final int? riderId;
  final String? driverName;
  final String? riderName;
  final int? seatsAvailable;
  final double driverAverageRating;
  final int driverReviewCount;

  bool get tripIsCancelled => tripStatus == 'cancelled';
  bool get tripIsCompleted => tripStatus == 'completed';
  bool get isHistory =>
      tripIsCancelled ||
      tripIsCompleted ||
      departureTime.toLocal().isBefore(DateTime.now());

  factory RequestSummary.fromJson(Map<String, dynamic> json) {
    return RequestSummary(
      requestId: (json['request_id'] ?? json['id']) as int,
      tripId: json['trip_id'] as int,
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
      originCity: json['origin_city'] as String,
      destinationCity: json['destination_city'] as String,
      departureTime: DateTime.parse(json['departure_time'] as String),
      tripStatus: json['trip_status'] as String? ?? 'open',
      meetingSpot: json['meeting_spot'] as String?,
      driverId: json['driver_id'] as int?,
      riderId: json['rider_id'] as int?,
      driverName: json['driver_name'] as String?,
      riderName: json['rider_name'] as String?,
      seatsAvailable: json['seats_available'] as int?,
      driverAverageRating:
          (json['driver_average_rating'] as num?)?.toDouble() ?? 0,
      driverReviewCount: json['driver_review_count'] as int? ?? 0,
    );
  }
}
