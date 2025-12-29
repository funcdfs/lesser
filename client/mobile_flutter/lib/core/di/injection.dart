import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../grpc/grpc_client.dart';
import '../grpc/auth_grpc_client.dart';
import '../grpc/chat_grpc_client.dart';
import '../storage/web_session_storage.dart';

// 认证
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// 通知
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';

// 信息流
import '../../features/feeds/data/datasources/feed_remote_datasource.dart';
import '../../features/feeds/data/repositories/feed_repository_impl.dart';
import '../../features/feeds/domain/repositories/feed_repository.dart';

// 个人资料
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

// 搜索
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';

// 帖子
import '../../features/post/data/datasources/post_remote_datasource.dart';
import '../../features/post/data/repositories/post_repository_impl.dart';
import '../../features/post/domain/repositories/post_repository.dart';

// 聊天
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/datasources/chat_websocket_service.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

final getIt = GetIt.instance;

/// 初始化依赖注入
Future<void> initializeDependencies() async {
  // 外部依赖
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Web 平台使用基于会话的存储（每个标签页独立会话）
  // 移动平台使用安全存储
  late final FlutterSecureStorage secureStorage;
  if (kIsWeb) {
    secureStorage = const WebSessionStorage();
  } else {
    secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // API 客户端
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(secureStorage: getIt<FlutterSecureStorage>()),
  );

  // gRPC 客户端管理器
  getIt.registerLazySingleton<GrpcClientManager>(
    () => GrpcClientManager(secureStorage: getIt<FlutterSecureStorage>()),
  );

  // gRPC 服务客户端
  getIt.registerLazySingleton<AuthGrpcClient>(
    () => AuthGrpcClient(getIt<GrpcClientManager>()),
  );
  getIt.registerLazySingleton<ChatGrpcClient>(
    () => ChatGrpcClient(getIt<GrpcClientManager>()),
  );

  // 数据源
  _registerDataSources();

  // 仓库
  _registerRepositories();
}

void _registerDataSources() {
  // 认证数据源
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // 通知数据源
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 信息流数据源
  getIt.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 个人资料数据源
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 搜索数据源
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 帖子数据源
  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 聊天数据源
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      getIt<ApiClient>(),
      getIt<SharedPreferences>(),
    ),
  );

  // 聊天 WebSocket 服务（单例，用于实时消息）
  getIt.registerLazySingleton<ChatWebSocketService>(
    () => ChatWebSocketService(),
  );
}

void _registerRepositories() {
  // 认证仓库
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // 通知仓库
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );

  // 信息流仓库
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(
      remoteDataSource: getIt<FeedRemoteDataSource>(),
    ),
  );

  // 个人资料仓库
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  // 搜索仓库
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: getIt<SearchRemoteDataSource>(),
    ),
  );

  // 帖子仓库
  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: getIt<PostRemoteDataSource>(),
    ),
  );

  // 聊天仓库
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: getIt<ChatRemoteDataSource>(),
    ),
  );
}
