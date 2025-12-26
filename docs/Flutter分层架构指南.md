# Flutter Frontend 分层架构指南

## 架构概览

Lesser 项目的 Flutter 前端遵循 Clean Architecture 分层设计，分为四个清晰的层次：

```
┌─────────────────────────────────────────────────────┐
│                 app/ (应用层)                        │
│    ▸ 路由定义 ▸ Theme 主题 ▸ 依赖注入 ▸ 配置     │
└─────────────────────────────────────────────────────┘
                       ▲
┌─────────────────────────────────────────────────────┐
│               feature/ (功能层)                      │
│    ▸ UI Pages ▸ Widgets ▸ State Management       │
│    ▸ 依赖: domain + data 层                        │
└─────────────────────────────────────────────────────┘
                       ▲
┌──────────────┬──────────────────────────┐
│    data/     │        domain/           │
│  数据层      │     领域层（核心）      │
│  ▸ API       │  ▸ Entities              │
│  ▸ Repos     │  ▸ Repositories (接口)  │
│  ▸ Models    │                          │
└──────────────┴──────────────────────────┘
         ▲                 ▲
         └─────────────────┘
       (data 实现 domain 的接口)
```

## 分层详解

### 1. domain/ - 领域层（业务核心）

**职责**：定义纯业务模型和业务逻辑接口  
**关键特点**：
- 不依赖 Flutter 框架
- 不依赖 HTTP 客户端、JSON 序列化等技术细节
- 可单独进行单元测试
- 可被多个项目复用（如果需要）

**目录结构**：
```
domain/
├── entities/           # 业务实体（核心对象）
│   ├── user.dart      # User 实体
│   ├── post.dart      # Post 实体
│   ├── chat.dart      # Chat 实体
│   └── ...
│
├── repositories/       # Repository 接口（业务逻辑接口）
│   ├── user_repository.dart
│   ├── post_repository.dart
│   └── ...
│
└── usecases/          # 业务用例（可选，用于复杂业务逻辑）
    ├── get_user_usecase.dart
    └── ...
```

**示例：User 实体**
```dart
// domain/entities/user.dart
/// 用户业务模型（与框架无关）
class User {
  final int id;
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
  });
  
  /// 副本方法
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? avatar,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
    );
  }
}
```

**示例：Repository 接口**
```dart
// domain/repositories/user_repository.dart
/// 用户业务逻辑接口（由 data 层实现）
abstract class UserRepository {
  /// 获取用户列表
  Future<List<User>> getUsers();
  
  /// 获取用户详情
  Future<User> getUser(int id);
  
  /// 创建用户
  Future<User> createUser(String username, String email);
  
  /// 更新用户
  Future<User> updateUser(User user);
  
  /// 删除用户
  Future<void> deleteUser(int id);
}
```

### 2. data/ - 数据层

**职责**：实现 domain 接口，处理数据来源（API、本地存储）  
**关键特点**：
- 实现 domain 中的 Repository 接口
- 处理数据转换（DTO ↔ Entity）
- 处理 API 调用、缓存、本地存储等
- 依赖外部库（http, shared_preferences 等）

**目录结构**：
```
data/
├── datasources/       # 数据源（API、本地存储）
│   ├── user_remote_datasource.dart    # 远程数据源（API）
│   ├── user_local_datasource.dart     # 本地数据源（缓存）
│   └── ...
│
├── models/            # DTO（数据传输对象）
│   ├── user_model.dart       # User JSON 模型
│   └── ...
│
├── repositories/      # Repository 实现
│   ├── user_repository_impl.dart  # 实现 UserRepository
│   └── ...
│
└── mappers/           # 数据映射器（可选）
    ├── user_mapper.dart  # UserModel ↔ User 映射
    └── ...
```

**示例：User 模型（DTO）**
```dart
// data/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// User JSON 模型（用于 API 通讯）
@JsonSerializable()
class UserModel {
  final int id;
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
  });
  
  /// JSON 反序列化
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  
  /// JSON 序列化
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  /// 转换为 Entity
  User toEntity() => User(
    id: id,
    username: username,
    email: email,
    avatar: avatar,
    bio: bio,
  );
}
```

