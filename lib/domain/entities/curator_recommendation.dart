/// Result from the AI Curator: which photo was recommended plus caption and vibe.
class CuratorRecommendation {
  const CuratorRecommendation({
    required this.recommendedIndex,
    required this.caption,
    required this.vibe,
    required this.recommendedImageBytes,
  });

  /// Zero-based index into the original list of photos.
  final int recommendedIndex;

  /// AI-generated caption for the post.
  final String caption;

  /// AI-generated vibe/mood.
  final String vibe;

  /// The selected image bytes (from the original selection) for display.
  final List<int> recommendedImageBytes;
}
