/// # 依赖注入 (Dependency Injection, DI)
///
/// ## 什么是依赖注入？
/// 依赖注入是一种设计模式，用于管理对象之间的依赖关系。
/// 简单来说，就是一个"服务中心"，统一管理和分发应用中各种对象的创建。
///
/// ## 为什么需要它？
/// 假设没有 DI，你在页面里要用 AuthRepository，代码会变成这样：
/// ```dart
/// // ❌ 不用 DI - 每次都要手动创建一堆依赖
/// final secureStorage = FlutterSecureStorage();
/// final grpcClient = UnifiedGrpcClient(...);
/// final remoteDataSource = AuthGrpcDataSourceImpl(grpcClient);
/// final localDataSource = AuthLocalDataSourceImpl(...);
/// final authRepository = AuthRepositoryImpl(
///   remoteDataSource: remoteDataSource,
///   localDataSource: localDataSource,
/// );
/// ```
///
/// 用了 DI 之后：
/// ```dart
/// // ✅ 用 DI - 一行搞定
/// final authRepository = getIt<AuthRepository>();
/// ```
///
/// ## 核心概念
/// - `registerSingleton<T>()` - 立即创建实例，全局唯一
/// - `registerLazySingleton<T>()` - 延迟创建（首次使用时），全局唯一
/// - `getIt<T>()` - 从容器中获取类型 T 的实例
///
/// ## 数据流向
/// ```
/// 页面/Provider → getIt<Repository>() → Repository → DataSource → gRPC Client
///                     ↑
///                     └── DI 容器自动组装好这条链
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../grpc/grpc_client.dart';
import '../grpc/auth_grpc_client.dart' as auth_client;
import '../grpc/chat_grpc_client.dart';
import '../grpc/feed_grpc_client.dart';
import '../grpc/post_grpc_client.dart';
import '../grpc/user_grpc_client.dart';
import '../grpc/search_grpc_client.dart';
import '../grpc/notification_grpc_client.dart';
import '../network/unified_grpc_client.dart';
import '../network/stream_event_handler.dart';
import '../storage/web_session_storage.dart';

// ============================================================================
// 功能模块导入
// ============================================================================

// 认证模块
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_grpc_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// 通知模块
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/datasources/notification_grpc_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';

// 信息流模块
import '../../features/feeds/data/datasources/feed_remote_datasource.dart';
import '../../features/feeds/data/datasources/feed_grpc_datasource.dart';
import '../../features/feeds/data/repositories/feed_repository_impl.dart';
import '../../features/feeds/domain/repositories/feed_repository.dart';

// 个人资料模块
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/datasources/profile_grpc_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

// 搜索模块
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/datasources/search_grpc_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';

// 帖子模块
import '../../features/post/data/datasources/post_remote_datasource.dart';
import '../../features/post/data/datasources/post_grpc_datasource.dart';
import '../../features/post/data/repositories/post_repository_impl.dart';
import '../../features/post/domain/repositories/post_repository.dart';

// 聊天模块
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/datasources/chat_grpc_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

// ============================================================================
// GetIt 服务定位器实例
// ============================================================================

/// 全局服务定位器实例
final getIt = GetIt.instance;

// ============================================================================
// 依赖注入初始化
// ============================================================================

/// 初始化所有依赖注入
Future<void> initializeDependencies() async {
  // --------------------------------------------------------------------------
  // 第一步：注册外部依赖
  // --------------------------------------------------------------------------

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

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

  // --------------------------------------------------------------------------
  // 第二步：注册基础设施
  // --------------------------------------------------------------------------

  getIt.registerLazySingleton<GrpcClientManager>(
    () => GrpcClientManager(secureStorage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<UnifiedGrpcClient>(
    () => UnifiedGrpcClient(secureStorage: getIt<FlutterSecureStorage>()),
  );

  // gRPC 双向流事件处理器
  getIt.registerLazySingleton<StreamEventHandler>(
    () => StreamEventHandler(),
  );

  // gRPC 服务客户端
  getIt.registerLazySingleton<auth_client.AuthGrpcClient>(
    () => auth_client.AuthGrpcClient(getIt<GrpcClientManager>()),
  );
  getIt.registerLazySingleton<ChatGrpcClient>(
    () => ChatGrpcClient(getIt<GrpcClientManager>()),
  );
  getIt.registerLazySingleton<FeedGrpcClient>(
    () => FeedGrpcClient(getIt<GrpcClientManager>()),
  );
  getIt.registerLazySingleton<PostGrpcClient>(
    () => PostGrpcClient(getIt<GrpcClientManager>()),
  );
  getIt.registerLazySingleton<UserGrpcClient>(
    () => UserGrpcClient(getIt<GrpcClientManager>()),
  );
  getIt.registerLazySingleton<SearchGrpcClient>(
    () => SearchGrpcClient(getIt<GrpcClientManager>()),
  );
  getIt.registerLazySingleton<NotificationGrpcClient>(
    () => NotificationGrpcClient(getIt<GrpcClientManager>()),
  );

  // --------------------------------------------------------------------------
  // 第三步：注册数据源和仓库
  // --------------------------------------------------------------------------
  _registerDataSources();
  _registerRepositories();
}

// ============================================================================
// 数据源注册
// ============================================================================

void _registerDataSources() {
  // 认证数据源
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthGrpcDataSourceImpl(getIt<UnifiedGrpcClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // 通知数据源
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationGrpcDataSourceImpl(
      getIt<NotificationGrpcClient>(),
      getIt<SharedPreferences>(),
    ),
  );

  // 信息流数据源
  getIt.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedGrpcDataSourceImpl(
      getIt<FeedGrpcClient>(),
      getIt<SharedPreferences>(),
    ),
  );

  // 个人资料数据源
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileGrpcDataSourceImpl(
      getIt<UserGrpcClient>(),
      getIt<SharedPreferences>(),
    ),
  );

  // 搜索数据源
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchGrpcDataSourceImpl(
      getIt<SearchGrpcClient>(),
      getIt<SharedPreferences>(),
    ),
  );

  // 帖子数据源
  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostGrpcDataSourceImpl(
      getIt<PostGrpcClient>(),
      getIt<SharedPreferences>(),
    ),
  );

  // 聊天数据源
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatGrpcDataSourceImpl(
      getIt<ChatGrpcClient>(),
      getIt<SharedPreferences>(),
    ),
  );
}

// ============================================================================
// 仓库注册
// ============================================================================

void _registerRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(
      remoteDataSource: getIt<FeedRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: getIt<SearchRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: getIt<PostRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: getIt<ChatRemoteDataSource>(),
    ),
  );
}
