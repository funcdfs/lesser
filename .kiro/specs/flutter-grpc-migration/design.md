# Design Document: Flutter gRPC Migration

## Overview

This design document outlines the complete migration of the Flutter client from Django RESTful API to gRPC architecture. Building on the successful Auth and Chat module gRPC migrations, this design extends gRPC communication to all remaining business modules: feeds, post, profile, search, and notifications.

### Goals

- Remove all RESTful API dependencies from Flutter client
- Implement gRPC clients for all business modules
- Unify communication protocol using gRPC + WebSocket
- Maintain Clean Architecture layering
- Ensure seamless integration with Go backend gRPC services

### Non-Goals

- Modifying backend gRPC service implementations
- Changing UI/UX or business logic
- Implementing new features beyond migration scope

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Client                          │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer (Providers/Widgets)                     │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer (Entities/Repositories)                       │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                  │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │  gRPC DataSource │  │  Local DataSource│               │
│  └────────┬─────────┘  └──────────────────┘               │
│           │                                                 │
│  ┌────────▼─────────────────────────────────┐             │
│  │     gRPC Client Manager                   │             │
│  │  ┌──────────┐  ┌──────────┐  ┌────────┐ │             │
│  │  │ Feed     │  │ Post     │  │ User   │ │             │
│  │  │ Client   │  │ Client   │  │ Client │ │             │
│  │  └──────────┘  └──────────┘  └────────┘ │             │
│  │  ┌──────────┐  ┌──────────┐             │             │
│  │  │ Search   │  │ Notif    │             │             │
│  │  │ Client   │  │ Client   │             │             │
│  │  └──────────┘  └──────────┘             │             │
│  └────────┬─────────────────────────────────┘             │
└───────────┼─────────────────────────────────────────────────┘
            │ gRPC Protocol
┌───────────▼─────────────────────────────────────────────────┐
│                     Go Backend                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Gateway  │  │ Feed     │  │ Post     │  │ User     │  │
│  │ Service  │  │ Worker   │  │ Worker   │  │ Worker   │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
│  ┌──────────┐  ┌──────────┐                               │
│  │ Search   │  │ Notif    │                               │
│  │ Worker   │  │ Worker   │                               │
│  └──────────┘  └──────────┘                               │
└─────────────────────────────────────────────────────────────┘
```


### Communication Flow

1. **User Action** → Presentation Layer (Provider)
2. **Provider** → Domain Layer (Repository)
3. **Repository** → Data Layer (gRPC DataSource)
4. **DataSource** → gRPC Client (with auth interceptor)
5. **gRPC Client** → Go Backend Service
6. **Response** flows back through the same layers with data transformation

### Key Design Decisions

1. **Unified gRPC Client Manager**: Single manager for all gRPC channels with shared authentication
2. **Per-Service gRPC Clients**: Separate client classes for each business domain (Feed, Post, User, etc.)
3. **Proto-to-Entity Conversion**: Model layer handles conversion between Proto messages and Domain entities
4. **Lazy Initialization**: gRPC clients created on-demand to optimize startup time
5. **Error Handling**: Centralized gRPC error handler with user-friendly messages

## Components and Interfaces

### 1. gRPC Client Manager (Enhanced)

**Location**: `lib/core/grpc/grpc_client.dart`

**Responsibilities**:
- Manage gRPC channel lifecycle
- Provide authentication interceptors
- Handle token refresh
- Centralized error handling

**Interface**:
```dart
class GrpcClientManager {
  ClientChannel get channel;
  Future<CallOptions> getAuthCallOptions();
  T createStub<T>(T Function(ClientChannel, Iterable<ClientInterceptor>) factory);
  Future<void> shutdown();
}
```

**No changes needed** - existing implementation already supports all requirements.

### 2. Feed gRPC Client

**Location**: `lib/core/grpc/feed_grpc_client.dart`

**Responsibilities**:
- Encapsulate all Feed-related gRPC calls
- Handle like/unlike operations
- Manage comments and replies
- Handle repost and bookmark operations

**Interface**:
```dart
class FeedGrpcClient {
  FeedGrpcClient(GrpcClientManager manager);
  
