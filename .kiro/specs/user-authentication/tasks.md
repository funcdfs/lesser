# Implementation Plan: User Authentication

## Overview

本实现计划将用户认证功能分解为可执行的编码任务，涵盖后端 API 修复、前端状态管理、API 网关配置和测试。任务按依赖顺序排列，确保增量开发和验证。

## Tasks

- [x] 1. Fix Backend Authentication APIs
  - [x] 1.1 Fix RegisterAPI to handle password field names correctly
    - 修改 `backend/django_code/app/users/views.py` 中的 RegisterAPI
    - 支持 `password` 字段（前端发送）和 `password1/password2` 字段（兼容）
    - 添加输入验证和错误处理
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  - [x] 1.2 Fix LoginAPI to use correct authentication method
    - 修改 LoginAPI 使用 `authenticate()` 而非 `AuthenticationForm`
    - 支持 JSON 请求体中的 `username` 和 `password` 字段
    - 返回标准化的错误响应
    - _Requirements: 2.1, 2.2, 2.3_
  - [x] 1.3 Fix LogoutAPI to handle missing token gracefully
    - 添加 token 存在性检查
    - 返回标准化的成功/错误响应
    - _Requirements: 3.1_
  - [x] 1.4 Write property tests for backend authentication
    - **Property 2: Password Mismatch Rejection**
    - **Property 3: Empty Field Validation Rejection**
    - **Validates: Requirements 1.2, 1.4, 2.3**

- [x] 2. Configure APISIX API Gateway Routes
  - [x] 2.1 Add user authentication routes to APISIX
    - 通过 APISIX Admin API 配置 `/api/users/*` 路由
    - 精简 apisix 使用的中间件以及功能。现在要做的是最小化流程跑通任务。
    - 配置上游服务指向 Django 后端
    - 启用 CORS 插件
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 3. Checkpoint - Verify Backend and Gateway
  - Ensure backend APIs work via APISIX gateway
  - Test with curl or Postman: register, login, logout
  - Ask the user if questions arise

- [x] 4. Create Frontend Auth Provider
  - [x] 4.1 Create AuthState model with Freezed
    - 创建 `lib/features/auth/domain/models/auth_state.dart`
    - 定义 initial, loading, authenticated, unauthenticated, error 状态
    - _Requirements: 5.1, 5.2, 5.3_
  - [x] 4.2 Create AuthProvider with Riverpod
    - 创建 `lib/features/auth/presentation/providers/auth_provider.dart`
    - 实现 login, register, logout, checkAuthStatus 方法
    - 集成 TokenManager 和 ApiClient
    - _Requirements: 1.5, 1.6, 2.4, 2.5, 3.2, 3.3, 5.1, 5.2, 5.3, 5.4_
  - [x] 4.3 Create AuthRepository
    - 创建 `lib/features/auth/data/auth_repository.dart`
    - 封装 API 调用和错误处理
    - _Requirements: 7.1, 7.2, 7.3_
  - [x] 4.4 Write property test for token round-trip
    - **Property 8: Token Round-Trip**
    - **Validates: Requirements 6.3**

- [-] 5. Update Frontend Login Screen
  - [ ] 5.1 Update LoginScreen to use AuthProvider
    - 修改 `lib/features/auth/presentation/screens/login_screen.dart`
    - 使用 AuthProvider 替代直接 API 调用
    - 添加错误显示和加载状态
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 7.1, 7.2_

- [-] 6. Update Frontend Register Screen
  - [ ] 6.1 Update RegisterScreen to use AuthProvider
    - 修改 `lib/features/auth/presentation/screens/register_screen.dart`
    - 使用 AuthProvider 替代直接 API 调用
    - 添加密码确认验证
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 7.1, 7.2_

- [ ] 7. Implement App Startup Auth Check
  - [ ] 7.1 Add auth check to app initialization
    - 修改 `lib/main.dart` 或创建 SplashScreen
    - 检查本地 token 并决定初始路由
    - _Requirements: 5.1, 5.2, 5.3_
  - [ ] 7.2 Add 401 interceptor to API client
    - 修改 `lib/core/network/api_client.dart`
    - 添加响应拦截器处理 401 状态码
    - 自动清除 token 并导航到登录页
    - _Requirements: 5.4_

- [ ] 8. Implement Logout Functionality
  - [ ] 8.1 Add logout button to profile screen
    - 在用户资料页添加退出登录按钮
    - 调用 AuthProvider.logout()
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 9. Checkpoint - Test Full Authentication Flow
  - Ensure all tests pass
  - Test complete flow: register → login → logout
  - Test auto-login on app restart
  - Ask the user if questions arise

- [ ] 10. Write Integration Tests
  - [ ] 10.1 Write frontend integration tests
    - 测试完整的注册流程
    - 测试完整的登录流程
    - 测试退出登录流程
    - _Requirements: 1.1-1.6, 2.1-2.5, 3.1-3.4_
  - [ ] 10.2 Write backend integration tests
    - 测试 API 端点的完整流程
    - 测试 token 认证
    - _Requirements: 1.1-1.6, 2.1-2.5, 3.1-3.4_

- [ ] 11. Final Checkpoint
  - Ensure all tests pass
  - Verify all requirements are met
  - Ask the user if questions arise

## Notes

- All tasks are required for complete implementation
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Backend uses Python/Django, Frontend uses Dart/Flutter