**示例：远程数据源**
```dart
// data/datasources/user_remote_datasource.dart
abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUser(int id);
  Future<UserModel> createUser(String username, String email);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  
  UserRemoteDataSourceImpl({required this.client});
  
  @override
  Future<List<UserModel>> getUsers() async {
    final response = await client.get(
      Uri.parse('${Config.apiUrl}/api/users/'),
    );
    
    if (response.statusCode == 200) {
      final List json = jsonDecode(response.body);
      return json.map((u) => UserModel.fromJson(u)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
```

**示例：Repository 实现**
```dart
// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  
  UserRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<List<User>> getUsers() async {
    final models = await remoteDataSource.getUsers();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<User> getUser(int id) async {
    final model = await remoteDataSource.getUser(id);
    return model.toEntity();
  }
}
```

### 3. feature/ - 功能层

**职责**：实现 UI、状态管理、用户交互  
**关键特点**：
- 依赖 domain 和 data 层
- 包含 Pages、Widgets、State Management
- 按功能模块划分（不是按 UI 类型）

**目录结构**：
```
feature/
├── user/                      # 用户相关功能
│   ├── presentation/
│   │   ├── pages/
│   │   │   ├── user_list_page.dart     # 用户列表页
│   │   │   ├── user_detail_page.dart   # 用户详情页
│   │   │   └── user_edit_page.dart     # 编辑用户页
│   │   │
│   │   ├── widgets/
│   │   │   ├── user_card.dart          # 用户卡片组件
│   │   │   ├── user_item.dart          # 用户列表项
│   │   │   └── user_form.dart          # 用户表单
│   │   │
│   │   └── providers/                  # Riverpod 状态管理
│   │       ├── user_list_provider.dart
│   │       ├── user_detail_provider.dart
│   │       └── user_form_provider.dart
│   │
│   └── domain/                         # 可选，业务用例
│       └── ...
│
├── post/                      # 内容/文章相关
│   ├── presentation/
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── providers/
│   └── ...
│
├── chat/                      # 聊天相关
│   ├── presentation/
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── providers/
│   └── ...
│
└── ...
```

**示例：用户列表页面**
```dart
// feature/user/presentation/pages/user_list_page.dart
class UserListPage extends ConsumerWidget {
  const UserListPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听用户列表状态
    final usersAsync = ref.watch(userListProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('用户列表')),
      body: usersAsync.when(
        // 数据加载成功
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return UserCard(user: users[index]);
          },
        ),
        // 加载中
        loading: () => const Center(child: CircularProgressIndicator()),
        // 加载失败
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
```

**示例：状态管理（Riverpod）**
```dart
// feature/user/presentation/providers/user_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/repositories/user_repository.dart';

// 依赖注入
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDataSource: UserRemoteDataSourceImpl(
      client: http.Client(),
    ),
  );
});

// 用户列表提供者
final userListProvider = FutureProvider<List<User>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUsers();
});

// 单个用户详情提供者
final userDetailProvider = FutureProvider.family<User, int>((ref, userId) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUser(userId);
});
```

### 4. app/ - 应用层

**职责**：应用级配置、路由、主题、全局设置  
**关键特点**：
- 定义整个应用的路由规则
- 集中管理 Theme（颜色、排版等）
- 配置依赖注入容器
- 定义应用常量

**目录结构**：
```
app/
├── routing/
│   └── app_router.dart        # Go Router 路由配置
│
├── theme/                     # 统一 Theme 管理
│   ├── app_theme.dart         # 主题入口
│   ├── app_colors.dart        # 颜色定义
│   ├── app_typography.dart    # 排版定义
│   └── app_spacing.dart       # 间距定义
│
├── di/                        # 依赖注入
│   └── providers.dart         # 全局 Riverpod Providers
│
├── config/
│   ├── constants.dart         # 应用常量
│   └── config.dart            # 运行时配置
│
└── app.dart                   # 应用入口组件
```

**示例：路由定义**
```dart
// app/routing/app_router.dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UserListPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'user-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return UserDetailPage(userId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
    ],
  );
});
```

