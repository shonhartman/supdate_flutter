import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../domain/entities/curator_recommendation.dart';

/// Displays the Curator's recommended photo with caption and vibe in a premium minimalist style.
class RecommendedPhotoCard extends StatelessWidget {
  const RecommendedPhotoCard({
    super.key,
    required this.recommendation,
    this.onTryAgain,
  });

  final CuratorRecommendation recommendation;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 1,
            child: Image.memory(
              Uint8List.fromList(recommendation.recommendedImageBytes),
              fit: BoxFit.cover,
            ),
          ),
          // Caption & vibe — premium minimalist
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recommendation.caption.isNotEmpty) ...[
                  Text(
                    recommendation.caption,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (recommendation.vibe.isNotEmpty)
                  Text(
                    recommendation.vibe,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ),
          if (onTryAgain != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: TextButton(
                onPressed: onTryAgain,
                child: const Text('Try again'),
              ),
            ),
        ],
      ),
    );
  }
}
