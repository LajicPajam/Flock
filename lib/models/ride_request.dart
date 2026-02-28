class RideRequest {
  RideRequest({
    required this.id,
    required this.tripId,
    required this.riderId,
    required this.message,
    required this.status,
    this.riderName,
    this.riderMajor,
    this.riderAcademicYear,
    this.riderVibe,
    this.riderFavoritePlaylist,
    this.riderAverageRating,
  });

  final int id;
  final int tripId;
  final int riderId;
  final String message;
  final String status;
  final String? riderName;
  final String? riderMajor;
  final String? riderAcademicYear;
  final String? riderVibe;
  final String? riderFavoritePlaylist;
  final double? riderAverageRating;

  bool get isAccepted => status == 'accepted';

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'] as int,
      tripId: json['trip_id'] as int,
      riderId: json['rider_id'] as int,
      message: json['message'] as String,
      status: json['status'] as String,
      riderName: json['rider_name'] as String?,
      riderMajor: json['rider_major'] as String?,
      riderAcademicYear: json['rider_academic_year'] as String?,
      riderVibe: json['rider_vibe'] as String?,
      riderFavoritePlaylist: json['rider_favorite_playlist'] as String?,
      riderAverageRating:
          double.tryParse('${json['rider_average_rating'] ?? ''}'),
    );
  }
}
