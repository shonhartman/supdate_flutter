import '../entities/curator_recommendation.dart';

/// Repository for the Photo Curator: sends images to the Edge Function and returns the recommendation.
abstract class CuratorRepository {
  /// Sends [imageBytesList] (2–10 images) to the Curator Edge Function.
  /// Images should already be resized (e.g. max-width 1024px) and encoded as bytes.
  /// Returns the recommendation and the bytes of the recommended image for display.
  Future<CuratorRecommendation> getRecommendation(
    List<List<int>> imageBytesList,
  );
}
