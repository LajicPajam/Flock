import 'package:flutter/material.dart';

import '../models/carbon_stats.dart';

class CarbonProgressBar extends StatelessWidget {
  const CarbonProgressBar({super.key, required this.stats});

  final CarbonStats stats;

  @override
  Widget build(BuildContext context) {
    final tl = stats.tierLevel;
    final progress = tl.progressInTier(stats.totalCo2SavedGrams);
    final markers = tl.levelMarkerFractions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tl.badgeLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${(stats.totalCo2SavedGrams / 1000).toStringAsFixed(1)} kg CO₂ saved',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 28,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    width: width * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tl.tier.barColor,
                          tl.tier.barColor.withAlpha(200),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: tl.tier.barColor.withAlpha(80),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  for (int i = 1; i < markers.length; i++)
                    Positioned(
                      left: width * markers[i] - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        _buildLevelLabels(context, tl),
        const SizedBox(height: 14),
        _TangibleCard(grams: stats.totalCo2SavedGrams),
      ],
    );
  }

  Widget _buildLevelLabels(BuildContext context, CarbonTierLevel tl) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey.shade600,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${tl.tier.label} I', style: style),
        Text('${tl.tier.label} II', style: style),
        Text('${tl.tier.label} III', style: style),
      ],
    );
  }
}

class _TangibleCard extends StatelessWidget {
  const _TangibleCard({required this.grams});

  final int grams;

  @override
  Widget build(BuildContext context) {
    final translation = TangibleTranslation.forGrams(grams);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8F3DC)),
      ),
      child: Row(
        children: [
          Icon(translation.icon, size: 28, color: const Color(0xFF2D6A4F)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              translation.text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
