class AppCarbonOverview {
  AppCarbonOverview({
    required this.totalCo2SavedGrams,
    required this.totalDistanceKm,
    required this.completedRides,
  });

  final int totalCo2SavedGrams;
  final int totalDistanceKm;
  final int completedRides;

  factory AppCarbonOverview.fromJson(Map<String, dynamic> json) {
    return AppCarbonOverview(
      totalCo2SavedGrams: json['total_co2_saved_grams'] as int? ?? 0,
      totalDistanceKm: json['total_distance_km'] as int? ?? 0,
      completedRides: json['completed_rides'] as int? ?? 0,
    );
  }
}
