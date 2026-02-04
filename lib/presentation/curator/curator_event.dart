import 'package:equatable/equatable.dart';

abstract class CuratorEvent extends Equatable {
  const CuratorEvent();

  @override
  List<Object?> get props => [];
}

/// User selected photos and requested a recommendation.
class GetRecommendationRequested extends CuratorEvent {
  const GetRecommendationRequested(this.imageBytesList);

  /// Raw bytes of 2–10 selected images (will be resized in repository).
  final List<List<int>> imageBytesList;

  @override
  List<Object?> get props => [imageBytesList];
}

/// User cleared the recommendation to try again.
class CuratorCleared extends CuratorEvent {
  const CuratorCleared();
}
