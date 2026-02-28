import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api.dart';
import '../state/app_state.dart';
import 'ui_shell.dart';

class UserReviewsScreen extends StatelessWidget {
  const UserReviewsScreen({
    super.key,
    required this.userId,
    required this.title,
  });

  final int userId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return UiShell(
      title: title,
      child: FutureBuilder<UserReviewsResult>(
        future: context.read<AppState>().loadUserReviews(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
              ],
            );
          }

          final data = snapshot.data!;
          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.reviewCount == 0
                            ? 'No reviews yet'
                            : '${data.averageRating.toStringAsFixed(1)} / 5 stars from ${data.reviewCount} review${data.reviewCount == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (data.reviewCount > 0) ...[
                        const SizedBox(height: 8),
                        _StarRow(rating: data.averageRating),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (data.reviews.isEmpty)
                const Center(child: Text('No reviews to show.'))
              else
                ...data.reviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _StarRow(rating: review.rating.toDouble()),
                                const SizedBox(width: 8),
                                Text(
                                  '${review.rating} / 5',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text('From: ${review.reviewerName}'),
                            if (review.comment.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(review.comment),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final filledStars = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < filledStars ? Icons.star_rounded : Icons.star_border_rounded,
          size: 18,
          color: const Color(0xFFE0A106),
        );
      }),
    );
  }
}
