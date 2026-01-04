# Requirements Document

## Introduction

本文档定义了 CLI 服务测试流程的需求，包括数据库分表验证、服务测试、以及三轮完整测试流程。目标是确保所有服务在不同场景下（初始化、删除重建、重启）都能正常工作，并通过 CLI 统一入口进行测试管理。

## Glossary

- **CLI**: Command Line Interface，命令行工具 `devlesser`，位于 `infra/cli/`
- **Service**: 后端微服务，包括 Auth、User、Content、Interaction、Comment、Timeline、Search、Notification、Chat、SuperUser、Gateway
- **lesser_db**: 主数据库，存储用户、内容、交互、评论、通知等数据
- **lesser_chat_db**: 聊天数据库，存储会话和消息数据
- **Test_Round**: 测试轮次，包括初始化测试、删除重建测试、重启测试
- **Service_Test**: 单个服务的 API 测试
- **Integration_Test**: 多服务联动测试

## Requirements

### Requirement 1: 数据库分表验证

**User Story:** As a developer, I want to verify that database tables are correctly partitioned, so that each service uses the correct tables.

#### Acceptance Criteria

1. THE CLI SHALL verify that `lesser_db` contains user tables (users, follows, blocks, user_privacy_settings, user_notification_settings, follow_requests, superusers, superuser_audit_logs, superuser_sessions)
2. THE CLI SHALL verify that `lesser_db` contains content tables (contents, likes, bookmarks, reposts, comments, comment_likes)
3. THE CLI SHALL verify that `lesser_chat_db` contains chat tables (conversations, conversation_members, messages, message_reads)
4. WHEN a table is missing, THE CLI SHALL report the missing table name and database
5. THE CLI SHALL verify that all services connect to the correct database for their tables

### Requirement 2: CLI 测试命令统一入口

**User Story:** As a developer, I want to use CLI as the single entry point for all tests, so that I don't need scattered shell scripts.

#### Acceptance Criteria

1. THE CLI SHALL provide `devlesser test all` command to run all service tests
2. THE CLI SHALL provide `devlesser test <service>` command to run individual service tests
3. THE CLI SHALL provide `devlesser test integration` command to run cross-service integration tests
4. THE CLI SHALL provide `devlesser test round <1|2|3>` command to run specific test rounds
5. WHEN running tests, THE CLI SHALL display progress and results in a clear format
6. IF a test fails, THEN THE CLI SHALL report the failure details and continue with remaining tests

### Requirement 3: 第一轮测试 - 初始化启动测试

**User Story:** As a developer, I want to test services after fresh initialization, so that I can verify the initial setup works correctly.

#### Acceptance Criteria

1. WHEN running round 1, THE CLI SHALL execute `devlesser init` to initialize the environment
2. WHEN running round 1, THE CLI SHALL execute `devlesser start` to start all services
3. WHEN running round 1, THE CLI SHALL wait for all services to be healthy before testing
4. WHEN running round 1, THE CLI SHALL test each service individually (Auth, User, Content, Interaction, Comment, Timeline, Search, Notification, Chat, SuperUser, Gateway)
5. WHEN running round 1, THE CLI SHALL test service integration scenarios
6. THE CLI SHALL record test results for round 1

### Requirement 4: 第二轮测试 - 删除重建测试

**User Story:** As a developer, I want to test services after clean rebuild, so that I can verify the system can be rebuilt from scratch.

#### Acceptance Criteria

1. WHEN running round 2, THE CLI SHALL execute `devlesser stop` to stop all services
2. WHEN running round 2, THE CLI SHALL execute `devlesser clean volumes` to delete all data
3. WHEN running round 2, THE CLI SHALL execute `devlesser start` to rebuild and start services
4. WHEN running round 2, THE CLI SHALL wait for all services to be healthy before testing
5. WHEN running round 2, THE CLI SHALL test each service individually
6. WHEN running round 2, THE CLI SHALL test service integration scenarios
7. THE CLI SHALL record test results for round 2

### Requirement 5: 第三轮测试 - 重启测试

**User Story:** As a developer, I want to test services after restart, so that I can verify the system handles restarts correctly.

#### Acceptance Criteria

1. WHEN running round 3, THE CLI SHALL execute `devlesser restart` to restart all services
2. WHEN running round 3, THE CLI SHALL wait for all services to be healthy before testing
3. WHEN running round 3, THE CLI SHALL test each service individually
4. WHEN running round 3, THE CLI SHALL test service integration scenarios
5. THE CLI SHALL record test results for round 3

### Requirement 6: 单服务测试

**User Story:** As a developer, I want to test each service's API endpoints, so that I can verify individual service functionality.

#### Acceptance Criteria

1. THE Auth_Test SHALL test register, login, refresh token, logout, and ban operations
2. THE User_Test SHALL test profile CRUD, follow/unfollow, block/unblock, and settings operations
3. THE Content_Test SHALL test create, read, update, delete, and list content operations
4. THE Interaction_Test SHALL test like, bookmark, repost operations
5. THE Comment_Test SHALL test create, read, delete, like comment operations
6. THE Timeline_Test SHALL test feed retrieval (following, user, hot, recommended)
7. THE Search_Test SHALL test user and content search operations
8. THE Notification_Test SHALL test notification list, mark read, unread count operations
9. THE Chat_Test SHALL test conversation CRUD, message send/receive, member management
10. THE SuperUser_Test SHALL test admin login, user management, content moderation, system monitoring
11. THE Gateway_Test SHALL test routing, authentication, and rate limiting

### Requirement 7: 服务联动测试

**User Story:** As a developer, I want to test cross-service scenarios, so that I can verify services work together correctly.

#### Acceptance Criteria

1. THE Integration_Test SHALL test user registration → login → create content → interact flow
2. THE Integration_Test SHALL test content creation → comment → notification flow
3. THE Integration_Test SHALL test user follow → timeline update flow
4. THE Integration_Test SHALL test chat conversation creation → message exchange flow
5. THE Integration_Test SHALL test superuser moderation → user/content state change flow
6. IF any service in the flow fails, THEN THE Integration_Test SHALL report which service caused the failure

### Requirement 8: 测试结果报告

**User Story:** As a developer, I want to see comprehensive test results, so that I can identify and fix issues.

#### Acceptance Criteria

1. THE CLI SHALL display test progress in real-time
2. THE CLI SHALL display a summary after each test round
3. THE CLI SHALL display a final summary comparing all three rounds
4. WHEN tests fail, THE CLI SHALL provide detailed error messages
5. THE CLI SHALL exit with non-zero code if any test fails

### Requirement 9: Bug 修复记录

**User Story:** As a developer, I want bugs found during testing to be fixed, so that the system becomes stable.

#### Acceptance Criteria

1. WHEN a CLI bug is found, THE developer SHALL fix it and document the fix
2. WHEN a service bug is found, THE developer SHALL fix it and document the fix
3. THE CLI SHALL provide a `--fix` flag to attempt automatic fixes for known issues
4. THE CLI SHALL log all bugs encountered during testing

