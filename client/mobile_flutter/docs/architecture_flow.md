# Flutter 客户端架构流程图

## 整体架构概览

```mermaid
graph TB
    subgraph "Presentation Layer 表现层"
        UI[UI Widgets/Pages]
        Provider[Riverpod Providers]
    end
    
    subgraph "Domain Layer 领域层"
        UseCase[Use Cases]
        Entity[Entities]
        RepoInterface[Repository Interfaces]
    end
    
    subgraph "Data Layer 数据层"
        RepoImpl[Repository Implementations]
        RemoteDS[Remote Data Sources]
        LocalDS[Local Data Sources]
        Model[Data Models]
    end
    
    subgraph "Core 核心模块"
        API[API Client]
        DI[Dependency Injection]
        Theme[Theme]
        Utils[Utils]
    end
    
    subgraph "External 外部服务"
        Backend[Backend API]
        LocalStorage[Local Storage]
    end
    
    UI --> Provider
    Provider --> UseCase
    UseCase --> RepoInterface
    RepoInterface -.-> RepoImpl
    RepoImpl --> RemoteDS
    RepoImpl --> LocalDS
    RemoteDS --> API
    LocalDS --> LocalStorage
    API --> Backend
    
    Model --> RemoteDS
    Model --> LocalDS
    Entity --> UseCase
```

## 数据流向详解

### 1. 用户操作流程 (以登录为例)

```mermaid
sequenceDiagram
    participant U as User
    participant P as LoginPage
    participant N as AuthNotifier
    participant UC as LoginUseCase
    participant R as AuthRepository
    participant RDS as RemoteDataSource
    participant LDS as LocalDataSource
    participant API as ApiClient
    participant BE as Backend

    U->>P: 输入邮箱密码，点击登录
    P->>N: login(email, password)
    N->>N: 设置 loading 状态
    N->>UC: call(LoginParams)
    UC->>R: login(email, password)
    R->>RDS: login(email, password)
    RDS->>API: POST /api/v1/auth/login/
    API->>BE: HTTP Request
    BE-->>API: Response (user + tokens)
    API-->>RDS: Response
    RDS-->>R: (UserModel, TokenModel)
    R->>LDS: cacheUser(user)
    R->>LDS: cacheTokens(tokens)
    LDS-->>R: Success
    R-->>UC: Right(User)
    UC-->>N: Right(User)
    N->>N: 设置 authenticated 状态
    N-->>P: 状态更新
    P->>P: 导航到首页
```

### 2. 数据获取流程 (以获取 Feeds 为例)

```mermaid
sequenceDiagram
    participant P as FeedsPage
    participant N as FeedNotifier
    participant R as FeedRepository
    participant RDS as RemoteDataSource
    participant API as ApiClient
    participant BE as Backend

    P->>N: loadFeeds()
    N->>N: 设置 loading 状态
    N->>R: getFeeds(page: 1)
    R->>RDS: getFeeds(page: 1)
    RDS->>API: GET /api/v1/feeds/
    API->>BE: HTTP Request
    BE-->>API: Response (feeds list)
    API-->>RDS: Response
    RDS-->>R: List<FeedItemModel>
    R-->>N: Right(List<FeedItem>)
    N->>N: 设置 loaded 状态，更新 feeds
    N-->>P: 状态更新
    P->>P: 渲染 feed 列表
```

## 各层职责说明

### Presentation Layer (表现层)

| 组件 | 职责 |
|------|------|
| **Pages** | 页面 UI 组件，负责布局和用户交互 |
| **Widgets** | 可复用的 UI 组件 |
| **Providers** | 状态管理，连接 UI 和业务逻辑 |

```dart
// Provider 示例
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.login(email: email, password: password);
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }
}
```

### Domain Layer (领域层)

| 组件 | 职责 |
|------|------|
| **Entities** | 核心业务对象，纯 Dart 类 |
| **Use Cases** | 单一业务操作，封装业务逻辑 |
| **Repository Interfaces** | 定义数据操作契约 |

```dart
// Use Case 示例
class LoginUseCase {
  final AuthRepository _repository;
  
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
```

### Data Layer (数据层)

| 组件 | 职责 |
|------|------|
| **Repository Impl** | 实现 Repository 接口，协调数据源 |
| **Remote Data Source** | 处理网络请求 |
| **Local Data Source** | 处理本地存储 |
| **Models** | 数据传输对象，包含序列化逻辑 |

```dart
// Repository 实现示例
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  
  @override
  Future<Either<Failure, User>> login({...}) async {
    try {
      final result = await _remoteDataSource.login(...);
      await _localDataSource.cacheUser(result.user);
      await _localDataSource.cacheTokens(...);
      return Right(result.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
```

### Core (核心模块)

| 组件 | 职责 |
|------|------|
| **API Client** | HTTP 客户端，处理请求/响应 |
| **DI** | 依赖注入配置 |
| **Theme** | 主题和样式配置 |
| **Utils** | 工具函数和扩展 |
| **Errors** | 异常和失败类型定义 |

## Feature 模块结构

每个 Feature 模块遵循 Clean Architecture:

```
feature/
├── data/
│   ├── datasources/
│   │   ├── xxx_remote_datasource.dart
│   │   └── xxx_local_datasource.dart
│   ├── models/
│   │   └── xxx_model.dart
│   └── repositories/
│       └── xxx_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── xxx.dart
│   ├── repositories/
│   │   └── xxx_repository.dart
│   └── usecases/
│       └── xxx_usecase.dart
└── presentation/
    ├── providers/
    │   └── xxx_provider.dart
    ├── pages/
    │   └── xxx_page.dart
    └── widgets/
        └── xxx_widget.dart
```

## 错误处理流程

```mermaid
graph TD
    A[API 请求] --> B{响应状态}
    B -->|成功| C[解析数据]
    B -->|失败| D[抛出异常]
    
    D --> E{异常类型}
    E -->|401| F[UnauthorizedException]
    E -->|404| G[NotFoundException]
    E -->|网络错误| H[NetworkException]
    E -->|其他| I[ServerException]
    
    C --> J[返回 Model]
    F --> K[Repository 捕获]
    G --> K
    H --> K
    I --> K
    
    K --> L[转换为 Failure]
    L --> M[返回 Left<Failure>]
    J --> N[返回 Right<Data>]
    
    M --> O[Provider 处理]
    N --> O
    
    O --> P{结果类型}
    P -->|Left| Q[更新错误状态]
    P -->|Right| R[更新成功状态]
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
    subgraph "External"
        SP[SharedPreferences]
        SS[SecureStorage]
    end
    
    subgraph "Core"
        API[ApiClient]
    end
    
    subgraph "Data Sources"
        RDS[RemoteDataSource]
        LDS[LocalDataSource]
    end
    
    subgraph "Repositories"
        Repo[Repository]
    end
    
    subgraph "Providers"
        Notifier[StateNotifier]
    end
    
    SS --> API
    API --> RDS
    SP --> LDS
    SS --> LDS
    RDS --> Repo
    LDS --> Repo
    Repo --> Notifier
```

## 总结

1. **单向数据流**: UI → Provider → UseCase → Repository → DataSource → API
2. **依赖倒置**: 高层模块不依赖低层模块，都依赖抽象
3. **关注点分离**: 每层只关注自己的职责
4. **可测试性**: 通过接口抽象，便于单元测试和 Mock
5. **可维护性**: 清晰的模块边界，便于修改和扩展
