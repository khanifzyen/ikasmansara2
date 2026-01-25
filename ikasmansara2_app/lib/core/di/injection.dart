/// Dependency Injection Setup with GetIt
library;

import 'package:get_it/get_it.dart';
import '../network/pb_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/donations/data/datasources/donation_remote_data_source.dart';
import '../../features/donations/data/repositories/donation_repository_impl.dart';
import '../../features/donations/domain/repositories/donation_repository.dart';
import '../../features/donations/domain/usecases/get_donations.dart';
import '../../features/donations/domain/usecases/get_donation_detail.dart';
import '../../features/donations/domain/usecases/get_my_donations.dart';
import '../../features/donations/domain/usecases/get_donation_transactions.dart';
import '../../features/donations/domain/usecases/create_donation_transaction.dart';
import '../../features/donations/presentation/bloc/donation_list_bloc.dart';
import '../../features/donations/presentation/bloc/donation_detail_bloc.dart';
import '../../features/donations/presentation/bloc/my_donation_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ===== Core =====
  getIt.registerLazySingleton<PBClient>(() => PBClient.instance);

  // Initialize PocketBase auth
  await getIt<PBClient>().initAuth();

  // ===== Auth Feature =====

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<PBClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));

  // ===== Donation Feature =====

  // Data Sources
  getIt.registerLazySingleton<DonationRemoteDataSource>(
    () => DonationRemoteDataSourceImpl(getIt<PBClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<DonationRepository>(
    () => DonationRepositoryImpl(getIt<DonationRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetDonations(getIt<DonationRepository>()));
  getIt.registerLazySingleton(
    () => GetDonationDetail(getIt<DonationRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetMyDonations(getIt<DonationRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDonationTransactions(getIt<DonationRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateDonationTransaction(getIt<DonationRepository>()),
  );

  // BLoCs
  getIt.registerFactory(() => DonationListBloc(getIt<GetDonations>()));
  getIt.registerFactory(() => MyDonationBloc(getIt<GetMyDonations>()));
  getIt.registerFactory(
    () => DonationDetailBloc(
      getDonationDetail: getIt<GetDonationDetail>(),
      getDonationTransactions: getIt<GetDonationTransactions>(),
      createDonationTransaction: getIt<CreateDonationTransaction>(),
    ),
  );
}
