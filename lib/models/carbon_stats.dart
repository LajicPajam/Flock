import 'package:flutter/material.dart';

class CarbonStats {
  CarbonStats({
    required this.totalCo2SavedGrams,
    required this.totalDistanceKm,
    required this.completedRides,
  });

  final int totalCo2SavedGrams;
  final int totalDistanceKm;
  final int completedRides;

  factory CarbonStats.fromJson(Map<String, dynamic> json) {
    return CarbonStats(
      totalCo2SavedGrams: json['total_co2_saved_grams'] as int? ?? 0,
      totalDistanceKm: json['total_distance_km'] as int? ?? 0,
      completedRides: json['completed_rides'] as int? ?? 0,
    );
  }

  CarbonTierLevel get tierLevel => CarbonTierLevel.fromGrams(totalCo2SavedGrams);
}

enum CarbonTier {
  cloud('Cloud', Color(0xFFA0A0A0), Color(0xFFF7F9F8), '☁️'),
  sage('Sage', Color(0xFF6BBF7B), Color(0xFFD8F3DC), '🌿'),
  evergreen('Evergreen', Color(0xFF2D6A4F), Color(0xFF2D6A4F), '🌲'),
  azure('Azure', Color(0xFF3A86FF), Color(0xFF3A86FF), '⚡');

  const CarbonTier(this.label, this.barColor, this.uiColor, this.emoji);

  final String label;
  final Color barColor;
  final Color uiColor;
  final String emoji;

  Color get textColor {
    switch (this) {
      case CarbonTier.cloud:
      case CarbonTier.sage:
        return const Color(0xFF1E1E24);
      case CarbonTier.evergreen:
      case CarbonTier.azure:
        return Colors.white;
    }
  }
}

class CarbonTierLevel {
  const CarbonTierLevel({required this.tier, required this.level});

  final CarbonTier tier;
  final int level; // 1, 2, or 3

  String get label => '${tier.label} ${'I' * level}';
  String get badgeLabel => '${tier.emoji} ${tier.label} ${'I' * level}';

  static const _thresholds = [
    (CarbonTier.cloud, 1, 0),
    (CarbonTier.cloud, 2, 834),
    (CarbonTier.cloud, 3, 1667),
    (CarbonTier.sage, 1, 2500),
    (CarbonTier.sage, 2, 9000),
    (CarbonTier.sage, 3, 15500),
    (CarbonTier.evergreen, 1, 22000),
    (CarbonTier.evergreen, 2, 68000),
    (CarbonTier.evergreen, 3, 114000),
    (CarbonTier.azure, 1, 160000),
    (CarbonTier.azure, 2, 240000),
    (CarbonTier.azure, 3, 320000),
  ];

  static CarbonTierLevel fromGrams(int grams) {
    var tier = CarbonTier.cloud;
    var level = 1;
    for (final (t, l, threshold) in _thresholds) {
      if (grams >= threshold) {
        tier = t;
        level = l;
      } else {
        break;
      }
    }
    return CarbonTierLevel(tier: tier, level: level);
  }

  /// Start of the current tier (grams).
  int get tierStartGrams {
    for (final (t, l, threshold) in _thresholds) {
      if (t == tier && l == 1) return threshold;
    }
    return 0;
  }

  /// Start of the next tier (grams), or cap for Azure.
  int get tierEndGrams {
    final tierIndex = CarbonTier.values.indexOf(tier);
    if (tierIndex < CarbonTier.values.length - 1) {
      final nextTier = CarbonTier.values[tierIndex + 1];
      for (final (t, l, threshold) in _thresholds) {
        if (t == nextTier && l == 1) return threshold;
      }
    }
    return 400000;
  }

  /// Fractional progress within the current tier (0.0 to 1.0).
  double progressInTier(int grams) {
    final range = tierEndGrams - tierStartGrams;
    if (range <= 0) return 1.0;
    return ((grams - tierStartGrams) / range).clamp(0.0, 1.0);
  }

  /// Thresholds for level 1, 2, 3 within the current tier, as fractions.
  List<double> get levelMarkerFractions {
    final range = tierEndGrams - tierStartGrams;
    if (range <= 0) return [0, 0.33, 0.67];
    final markers = <double>[];
    for (final (t, _, threshold) in _thresholds) {
      if (t == tier) {
        markers.add((threshold - tierStartGrams) / range);
      }
    }
    return markers;
  }
}

/// Human-friendly equivalents for a given CO2 amount.
class TangibleTranslation {
  TangibleTranslation({required this.text, required this.icon});

  final String text;
  final IconData icon;

  static TangibleTranslation forGrams(int grams) {
    final kg = grams / 1000;

    if (kg < 1) {
      final charges = (grams / 8).round();
      return TangibleTranslation(
        text: "You've saved ${grams}g of CO₂! That's like "
            'charging your phone $charges times.',
        icon: Icons.smartphone,
      );
    }
    if (kg < 5) {
      final bottles = (grams / 83).round();
      return TangibleTranslation(
        text: "You've saved ${kg.toStringAsFixed(1)}kg of CO₂! "
            "That's equal to skipping $bottles single-use plastic bottles.",
        icon: Icons.water_drop_outlined,
      );
    }
    if (kg < 22) {
      final charges = (grams / 8).round();
      return TangibleTranslation(
        text: "You've saved ${kg.toStringAsFixed(1)}kg of CO₂! "
            "That's equal to charging your smartphone "
            '${_formatNumber(charges)} times.',
        icon: Icons.battery_charging_full,
      );
    }
    if (kg < 100) {
      final trees = (kg / 22).toStringAsFixed(1);
      return TangibleTranslation(
        text: "You've saved ${kg.toStringAsFixed(0)}kg of CO₂! "
            "That's equal to $trees trees absorbing carbon for a full year.",
        icon: Icons.park,
      );
    }
    if (kg < 450) {
      final days = (kg / 14.9).round();
      return TangibleTranslation(
        text: "You've saved ${kg.toStringAsFixed(0)}kg of CO₂! "
            "That's like keeping a gas car off the road for $days days.",
        icon: Icons.directions_car_outlined,
      );
    }
    final months = (kg / 453).toStringAsFixed(1);
    return TangibleTranslation(
      text: "You've saved ${kg.toStringAsFixed(0)}kg of CO₂! "
          "That's equal to keeping a gas car parked for $months months.",
      icon: Icons.eco,
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}
