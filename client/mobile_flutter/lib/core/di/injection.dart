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
/// final apiClient = ApiClient(secureStorage: secureStorage);
/// final remoteDataSource = AuthRemoteDataSourceImpl(apiClient);
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
/// 页面/Provider → getIt<Repository>() → Repository → DataSource → ApiClient
///                     ↑
///                     └── DI 容器自动组装好这条链
/// ```
///
/// ## 使用示例
/// ```dart
/// // 在任意位置获取已注册的服务
/// final authRepo = getIt<AuthRepository>();
/// final apiClient = getIt<ApiClient>();
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../grpc/grpc_client.dart';
import '../grpc/auth_grpc_client.dart';
import '../grpc/chat_grpc_client.dart';
import '../storage/web_session_storage.dart';

// ============================================================================
// 功能模块导入
// ============================================================================

// 认证模块
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// 通知模块
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';

// 信息流模块
import '../../features/feeds/data/datasources/feed_remote_datasource.dart';
import '../../features/feeds/data/repositories/feed_repository_impl.dart';
import '../../features/feeds/domain/repositories/feed_repository.dart';

// 个人资料模块
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

// 搜索模块
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';

// 帖子模块
import '../../features/post/data/datasources/post_remote_datasource.dart';
import '../../features/post/data/repositories/post_repository_impl.dart';
import '../../features/post/domain/repositories/post_repository.dart';

// 聊天模块
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/datasources/chat_grpc_datasource.dart';
import '../../features/chat/data/datasources/chat_websocket_service.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

// ============================================================================
// GetIt 服务定位器实例
// ============================================================================

/// 全局服务定位器实例
/// 通过 getIt<T>() 获取已注册的服务
final getIt = GetIt.instance;

// ============================================================================
// 依赖注入初始化
// ============================================================================

/// 初始化所有依赖注入
///
/// 在 main.dart 中调用，应用启动时执行一次：
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeDependencies();  // 初始化 DI
///   runApp(MyApp());
/// }
/// ```
///
/// 注册顺序很重要：
/// 1. 外部依赖（SharedPreferences、SecureStorage）
/// 2. 基础设施（ApiClient、GrpcClient）
/// 3. 数据源（DataSource）
/// 4. 仓库（Repository）
Future<void> initializeDependencies() async {
  // --------------------------------------------------------------------------
  // 第一步：注册外部依赖
  // --------------------------------------------------------------------------

  // SharedPreferences - 用于存储非敏感的键值对数据
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // FlutterSecureStorage - 用于存储敏感数据（如 Token）
  // Web 平台：使用 sessionStorage（每个标签页独立，关闭即清除）
  // 移动平台：使用系统安全存储（iOS Keychain / Android EncryptedSharedPreferences）
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

  // REST API 客户端 - 处理所有 HTTP 请求
  // LazySingleton: 首次使用时才创建，节省启动时间
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(secureStorage: getIt<FlutterSecureStorage>()),
  );

  // gRPC 客户端管理器 - 管理 gRPC 连接
  getIt.registerLazySingleton<GrpcClientManager>(
    () => GrpcClientManager(secureStorage: getIt<FlutterSecureStorage>()),
  );

  // gRPC 服务客户端 - 各业务的 gRPC 调用
  getIt.registerLazySingleton<AuthGrpcClient>(
    () => AuthGrpcClient(getIt<GrpcClientManager>()),
  );
  getIt.registerLazySingleton<ChatGrpcClient>(
    () => ChatGrpcClient(getIt<GrpcClientManager>()),
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

/// 注册所有数据源 (DataSource)
///
/// 数据源负责具体的数据获取逻辑：
/// - RemoteDataSource: 从服务器获取数据（HTTP/gRPC）
/// - LocalDataSource: 从本地存储获取数据（SharedPreferences/SecureStorage/SQLite）
void _registerDataSources() {
  // 认证数据源
  // RemoteDataSource: 登录、注册、刷新 Token 等网络请求
  // LocalDataSource: Token 存储、用户信息缓存
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // 通知数据源 - 获取通知列表、标记已读
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 信息流数据源 - 获取 Feed 列表、点赞、评论等
  getIt.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 个人资料数据源 - 获取/更新用户资料、关注/粉丝列表
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 搜索数据源 - 搜索用户、帖子
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 帖子数据源 - 帖子 CRUD 操作
  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // 聊天数据源 - 会话列表、消息历史（使用 gRPC）
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatGrpcDataSourceImpl(
      getIt<ChatGrpcClient>(),
      getIt<SharedPreferences>(),
    ),
  );

  // 聊天 WebSocket 服务 - 实时消息收发
  // 单例模式确保全局只有一个 WebSocket 连接
  getIt.registerLazySingleton<ChatWebSocketService>(
    () => ChatWebSocketService(),
  );
}

// ============================================================================
// 仓库注册
// ============================================================================

/// 注册所有仓库 (Repository)
///
/// 仓库是数据层的门面，负责：
/// 1. 协调多个数据源（远程 + 本地）
/// 2. 数据转换（Model → Entity）
/// 3. 缓存策略（先本地后远程、失败回退等）
/// 4. 错误处理和重试逻辑
///
/// 注意：这里注册的是接口类型 (AuthRepository)，
/// 实现类 (AuthRepositoryImpl) 作为工厂函数返回。
/// 这样上层代码只依赖接口，方便测试时替换为 Mock 实现。
void _registerRepositories() {
  // 认证仓库 - 登录状态管理、Token 刷新
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
