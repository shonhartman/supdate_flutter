import 'package:equatable/equatable.dart';

import '../../domain/entities/curator_recommendation.dart';

abstract class CuratorState extends Equatable {
  const CuratorState();

  @override
  List<Object?> get props => [];
}

class CuratorInitial extends CuratorState {
  const CuratorInitial();
}

class CuratorLoading extends CuratorState {
  const CuratorLoading();
}

class CuratorReady extends CuratorState {
  const CuratorReady(this.recommendation);

  final CuratorRecommendation recommendation;

  @override
  List<Object?> get props => [recommendation];
}

class CuratorError extends CuratorState {
  const CuratorError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
