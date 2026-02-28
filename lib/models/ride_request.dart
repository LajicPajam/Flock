class RideRequest {
  RideRequest({
    required this.id,
    required this.tripId,
    required this.riderId,
    required this.message,
    required this.status,
    this.riderName,
  });

  final int id;
  final int tripId;
  final int riderId;
  final String message;
  final String status;
  final String? riderName;

  bool get isAccepted => status == 'accepted';

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'] as int,
      tripId: json['trip_id'] as int,
      riderId: json['rider_id'] as int,
      message: json['message'] as String,
      status: json['status'] as String,
      riderName: json['rider_name'] as String?,
    );
  }
}
