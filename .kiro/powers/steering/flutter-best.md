# Flutter Development Best Practices

> Flutter 开发最佳实践指南（基于 Lesser 项目架构）

## 1. 架构原则

### 项目分层结构
```
lib/
├── gen_protos/         # protoc 生成代码【禁止手动修改】
├── pkg/                # 公共库
│   ├── constants/      # 常量（端点、颜色等）
│   ├── network/        # gRPC Channel 管理
│   ├── errors/         # 异常处理
│   ├── logs/           # 日志
│   ├── ui/             # 主题/公共组件
│   └── utils/          # 工具函数
├── features/
│   ├── auth/           # 登录页
│   ├── home/           # Tab 1: 首页
│   ├── channel/        # Tab 2: 频道
│   ├── chat/           # Tab 3: 聊天
│   └── profile/        # Tab 4: 我的
├── app.dart
└── main.dart

features/<name>/
├── handler/            # 业务逻辑层（状态管理、业务规则）
├── data_access/        # 数据访问层（gRPC 调用）
├── models/             # 数据模型（Proto 转换）
├── pages/              # 页面
└── widgets/            # 组件
```

### 调用链路
```
pages → handler → data_access → gRPC → Gateway → Service
```

### 分层职责
- **pages/**: UI 展示，只负责渲染和用户交互
- **widgets/**: 可复用的 UI 组件
- **handler/**: 业务逻辑、状态管理、数据转换
- **data_access/**: gRPC 数据源调用，错误映射
- **models/**: 数据模型定义，Proto ↔ Model 转换

## 2. Widget 设计

### 组合优于继承
```dart
// ✅ 好：组合小型、可复用的 widget
class UserCard extends StatelessWidget {
  final User user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          UserAvatar(url: user.avatarUrl),
          UserName(name: user.name),
          UserBio(bio: user.bio),
        ],
      ),
    );
  }
}

// ❌ 避免：一个巨大的 widget 做所有事情
```

### const 构造函数
```dart
// ✅ 使用 const 减少重建
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});  // const 构造函数

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),  // const
      child: Text('Hello'),
    );
  }
}

// 在 build 方法中使用 const
Widget build(BuildContext context) {
  return Column(
    children: const [
      Icon(Icons.star),
      SizedBox(height: 8),
      Text('Rating'),
    ],
  );
}
```

### 避免不必要的 Container
```dart
// ❌ 不好：只为了 padding 使用 Container
Container(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
)

// ✅ 好：使用 Padding
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
)

// ❌ 不好：只为了尺寸使用 Container
Container(
  width: 100,
  height: 100,
)

// ✅ 好：使用 SizedBox
SizedBox(
  width: 100,
  height: 100,
)
```

## 3. 状态管理

### Handler 模式（项目标准）
```dart
// 简单状态管理使用 ChangeNotifier
class AuthHandler extends ChangeNotifier {
  final AuthDataAccess _dataAccess;
  
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthHandler(this._dataAccess);

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _dataAccess.login(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
```

### Chat Stream Handler（双向流）
```dart
// features/chat/handler/stream_handler.dart
class ChatStreamHandler extends ChangeNotifier {
  final ChatDataAccess _dataAccess;
  StreamSubscription? _subscription;
  
  List<Message> _messages = [];
  bool _isConnected = false;

  List<Message> get messages => _messages;
  bool get isConnected => _isConnected;

  ChatStreamHandler(this._dataAccess);

  void subscribe(String conversationId) {
    _subscription = _dataAccess.streamEvents(conversationId).listen(
      (event) {
        _handleEvent(event);
        notifyListeners();
      },
      onError: (e) {
        _isConnected = false;
        notifyListeners();
      },
    );
    _isConnected = true;
    notifyListeners();
  }

  void _handleEvent(ServerEvent event) {
    if (event.hasNewMessage()) {
      _messages.add(Message.fromProto(event.newMessage));
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

### Provider 定义（可选 Riverpod）
```dart
// 简单状态
final counterProvider = StateProvider<int>((ref) => 0);

// 异步数据
final userProvider = FutureProvider<User>((ref) async {
  final dataAccess = ref.watch(userDataAccessProvider);
  return dataAccess.getCurrentUser();
});

// 复杂状态 (Notifier)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}
```

### Handler 层示例
```dart
// features/home/handler/home_handler.dart
class HomeHandler extends ChangeNotifier {
  final HomeDataAccess _dataAccess;
  
  List<Content> _contents = [];
  bool _isLoading = false;
  String? _error;

  List<Content> get contents => _contents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeHandler(this._dataAccess);

  Future<void> loadFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contents = await _dataAccess.getHomeFeed();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 在 Page 中使用
```dart
// features/home/pages/home_page.dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeHandler>(
      builder: (context, handler, child) {
        if (handler.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (handler.error != null) {
          return ErrorView(message: handler.error!);
        }
        return ContentList(contents: handler.contents);
      },
    );
  }
}
```

### 异步状态处理（Riverpod）
```dart
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      data: (user) => UserProfile(user: user),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
}
```

## 4. 列表性能

### ListView.builder
```dart
// ✅ 好：懒加载列表项
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index].name));
  },
)

// ❌ 避免：一次性构建所有项
ListView(
  children: items.map((item) => ListTile(title: Text(item.name))).toList(),
)
```

### 使用 Key
```dart
// 当列表项可能重排序时使用 Key
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ListTile(
      key: ValueKey(item.id),  // 唯一标识
      title: Text(item.name),
    );
  },
)
```

### 分页加载
```dart
class PaginatedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(paginatedItemsProvider);
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          ref.read(paginatedItemsProvider.notifier).loadMore();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const LoadingIndicator();
          }
          return ItemTile(item: items[index]);
        },
      ),
    );
  }
}
```

## 5. 网络请求 (gRPC)

### gRPC Channel 管理 (pkg/network/)
```dart
// pkg/network/grpc_channel.dart
class GrpcChannelManager {
  static GrpcChannelManager? _instance;
  late final ClientChannel _gatewayChannel;
  late final ClientChannel _chatChannel;

  GrpcChannelManager._() {
    // Gateway 通道（通过 Traefik）
    _gatewayChannel = ClientChannel(
      Endpoints.gatewayHost,
      port: Endpoints.gatewayPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    
    // Chat 直连通道（gRPC 双向流）
    _chatChannel = ClientChannel(
      Endpoints.chatHost,
      port: Endpoints.chatPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
  }

  static GrpcChannelManager get instance {
    _instance ??= GrpcChannelManager._();
    return _instance!;
  }

  ClientChannel get gatewayChannel => _gatewayChannel;
  ClientChannel get chatChannel => _chatChannel;

  Future<void> shutdown() async {
    await _gatewayChannel.shutdown();
    await _chatChannel.shutdown();
  }
}
```

### Data Access 层
```dart
// features/user/data_access/user_data_access.dart
class UserDataAccess {
  final UserServiceClient _client;

  UserDataAccess()
      : _client = UserServiceClient(
          GrpcChannelManager.instance.gatewayChannel,
        );

  Future<User> getUser(String userId) async {
    try {
      final request = GetUserRequest()..userId = userId;
      final response = await _client.getUser(request);
      return User.fromProto(response);
    } on GrpcError catch (e) {
      throw _mapGrpcError(e);
    }
  }

  AppException _mapGrpcError(GrpcError error) {
    switch (error.code) {
      case StatusCode.notFound:
        return NotFoundException(error.message ?? '未找到');
      case StatusCode.unauthenticated:
        return UnauthorizedException(error.message ?? '未授权');
      case StatusCode.permissionDenied:
        return ForbiddenException(error.message ?? '无权限');
      default:
        return ServerException(error.message ?? '服务器错误');
    }
  }
}
```

### Chat 双向流
```dart
// features/chat/data_access/chat_data_access.dart
class ChatDataAccess {
  final ChatServiceClient _client;
  ResponseStream<ServerEvent>? _stream;
  StreamController<ClientEvent>? _requestController;

  ChatDataAccess()
      : _client = ChatServiceClient(
          GrpcChannelManager.instance.chatChannel,
        );

  Stream<ServerEvent> streamEvents(String conversationId) {
    _requestController = StreamController<ClientEvent>();
    
    _stream = _client.streamEvents(_requestController!.stream);
    
    // 发送订阅事件
    _requestController!.add(
      ClientEvent()..subscribe = (SubscribeEvent()..conversationId = conversationId),
    );
    
    return _stream!;
  }

  void sendMessage(String conversationId, String content) {
    _requestController?.add(
      ClientEvent()..sendMessage = (SendMessageEvent()
        ..conversationId = conversationId
        ..content = content),
    );
  }

  void sendPing() {
    _requestController?.add(ClientEvent()..ping = PingEvent());
  }

  void close() {
    _requestController?.close();
  }
}
```

## 6. 数据模型 (models/)

### Model 定义
```dart
// features/user/models/user.dart
class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.isVerified = false,
    required this.createdAt,
  });

  // 从 Proto 转换
  factory User.fromProto(UserProto proto) {
    return User(
      id: proto.id,
      username: proto.username,
      email: proto.email,
      avatarUrl: proto.hasAvatarUrl() ? proto.avatarUrl : null,
      isVerified: proto.isVerified,
      createdAt: proto.createdAt.toDateTime(),
    );
  }

  // 转换为 Proto
  UserProto toProto() {
    return UserProto()
      ..id = id
      ..username = username
      ..email = email
      ..avatarUrl = avatarUrl ?? ''
      ..isVerified = isVerified
      ..createdAt = Timestamp.fromDateTime(createdAt);
  }

  // copyWith 方法
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### 使用 Freezed（可选）
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String content,
    required DateTime sentAt,
    @Default(false) bool isRead,
  }) = _Message;

  factory Message.fromProto(MessageProto proto) {
    return Message(
      id: proto.id,
      conversationId: proto.conversationId,
      senderId: proto.senderId,
      content: proto.content,
      sentAt: proto.sentAt.toDateTime(),
      isRead: proto.isRead,
    );
  }
}
```

## 7. 错误处理 (pkg/errors/)

### 异常定义
```dart
// pkg/errors/app_exception.dart
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  const NotFoundException([String message = '资源未找到']) : super(message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = '未授权']) : super(message);
}

class ForbiddenException extends AppException {
  const ForbiddenException([String message = '无权限']) : super(message);
}

class ServerException extends AppException {
  const ServerException([String message = '服务器错误']) : super(message);
}

class NetworkException extends AppException {
  const NetworkException([String message = '网络连接失败']) : super(message);
}
```

### 在 Handler 中处理
```dart
class UserHandler extends ChangeNotifier {
  final UserDataAccess _dataAccess;
  
  User? _user;
  AppException? _error;
  bool _isLoading = false;

  User? get user => _user;
  AppException? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _dataAccess.getUser(userId);
    } on AppException catch (e) {
      _error = e;
    } catch (e) {
      _error = ServerException('未知错误: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 在 UI 中展示
```dart
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserHandler>(
      builder: (context, handler, child) {
        if (handler.isLoading) {
          return const LoadingView();
        }
        
        if (handler.error != null) {
          return ErrorView(
            error: handler.error!,
            onRetry: () => handler.loadUser(userId),
          );
        }
        
        if (handler.user == null) {
          return const EmptyView(message: '用户不存在');
        }
        
        return UserProfile(user: handler.user!);
      },
    );
  }
}

// 通用错误视图
class ErrorView extends StatelessWidget {
  final AppException error;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(),
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(error.message),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    if (error is NetworkException) return Icons.wifi_off;
    if (error is UnauthorizedException) return Icons.lock;
    if (error is NotFoundException) return Icons.search_off;
    return Icons.error_outline;
  }
}
```

## 8. 导航

### GoRouter
```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'user/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return UserPage(userId: id);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider).isLoggedIn;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }
      return null;
    },
  );
});
```

## 9. 主题和样式

### Material 3
```dart
final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
  ),
);
```

### 响应式设计
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

## 10. 测试

### Handler 测试
```dart
void main() {
  late MockUserDataAccess mockDataAccess;
  late UserHandler handler;

  setUp(() {
    mockDataAccess = MockUserDataAccess();
    handler = UserHandler(mockDataAccess);
  });

  test('loadUser success', () async {
    final user = User(id: '1', username: 'test', email: 'test@example.com', createdAt: DateTime.now());
    when(mockDataAccess.getUser('1')).thenAnswer((_) async => user);

    await handler.loadUser('1');

    expect(handler.user, user);
    expect(handler.error, isNull);
    expect(handler.isLoading, false);
  });

  test('loadUser error', () async {
    when(mockDataAccess.getUser('1')).thenThrow(NotFoundException());

    await handler.loadUser('1');

    expect(handler.user, isNull);
    expect(handler.error, isA<NotFoundException>());
    expect(handler.isLoading, false);
  });
}
```

### Widget 测试
```dart
void main() {
  testWidgets('UserPage shows user profile', (tester) async {
    final handler = MockUserHandler();
    when(handler.user).thenReturn(testUser);
    when(handler.isLoading).thenReturn(false);
    when(handler.error).thenReturn(null);

    await tester.pumpWidget(
      ChangeNotifierProvider<UserHandler>.value(
        value: handler,
        child: const MaterialApp(home: UserPage()),
      ),
    );

    expect(find.text(testUser.username), findsOneWidget);
  });

  testWidgets('UserPage shows loading', (tester) async {
    final handler = MockUserHandler();
    when(handler.isLoading).thenReturn(true);

    await tester.pumpWidget(
      ChangeNotifierProvider<UserHandler>.value(
        value: handler,
        child: const MaterialApp(home: UserPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### Data Access 测试
```dart
void main() {
  late MockUserServiceClient mockClient;
  late UserDataAccess dataAccess;

  setUp(() {
    mockClient = MockUserServiceClient();
    dataAccess = UserDataAccess.withClient(mockClient);
  });

  test('getUser returns user', () async {
    final proto = UserProto()
      ..id = '1'
      ..username = 'test';
    when(mockClient.getUser(any)).thenAnswer((_) async => proto);

    final user = await dataAccess.getUser('1');

    expect(user.id, '1');
    expect(user.username, 'test');
  });

  test('getUser throws NotFoundException on NOT_FOUND', () async {
    when(mockClient.getUser(any)).thenThrow(
      GrpcError.notFound('User not found'),
    );

    expect(
      () => dataAccess.getUser('1'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
```

## 11. 性能优化

### 避免重建
```dart
// ✅ 使用 select 只监听需要的部分
final userName = ref.watch(userProvider.select((user) => user.name));

// ✅ 使用 Consumer 限制重建范围
Scaffold(
  appBar: AppBar(title: const Text('App')),
  body: Consumer(
    builder: (context, ref, child) {
      final count = ref.watch(counterProvider);
      return Text('Count: $count');
    },
  ),
)
```

### 图片优化
```dart
// 使用 cached_network_image
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 200,  // 限制缓存尺寸
)
```

### 延迟加载
```dart
// 使用 AutomaticKeepAliveClientMixin 保持状态
class _MyPageState extends State<MyPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ...;
  }
}
```

## 参考文档

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)
- [Effective Dart](https://dart.dev/effective-dart)