  Future<void> like({required String userId, required String postId});
  Future<void> unlike({required String userId, required String postId});
  Future<Comment> createComment({
    required String authorId,
    required String postId,
    required String content,
    String? parentId,
  });
  Future<void> deleteComment({required String commentId, required String userId});
  Future<ListCommentsResponse> listComments({
    required String postId,
    String? parentId,
    int page = 1,
    int pageSize = 20,
  });
  Future<Repost> repost({
    required String userId,
    required String postId,
    String? quote,
  });
  Future<void> bookmark({required String userId, required String postId});
  Future<void> unbookmark({required String userId, required String postId});
  Future<ListBookmarksResponse> listBookmarks({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
}
```


### 3. Post gRPC Client

**Location**: `lib/core/grpc/post_grpc_client.dart`

**Responsibilities**:
- Handle post CRUD operations
- Support different post types (story, short, column)
- Manage media URLs

**Interface**:
```dart
class PostGrpcClient {
  PostGrpcClient(GrpcClientManager manager);
  
  Future<Post> create({
    required String authorId,
    required PostType postType,
    required String content,
    String? title,
    List<String>? mediaUrls,
  });
  Future<Post> get(String postId);
  Future<ListPostsResponse> list({
    String? authorId,
    PostType? postType,
    int page = 1,
    int pageSize = 20,
  });
  Future<void> delete({required String postId, required String userId});
  Future<Post> update({
    required String postId,
    required String userId,
    String? title,
    String? content,
    List<String>? mediaUrls,
  });
}
```

### 4. User gRPC Client

**Location**: `lib/core/grpc/user_grpc_client.dart`

**Responsibilities**:
- Manage user profile operations
- Handle follow/unfollow relationships
- Retrieve follower/following lists

**Interface**:
```dart
class UserGrpcClient {
  UserGrpcClient(GrpcClientManager manager);
  
  Future<Profile> getProfile(String userId);
  Future<Profile> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
  });
  Future<void> follow({required String followerId, required String followingId});
  Future<void> unfollow({required String followerId, required String followingId});
  Future<FollowListResponse> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
  Future<FollowListResponse> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
  Future<CheckFollowingResponse> checkFollowing({
    required String followerId,
    required String followingId,
  });
}
```

### 5. Search gRPC Client

**Location**: `lib/core/grpc/search_grpc_client.dart`

**Responsibilities**:
- Handle search operations for posts and users
- Support pagination
- Filter by post type

**Interface**:
```dart
class SearchGrpcClient {
  SearchGrpcClient(GrpcClientManager manager);
  
  Future<SearchPostsResponse> searchPosts({
    required String query,
    PostType? postType,
    int page = 1,
    int pageSize = 20,
  });
  Future<SearchUsersResponse> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  });
}
```


### 6. Notification gRPC Client

**Location**: `lib/core/grpc/notification_grpc_client.dart`

**Responsibilities**:
- Retrieve notification lists
- Mark notifications as read
- Get unread count

**Interface**:
```dart
class NotificationGrpcClient {
  NotificationGrpcClient(GrpcClientManager manager);
  
  Future<ListNotificationsResponse> list({
    required String userId,
    bool unreadOnly = false,
    int page = 1,
    int pageSize = 20,
  });
  Future<void> read({required String notificationId, required String userId});
  Future<void> readAll(String userId);
  Future<UnreadCountResponse> getUnreadCount(String userId);
}
```

### 7. gRPC DataSource Implementations

Each feature module will have a gRPC-based DataSource implementation:

**Feed DataSource** (`lib/features/feeds/data/datasources/feed_grpc_datasource.dart`):
```dart
class FeedGrpcDataSourceImpl implements FeedRemoteDataSource {
  FeedGrpcDataSourceImpl(this._grpcClient);
  final FeedGrpcClient _grpcClient;
  
  @override
  Future<List<FeedItemModel>> getFeeds({int page = 1, int pageSize = 20}) async {
    // Implementation uses _grpcClient
  }
  
  @override
  Future<void> likePost(String postId) async {
    // Implementation uses _grpcClient
  }
  
  // ... other methods
}
```

**Post DataSource** (`lib/features/post/data/datasources/post_grpc_datasource.dart`):
```dart
class PostGrpcDataSourceImpl implements PostRemoteDataSource {
  PostGrpcDataSourceImpl(this._grpcClient);
  final PostGrpcClient _grpcClient;
  
  @override
  Future<FeedItemModel> createPost({...}) async {
    // Implementation uses _grpcClient
  }
  
  // ... other methods
}
```

**Profile DataSource** (`lib/features/profile/data/datasources/profile_grpc_datasource.dart`):
```dart
class ProfileGrpcDataSourceImpl implements ProfileRemoteDataSource {
  ProfileGrpcDataSourceImpl(this._grpcClient);
  final UserGrpcClient _grpcClient;
  
  @override
  Future<ProfileModel> getProfile(String userId) async {
    // Implementation uses _grpcClient
  }
  
