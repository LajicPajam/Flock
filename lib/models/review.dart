class Review {
  Review({
    required this.id,
    required this.tripId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.reviewerName,
    required this.createdAt,
  });

  final int id;
  final int tripId;
  final int reviewerId;
  final int revieweeId;
  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      tripId: json['trip_id'] as int,
      reviewerId: json['reviewer_id'] as int,
      revieweeId: json['reviewee_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      reviewerName: json['reviewer_name'] as String? ?? 'User',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
