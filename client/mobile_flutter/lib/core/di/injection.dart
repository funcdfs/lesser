import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';

// Auth
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Notifications
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';

// Feeds
import '../../features/feeds/data/datasources/feed_remote_datasource.dart';
import '../../features/feeds/data/repositories/feed_repository_impl.dart';
import '../../features/feeds/domain/repositories/feed_repository.dart';

// Profile
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

// Search
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';

// Post
import '../../features/post/data/datasources/post_remote_datasource.dart';
import '../../features/post/data/repositories/post_repository_impl.dart';
import '../../features/post/domain/repositories/post_repository.dart';

// Chat
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // API Client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(secureStorage: getIt<FlutterSecureStorage>()),
  );

  // Data sources
  _registerDataSources();

  // Repositories
  _registerRepositories();
}

void _registerDataSources() {
  // Auth data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Notification data source
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Feed data source
  getIt.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Profile data source
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Search data source
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Post data source
  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Chat data source
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(getIt<ApiClient>()),
  );
}

void _registerRepositories() {
  // Auth repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Notification repository
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );

  // Feed repository
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(
      remoteDataSource: getIt<FeedRemoteDataSource>(),
    ),
  );

  // Profile repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  // Search repository
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: getIt<SearchRemoteDataSource>(),
    ),
  );

  // Post repository
  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: getIt<PostRemoteDataSource>(),
    ),
  );

  // Chat repository
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: getIt<ChatRemoteDataSource>(),
    ),
  );
}