  // ... other methods
}
```

**Search DataSource** (`lib/features/search/data/datasources/search_grpc_datasource.dart`):
```dart
class SearchGrpcDataSourceImpl implements SearchRemoteDataSource {
  SearchGrpcDataSourceImpl(this._grpcClient);
  final SearchGrpcClient _grpcClient;
  
  @override
  Future<List<FeedItemModel>> searchPosts({...}) async {
    // Implementation uses _grpcClient
  }
  
  // ... other methods
}
```

**Notification DataSource** (`lib/features/notifications/data/datasources/notification_grpc_datasource.dart`):
```dart
class NotificationGrpcDataSourceImpl implements NotificationRemoteDataSource {
  NotificationGrpcDataSourceImpl(this._grpcClient);
  final NotificationGrpcClient _grpcClient;
  
  @override
  Future<List<NotificationModel>> getNotifications({...}) async {
    // Implementation uses _grpcClient
  }
  
  // ... other methods
}
```


## Data Models

### Model Conversion Pattern

Each feature module follows a three-layer data model pattern:

```
Proto Message ←→ Model ←→ Domain Entity
```

**Example: Feed Comment**

```dart
// Proto Message (generated from feed.proto)
message Comment {
  string id = 1;
  string author_id = 2;
  string post_id = 3;
  string content = 4;
  Timestamp created_at = 5;
}

// Model (lib/features/feeds/data/models/comment_model.dart)
class CommentModel {
  final String id;
  final String authorId;
  final String postId;
  final String content;
  final DateTime createdAt;
  
