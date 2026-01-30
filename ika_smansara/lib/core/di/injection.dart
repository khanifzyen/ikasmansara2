/// Dependency Injection Setup with GetIt
library;

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/pb_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
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
import '../../features/news/data/datasources/news_remote_data_source.dart';
import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/repositories/news_repository.dart';
import '../../features/news/domain/usecases/get_news_list.dart';
import '../../features/news/domain/usecases/get_news_detail.dart';
import '../../features/news/presentation/bloc/news_bloc.dart';
import '../../features/events/data/datasources/event_remote_data_source.dart';
import '../../features/events/data/repositories/event_repository_impl.dart';
import '../../features/events/domain/repositories/event_repository.dart';
import '../../features/events/domain/usecases/get_events.dart';
import '../../features/events/domain/usecases/get_event_detail.dart';
import '../../features/events/domain/usecases/get_event_tickets.dart';
import '../../features/events/domain/usecases/get_event_sub_events.dart';
import '../../features/events/domain/usecases/get_event_sponsors.dart';

import '../../features/events/domain/usecases/create_event_booking.dart';
import '../../features/events/domain/usecases/get_user_event_bookings.dart';
import '../../features/events/domain/usecases/get_event_booking_tickets.dart';
import '../../features/events/domain/usecases/cancel_booking.dart';
import '../../features/events/domain/usecases/delete_booking.dart';
import '../../features/events/presentation/bloc/events_bloc.dart';
import '../../features/events/presentation/bloc/event_booking_bloc.dart';
import '../../features/events/presentation/bloc/my_tickets_bloc.dart';

import '../../features/forum/data/datasources/forum_remote_data_source.dart';

import '../../features/forum/data/repositories/forum_repository_impl.dart';
import '../../features/forum/domain/repositories/forum_repository.dart';

import '../../features/forum/domain/usecases/add_forum_comment.dart';
import '../../features/forum/domain/usecases/create_forum_post.dart';
import '../../features/forum/domain/usecases/get_forum_comments.dart';
import '../../features/forum/domain/usecases/get_forum_posts.dart';
import '../../features/forum/domain/usecases/toggle_forum_like.dart';

import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

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

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
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

  // ===== News Feature =====

  // Data Sources
  getIt.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(getIt<PBClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(getIt<NewsRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetNewsList(getIt<NewsRepository>()));
  getIt.registerLazySingleton(() => GetNewsDetail(getIt<NewsRepository>()));

  // BLoCs
  getIt.registerFactory(() => NewsBloc(getIt<GetNewsList>()));

  // ===== Event Feature =====

  // Data Sources
  getIt.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(getIt<PBClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(getIt<EventRemoteDataSource>()),
  );

  // Use Cases
  // Use Cases
  getIt.registerLazySingleton(() => GetEvents(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => GetEventDetail(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => GetEventTickets(getIt<EventRepository>()));
  getIt.registerLazySingleton(
    () => GetEventSubEvents(getIt<EventRepository>()),
  );
  getIt.registerLazySingleton(() => GetEventSponsors(getIt<EventRepository>()));
  getIt.registerLazySingleton(
    () => CreateEventBooking(getIt<EventRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetUserEventBookings(getIt<EventRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetEventBookingTickets(getIt<EventRepository>()),
  );
  getIt.registerLazySingleton(() => CancelBooking(getIt<EventRepository>()));
  getIt.registerLazySingleton(() => DeleteBooking(getIt<EventRepository>()));

  // BLoCs
  getIt.registerFactory(() => EventsBloc(getIt<GetEvents>()));
  getIt.registerFactory(() => EventBookingBloc(getIt<CreateEventBooking>()));
  getIt.registerLazySingleton(
    () => MyTicketsBloc(
      getUserEventBookings: getIt<GetUserEventBookings>(),
      getEventBookingTickets: getIt<GetEventBookingTickets>(),
      cancelBooking: getIt<CancelBooking>(),
      deleteBooking: getIt<DeleteBooking>(),
    ),
  );

  // ===== Forum Feature =====

  // Data Sources
  getIt.registerLazySingleton<ForumRemoteDataSource>(
    () => ForumRemoteDataSourceImpl(getIt<PBClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<ForumRepository>(
    () => ForumRepositoryImpl(getIt<ForumRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetForumPosts(getIt<ForumRepository>()));
  getIt.registerLazySingleton(() => CreateForumPost(getIt<ForumRepository>()));
  getIt.registerLazySingleton(() => GetForumComments(getIt<ForumRepository>()));
  getIt.registerLazySingleton(() => AddForumComment(getIt<ForumRepository>()));
  getIt.registerLazySingleton(() => ToggleForumLike(getIt<ForumRepository>()));

  // BLoCs
  // ForumBloc registration will be done after creating the class

  // ===== Profile Feature =====

  // Data Sources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<PBClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetProfile(getIt<ProfileRepository>()));
  getIt.registerLazySingleton(() => UpdateProfile(getIt<ProfileRepository>()));

  // BLoCs
  getIt.registerFactory(
    () => ProfileBloc(
      getProfile: getIt<GetProfile>(),
      updateProfile: getIt<UpdateProfile>(),
    ),
  );
}
