# Flutter 客户端架构流程图

## 整体架构概览

```mermaid
graph TB
    subgraph "Pages 页面层"
        UI[Pages/Widgets]
    end
    
    subgraph "Handler 业务逻辑层"
        Handler[Handler + StateNotifier]
    end
    
    subgraph "DataAccess 数据访问层"
        DA[DataAccess]
    end
    
    subgraph "Models 模型层"
        Model[Models]
    end
    
    subgraph "Pkg 公共库"
        Network[network/ gRPC Channel]
        Errors[errors/ 异常处理]
        UI_Pkg[ui/ 主题/组件]
        Constants[constants/ 端点/颜色]
    end
    
    subgraph "Proto 生成代码"
        Proto[gen_protos/ 禁止手动修改]
    end
    
    subgraph "Backend 后端"
        Gateway[Gateway :50051]
        Chat[Chat :50060]
        Channel[Channel :50062]
    end
    
    UI --> Handler
    Handler --> DA
    DA --> Model
    Model --> Proto
    DA --> Network
    Network --> Gateway
    Network --> Chat
    Network --> Channel
```

## 调用链路

```
pages → handler → data_access → gRPC → Gateway → Service
```

## 数据流向详解

### 1. 用户操作流程（以登录为例）

```mermaid
sequenceDiagram
    participant U as User
    participant P as LoginPage
    participant H as AuthHandler
    participant DA as AuthDataAccess
    participant N as Network
    participant BE as Backend

    U->>P: 输入邮箱密码，点击登录
    P->>H: login(email, password)
    H->>H: 设置 loading 状态
    H->>DA: login(email, password)
    DA->>N: gRPC 调用
    N->>BE: AuthService.Login
    BE-->>N: Response (user + tokens)
    N-->>DA: Response
    DA->>DA: 缓存 tokens
    DA-->>H: User
    H->>H: 设置 authenticated 状态
    H-->>P: 状态更新
    P->>P: 导航到首页
```

### 2. 数据获取流程（以获取 Feeds 为例）

```mermaid
sequenceDiagram
    participant P as HomePage
    participant H as HomeHandler
    participant DA as HomeDataAccess
    participant N as Network
    participant BE as Backend

    P->>H: loadFeeds()
    H->>H: 设置 loading 状态
    H->>DA: getHomeFeed(page: 1)
    DA->>N: gRPC 调用
    N->>BE: TimelineService.GetHomeFeed
    BE-->>N: Response (feeds list)
    N-->>DA: Response
    DA-->>H: List<FeedItem>
    H->>H: 设置 loaded 状态，更新 feeds
    H-->>P: 状态更新
    P->>P: 渲染 feed 列表
```

## 各层职责说明

### Pages 页面层