**示例：主题定义**
```dart
// app/theme/app_colors.dart
class AppColors {
  // 主要颜色
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  
  // 中立颜色
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  
  // 功能颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
}

// app/theme/app_typography.dart
class AppTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );
}

// app/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),
      typography: Typography.material2018(),
      textTheme: TextTheme(
        headlineLarge: AppTypography.heading1,
        bodyMedium: AppTypography.body1,
        labelSmall: AppTypography.caption,
      ),
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
```

**示例：应用入口**
```dart
// app/app.dart
class LesserApp extends ConsumerWidget {
  const LesserApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Lesser',
      routerConfig: router,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
    );
  }
}
```

## shared/ - 共享资源

**职责**：跨功能使用的组件、工具、常量  
**不属于任何层级**，但被所有层使用

**目录结构**：
```
shared/
├── widgets/                   # 通用 UI 组件
│   ├── base/                 # 原子组件
│   │   ├── custom_button.dart
│   │   ├── custom_input.dart
│   │   ├── custom_card.dart
│   │   └── ...
│   └── common/               # 业务通用组件
│       ├── user_avatar.dart
│       ├── loading_widget.dart
│       └── ...
│
├── utils/                     # 工具函数
│   ├── logger_service.dart   # 日志
│   ├── date_utils.dart       # 日期处理
│   ├── string_utils.dart     # 字符串处理
│   └── ...
│
├── constants/                 # 全局常量
│   ├── app_constants.dart
│   └── api_constants.dart
│
└── extensions/               # 扩展方法
    ├── string_extension.dart
    ├── int_extension.dart
    └── ...
```

## 最佳实践

### ✅ 应该做

1. **严格遵守分层**
   - domain 不依赖任何外部库
   - data 不包含 UI 逻辑
   - feature 只依赖 domain 和 data

2. **模块内聚**
   - 一个 feature 内的页面和组件放在一起
   - 相关的 Provider 放在一个文件

3. **命名规范**
   ```
   # Entities
   class User {}
   
   # Models
   class UserModel {}
   
   # Repositories
   abstract class UserRepository {}
   class UserRepositoryImpl {}
   
   # Providers
   final userRepositoryProvider = ...
   final userListProvider = ...
   
   # Pages
   class UserListPage extends ConsumerWidget {}
   
   # Widgets
   class UserCard extends StatelessWidget {}
   ```

4. **使用 Riverpod 管理状态**
   - 不要手动创建 StateNotifier
   - 使用 Provider 定义所有数据源
   - 使用 FutureProvider 处理异步操作

5. **为复杂逻辑添加注释**
   ```dart
   /// 获取用户列表（带分页和搜索）
   /// 
   /// 参数:
   ///   - [page]: 页码（从 1 开始）
   ///   - [query]: 搜索关键词
   /// 
   /// 返回: 用户列表
   Future<List<User>> getUsers(int page, String query) async {
     // 实现
   }
   ```

### ❌ 不应该做

1. **跨层依赖**
   - feature 不能直接依赖 API
   - data 不能导入 feature

2. **状态管理混乱**
   - 不要用 setState（使用 Riverpod）
   - 不要在 Widget 中进行 API 调用

3. **UI 和业务逻辑混合**
   - 将逻辑提取到 Provider 或 Usecase
   - 保持 Widget 简洁

4. **硬编码值**
   - 使用 constants/ 定义所有常量
   - 使用 theme/ 定义所有样式

## 常见问题

**Q: domain 层可以使用什么库？**
A: 仅标准 Dart 库。不能使用 Flutter、http、json_annotation 等。

**Q: 一个页面对应多个 Provider 吗？**
A: 可以，按功能拆分。如用户列表页可有 userListProvider, userSearchProvider 等。

**Q: 如何在 Provider 之间共享数据？**
A: 使用 `ref.watch()` 监听其他 Provider。

**Q: shared/ 中的组件何时使用？**
A: 当一个组件被多个 feature 使用时，才移到 shared/。

**Q: 如何添加新功能？**
A: 
1. 在 domain/ 定义 Entity 和 Repository 接口
2. 在 data/ 实现数据获取和映射
3. 在 feature/ 实现 UI 和状态管理

