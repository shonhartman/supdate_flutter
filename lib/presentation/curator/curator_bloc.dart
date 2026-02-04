import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/curator_repository_impl.dart';
import '../../domain/repositories/curator_repository.dart';
import 'curator_event.dart';
import 'curator_state.dart';

class CuratorBloc extends Bloc<CuratorEvent, CuratorState> {
  CuratorBloc({required CuratorRepository repository})
    : _repository = repository,
      super(const CuratorInitial()) {
    on<GetRecommendationRequested>(_onGetRecommendationRequested);
    on<CuratorCleared>(_onCuratorCleared);
  }

  final CuratorRepository _repository;

  Future<void> _onGetRecommendationRequested(
    GetRecommendationRequested event,
    Emitter<CuratorState> emit,
  ) async {
    emit(const CuratorLoading());
    try {
      final recommendation = await _repository.getRecommendation(
        event.imageBytesList,
      );
      emit(CuratorReady(recommendation));
    } on CuratorException catch (e) {
      emit(CuratorError(e.message));
    } catch (e) {
      emit(CuratorError(e.toString()));
    }
  }

  void _onCuratorCleared(CuratorCleared event, Emitter<CuratorState> emit) {
    emit(const CuratorInitial());
  }
}