| 组件 | 职责 |
|------|------|
| **pages/** | 页面 UI 组件，负责布局和用户交互 |
| **widgets/** | 可复用的 UI 组件 |

```dart
// Page 示例
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authHandlerProvider);
    
    return Scaffold(
      body: state.when(
        initial: () => LoginForm(onSubmit: (email, password) {
          ref.read(authHandlerProvider.notifier).login(email, password);
        }),
        loading: () => LoadingIndicator(),
        authenticated: (user) => HomePage(),
        error: (message) => ErrorView(message: message),
      ),
    );
  }
}
```

### Handler 业务逻辑层

| 组件 | 职责 |
|------|------|
| **handler/** | 状态管理，连接 UI 和数据访问层 |
| **stream_handler/** | 处理 gRPC 双向流（Chat/Channel） |

```dart
// Handler 示例
class AuthHandler extends StateNotifier<AuthState> {
  final AuthDataAccess _dataAccess;
  
  AuthHandler(this._dataAccess) : super(AuthState.initial());
  
  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _dataAccess.login(email: email, password: password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}
```

### DataAccess 数据访问层

| 组件 | 职责 |
|------|------|
| **data_access/** | 处理 gRPC 调用，管理本地缓存 |

```dart
// DataAccess 示例
class AuthDataAccess {
  final AuthServiceClient _client;
  final TokenStorage _tokenStorage;
  
  Future<User> login({required String email, required String password}) async {
    final request = LoginRequest()
      ..email = email
      ..password = password;
    
    final response = await _client.login(request);
    
    // 缓存 tokens
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    
    return User.fromProto(response.user);
  }
}
```

### Models 模型层

| 组件 | 职责 |
|------|------|
| **models/** | 业务模型，封装 Proto 对象 |

```dart
// Model 示例
class User {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });
  
  // 从 Proto 转换
  factory User.fromProto(UserProto proto) {
    return User(
      id: proto.id,
      username: proto.username,
      email: proto.email,
      displayName: proto.displayName.isEmpty ? null : proto.displayName,
      avatarUrl: proto.avatarUrl.isEmpty ? null : proto.avatarUrl,
    );
  }
}
```

### Pkg 公共库

| 组件 | 职责 |
|------|------|
| **network/** | gRPC Channel 管理，拦截器 |
| **errors/** | 异常类型定义 |
| **ui/** | 主题、通用组件 |
| **constants/** | 端点、颜色常量 |
| **utils/** | 工具函数 |
| **logs/** | 日志工具 |

## Feature 模块结构

```
features/<name>/
├── handler/
│   └── xxx_handler.dart       # 状态管理
├── data_access/
│   └── xxx_data_access.dart   # gRPC 调用
├── models/
│   └── xxx_model.dart         # 业务模型
├── pages/
│   └── xxx_page.dart          # 页面
└── widgets/
    └── xxx_widget.dart        # 组件
```

## 错误处理流程

```mermaid
graph TD
    A[gRPC 调用] --> B{响应状态}
    B -->|成功| C[解析数据]
    B -->|失败| D[抛出异常]
    
    D --> E{gRPC 状态码}
    E -->|UNAUTHENTICATED| F[AuthException]
    E -->|NOT_FOUND| G[NotFoundException]
    E -->|UNAVAILABLE| H[NetworkException]
    E -->|其他| I[ServerException]
    
    C --> J[返回 Model]
    F --> K[DataAccess 捕获]
    G --> K
    H --> K
    I --> K
    
    K --> L[Handler 处理]
    J --> L
    
    L --> M{结果}
    M -->|异常| N[更新错误状态]
    M -->|成功| O[更新成功状态]
```

## 状态管理流程

```mermaid
stateDiagram-v2
    [*] --> Initial
    Initial --> Loading: 开始请求
    Loading --> Loaded: 请求成功
    Loading --> Error: 请求失败
    Loaded --> Loading: 刷新/加载更多
    Error --> Loading: 重试
    Loaded --> [*]
```

## 依赖注入关系

```mermaid
graph BT
    subgraph "Storage"
        SS[SecureStorage]
        SP[SharedPreferences]
    end
    
    subgraph "Network"
        Channel[gRPC Channel]
        Client[Service Clients]
    end
    
    subgraph "DataAccess"
        DA[DataAccess]
    end
    
    subgraph "Handler"
        H[Handler/StateNotifier]
    end
    
    SS --> Channel
    Channel --> Client
    Client --> DA
    SP --> DA
    SS --> DA
    DA --> H
```

## 底部导航栏

| Tab | 名称 | Feature | 后端服务 |
|-----|------|---------|---------|
| 1 | 首页 | home | Timeline + Content + Comment + Interaction + Search |
| 2 | 频道 | channel | Channel (广播频道服务) |
| 3 | 聊天 | chat | Chat (私聊/群聊) + Notification |
| 4 | 我的 | profile | User |

登录页（auth）独立，不在底部导航栏。

## 总结

1. **简洁分层**: pages → handler → data_access → models → gen_protos
2. **单向数据流**: UI 触发 Handler，Handler 调用 DataAccess，DataAccess 返回 Model
3. **gRPC 通信**: 所有后端通信通过 gRPC，Proto 文件自动生成
4. **状态管理**: 使用 Riverpod + StateNotifier 管理状态
5. **可测试性**: 各层职责清晰，便于单元测试
