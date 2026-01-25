/// Dependency Injection Setup with GetIt
library;

import 'package:get_it/get_it.dart';
import '../network/pb_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt.registerLazySingleton<PBClient>(() => PBClient.instance);

  // Initialize PocketBase auth
  await getIt<PBClient>().initAuth();

  // TODO: Register repositories
  // TODO: Register use cases
  // TODO: Register blocs
}