  // Convert from Proto
  factory CommentModel.fromProto(Comment proto) {
    return CommentModel(
      id: proto.id,
      authorId: proto.authorId,
      postId: proto.postId,
      content: proto.content,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        proto.createdAt.seconds.toInt() * 1000,
      ),
    );
  }
  
  // Convert to Proto (for requests)
  Comment toProto() {
    return Comment()
      ..id = id
      ..authorId = authorId
      ..postId = postId
      ..content = content
      ..createdAt = (Timestamp()
        ..seconds = Int64(createdAt.millisecondsSinceEpoch ~/ 1000));
  }
  
  // Convert to Domain Entity
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      authorId: authorId,
      postId: postId,
      content: content,
      createdAt: createdAt,
    );
  }
}
```

### Key Model Classes

**Feed Models**:
- `CommentModel` - Comment data with proto conversion
- `RepostModel` - Repost data with proto conversion
- `BookmarkModel` - Bookmark data with proto conversion

**Post Models**:
- `PostModel` - Post data with proto conversion (already exists, needs proto methods)

**Profile Models**:
- `ProfileModel` - User profile data with proto conversion

**Search Models**:
- Reuses `PostModel` and `ProfileModel`

**Notification Models**:
- `NotificationModel` - Notification data with proto conversion

### Null Safety and Default Values

All model conversions must handle:
- Optional proto fields (use `hasField()` checks)
- Default values for missing data
- Timestamp conversions (proto Timestamp ↔ Dart DateTime)
- Enum conversions (proto enums ↔ Dart enums)

**Example**:
```dart
factory PostModel.fromProto(Post proto) {
  return PostModel(
    id: proto.id,
    authorId: proto.authorId,
    postType: _protoPostTypeToEntity(proto.postType),
    title: proto.hasTitle() ? proto.title : null,  // Handle optional
    content: proto.content,
    mediaUrls: proto.mediaUrls.toList(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      proto.createdAt.seconds.toInt() * 1000,
    ),
    likeCount: proto.likeCount,
    commentCount: proto.commentCount,
  );
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: JWT Token Auto-Injection

*For any* gRPC client (Feed, Post, User, Search, Notification) and any authenticated request, the request metadata SHALL contain a valid JWT token in the "authorization" header with "Bearer " prefix.

**Validates: Requirements 2.7, 3.6, 4.8, 5.5, 6.5**

### Property 2: Pagination Parameter Preservation

*For any* gRPC client method that accepts pagination parameters (page, pageSize), the parameters SHALL be correctly included in the gRPC request message without modification.

**Validates: Requirements 5.4**

### Property 3: Model Round-Trip Conversion

*For any* valid Model instance, converting to Proto and back to Model SHALL produce an equivalent Model instance (toProto → fromProto → equivalent model).

**Validates: Requirements 8.2, 8.4**

### Property 4: Entity Conversion Consistency

*For any* valid Model instance, converting to Entity and back to Model (via fromEntity if it exists) SHALL preserve all domain-relevant fields.

**Validates: Requirements 8.3**

### Property 5: Null Value Handling in Conversions

*For any* Model with optional fields set to null, converting to Proto and back SHALL preserve the null values or convert them to appropriate defaults without throwing exceptions.

**Validates: Requirements 8.5**

### Property 6: GetIt Singleton Behavior

*For any* gRPC client type registered in GetIt, calling getIt<ClientType>() multiple times SHALL return the same instance (referential equality).

**Validates: Requirements 10.2**


## Error Handling

### gRPC Error Mapping

The existing `GrpcErrorHandler` class provides comprehensive error mapping:

| gRPC Status Code | User Message | Action |
|-----------------|--------------|--------|
| UNAUTHENTICATED | "认证失败，请重新登录" | Trigger re-login flow |
| PERMISSION_DENIED | "权限不足" | Show error dialog |
| NOT_FOUND | "资源不存在" | Show error dialog |
| ALREADY_EXISTS | "资源已存在" | Show error dialog |
| INVALID_ARGUMENT | "参数无效: {details}" | Show error dialog |
| UNAVAILABLE | "服务暂时不可用，请稍后重试" | Show retry option |
| DEADLINE_EXCEEDED | "请求超时，请检查网络连接" | Show retry option |
| INTERNAL | "服务器内部错误" | Show error dialog |

### Error Handling Flow

```
gRPC Client Method
    ↓
try-catch GrpcError
    ↓
GrpcErrorHandler.logError()  // Log for debugging
    ↓
GrpcErrorHandler.getErrorMessage()  // Get user-friendly message
    ↓
Return Failure to Repository
    ↓
Repository returns Either<Failure, Data>
    ↓
Provider handles Failure
    ↓
UI shows error message
```

### Retry Logic

For retryable errors (UNAVAILABLE, DEADLINE_EXCEEDED, ABORTED, RESOURCE_EXHAUSTED):
- Use exponential backoff: 1s, 2s, 4s, 8s (max 30s)
- Maximum 3 retry attempts
- Show retry button to user after max attempts

### Token Refresh Flow

```
Request with expired token
    ↓
Backend returns UNAUTHENTICATED
    ↓
GrpcErrorHandler detects expired token
    ↓
Call AuthRepository.refreshToken()
    ↓
If refresh succeeds:
    - Update token in SecureStorage
    - Retry original request
If refresh fails:
    - Clear all tokens
    - Navigate to login screen
```

## Testing Strategy

### Dual Testing Approach

This migration will use both unit tests and property-based tests to ensure comprehensive coverage:

**Unit Tests**:
- Verify specific gRPC client methods call correct RPCs
- Test error handling for specific error codes
- Verify DataSource implementations use gRPC clients
- Test DI registration and retrieval
- Verify specific model conversions with known data

**Property-Based Tests**:
- Verify JWT token injection across all clients and requests
- Test pagination parameter handling with random values
- Verify model round-trip conversions with generated data
- Test null value handling with random optional field combinations
- Verify GetIt singleton behavior

### Property Test Configuration

- **Library**: Use `test` package with custom property test helpers (or `dart_check` if available)
- **Iterations**: Minimum 100 iterations per property test
- **Tagging**: Each property test must reference its design property number
- **Format**: `// Feature: flutter-grpc-migration, Property {N}: {property_text}`

### Test Organization

```
test/
├── core/
│   ├── grpc/
│   │   ├── feed_grpc_client_test.dart
│   │   ├── post_grpc_client_test.dart
│   │   ├── user_grpc_client_test.dart
│   │   ├── search_grpc_client_test.dart
│   │   ├── notification_grpc_client_test.dart
│   │   └── grpc_client_manager_test.dart
│   └── di/
│       └── injection_test.dart
├── features/
│   ├── feeds/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── feed_grpc_datasource_test.dart
│   │   │   └── models/
│   │   │       └── comment_model_test.dart  // Property tests here
│   ├── post/
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── post_grpc_datasource_test.dart
│   │       └── models/
│   │           └── post_model_test.dart  // Property tests here
│   ├── profile/
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── profile_grpc_datasource_test.dart
│   │       └── models/
│   │           └── profile_model_test.dart  // Property tests here
│   ├── search/
│   │   └── data/
│   │       └── datasources/
│   │           └── search_grpc_datasource_test.dart
│   └── notifications/
│       └── data/
│           ├── datasources/
│           │   └── notification_grpc_datasource_test.dart
│           └── models/
│               └── notification_model_test.dart  // Property tests here
└── property_tests/
    ├── jwt_token_injection_test.dart  // Property 1
    ├── pagination_preservation_test.dart  // Property 2
    ├── model_roundtrip_test.dart  // Property 3, 4, 5
    └── singleton_behavior_test.dart  // Property 6
```

### Mock Strategy

- Use `mockito` or `mocktail` for mocking gRPC stubs
- Mock `GrpcClientManager` for testing clients in isolation
- Mock gRPC clients for testing DataSources
- Use `fake_async` for testing retry logic with delays

### Integration Testing

While unit and property tests verify individual components, integration tests should verify:
- End-to-end flow from UI → Provider → Repository → DataSource → gRPC Client
- Token refresh flow with real token expiration
- Error propagation through all layers
- WebSocket + gRPC coexistence (for Chat module)


## Implementation Notes

### Migration Order

The migration should proceed in this order to minimize risk:

1. **Feed Module** - Most complex, includes likes, comments, reposts, bookmarks
2. **Post Module** - Depends on Feed for display
3. **Profile Module** - User data and follow relationships
4. **Search Module** - Depends on Post and Profile models
5. **Notification Module** - Depends on all other modules for notification types
6. **Cleanup** - Remove unused REST API code

### Backward Compatibility Strategy

During migration:
- Keep existing REST-based DataSources alongside new gRPC DataSources
- Use feature flags or environment variables to switch between implementations
- Repositories can fallback to REST if gRPC fails (optional, for safety)
- Remove REST code only after all modules are migrated and tested

### Proto Code Generation

Before implementation, ensure all proto files are generated:

```bash
# Generate Dart code from proto files
cd protos
protoc --dart_out=grpc:../client/mobile_flutter/lib/generated/protos \
  -I. \
  feed/feed.proto \
  post/post.proto \
  user/user.proto \
  search/search.proto \
  notification/notification.proto \
  common/common.proto
```

Generated files will be in:
- `lib/generated/protos/feed/feed.pb.dart`
- `lib/generated/protos/feed/feed.pbgrpc.dart`
- (similar for other modules)

### Dependency Injection Updates

Add to `lib/core/di/injection.dart`:

```dart
// Register new gRPC clients
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

// Update DataSource registrations to use gRPC
getIt.registerLazySingleton<FeedRemoteDataSource>(
  () => FeedGrpcDataSourceImpl(getIt<FeedGrpcClient>()),
);
getIt.registerLazySingleton<PostRemoteDataSource>(
  () => PostGrpcDataSourceImpl(getIt<PostGrpcClient>()),
);
getIt.registerLazySingleton<ProfileRemoteDataSource>(
  () => ProfileGrpcDataSourceImpl(getIt<UserGrpcClient>()),
);
getIt.registerLazySingleton<SearchRemoteDataSource>(
  () => SearchGrpcDataSourceImpl(getIt<SearchGrpcClient>()),
);
getIt.registerLazySingleton<NotificationRemoteDataSource>(
  () => NotificationGrpcDataSourceImpl(getIt<NotificationGrpcClient>()),
);
```

### Performance Considerations

1. **Channel Reuse**: All gRPC clients share the same channel through `GrpcClientManager`
2. **Lazy Initialization**: Clients are created only when first used
3. **Connection Pooling**: gRPC handles connection pooling automatically
4. **Streaming**: Use gRPC streaming for real-time updates (already implemented for Chat)

### Security Considerations

1. **Token Storage**: JWT tokens stored in `FlutterSecureStorage` (iOS Keychain / Android EncryptedSharedPreferences)
2. **Token Transmission**: Tokens sent in metadata, not in message body
3. **TLS**: Production should use `ChannelCredentials.secure()` instead of `insecure()`
4. **Token Refresh**: Automatic refresh on expiration prevents token leakage

### Monitoring and Debugging

1. **Trace IDs**: All requests include `x-trace-id` for distributed tracing
2. **Logging**: `GrpcErrorHandler.logError()` logs all errors with context
3. **Network Inspector**: Use Flutter DevTools Network tab to inspect gRPC calls
4. **Proto Debugging**: Use `UnifiedJsonPrinter` to pretty-print proto messages

### Known Limitations

1. **Web Platform**: gRPC-Web has limitations compared to native gRPC (no bidirectional streaming)
2. **File Upload**: Large file uploads should still use HTTP multipart (keep Dio for this)
3. **Third-Party APIs**: External REST APIs will still use Dio (e.g., image CDN, analytics)

### Future Enhancements

1. **Connection Health Checks**: Periodic health checks to detect connection issues early
2. **Request Caching**: Cache frequently accessed data (e.g., user profiles)
3. **Offline Support**: Queue requests when offline, sync when online
4. **Compression**: Enable gRPC compression for large responses
5. **Load Balancing**: Client-side load balancing for multiple backend instances

