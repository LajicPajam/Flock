import 'package:flutter/material.dart';

import '../models/carbon_stats.dart';

class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.carbonSavedGrams});

  final int carbonSavedGrams;

  @override
  Widget build(BuildContext context) {
    if (carbonSavedGrams <= 0) return const SizedBox.shrink();

    final tl = CarbonTierLevel.fromGrams(carbonSavedGrams);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tl.tier.uiColor,
        borderRadius: BorderRadius.circular(12),
        border: tl.tier == CarbonTier.cloud
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
      child: Text(
        '${tl.tier.emoji} ${tl.label}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: tl.tier.textColor,
        ),
      ),
    );
  }
}
