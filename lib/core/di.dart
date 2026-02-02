import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/curator_repository_impl.dart';
import '../domain/repositories/curator_repository.dart';
import '../presentation/curator/curator_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<CuratorRepository>(
    () => CuratorRepositoryImpl(client: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<CuratorBloc>(
    () => CuratorBloc(repository: getIt<CuratorRepository>()),
  );
}
