# Requirements Document

## Introduction

构建一个类似 X.com (Twitter) 的社交平台脚手架，包含完整的前后端架构、开发环境配置和部署脚本。平台支持 Feeds 流、搜索、多类型帖子发布、消息通知和用户管理等核心功能模块。

## Glossary

- **Platform**: 整个社交平台系统
- **Dev_Script**: 开发环境启动脚本 (dev.sh)
- **Prod_Script**: 生产环境启动脚本 (prod.sh)
- **Service_Stack**: 后端服务集合 (Django, Go, C++, Rust)
- **Client_Stack**: 前端客户端集合 (Flutter, React)
- **Gateway**: Traefik 反向代理网关
- **Auth_Service**: Django 认证服务
- **Feed_Service**: Feeds 流服务
- **Post_Service**: 帖子管理服务
- **Chat_Service**: 聊天消息服务
- **Notification_Service**: 通知服务
- **Search_Service**: 搜索服务

## Requirements

### Requirement 1: 开发脚本统一入口

**User Story:** As a developer, I want a unified entry script, so that I can easily start different parts of the system with simple commands.

#### Acceptance Criteria

1. WHEN a developer runs `./dev.sh start service`, THE Dev_Script SHALL start all backend services and databases in development mode
2. WHEN a developer runs `./dev.sh start client`, THE Dev_Script SHALL start all frontend clients (Flutter web, React)
3. WHEN a developer runs `./dev.sh start`, THE Dev_Script SHALL start both services and clients for integrated debugging
4. WHEN a developer runs `./dev.sh stop`, THE Dev_Script SHALL gracefully stop all running containers and processes
5. WHEN a developer runs `./dev.sh logs [service]`, THE Dev_Script SHALL display logs for specified or all services
6. THE Dev_Script SHALL use development environment variables from `.env.dev`

### Requirement 2: 生产环境脚本

**User Story:** As a DevOps engineer, I want a production deployment script, so that I can deploy the platform to production safely.

#### Acceptance Criteria

1. WHEN an operator runs `./prod.sh start`, THE Prod_Script SHALL start all services in production mode with optimized configurations
2. WHEN an operator runs `./prod.sh stop`, THE Prod_Script SHALL gracefully stop all production services
3. THE Prod_Script SHALL use production environment variables from `.env.prod`
4. THE Prod_Script SHALL validate all required environment variables before starting

### Requirement 3: Docker 基础设施

**User Story:** As a developer, I want containerized infrastructure, so that I can have consistent development and production environments.

#### Acceptance Criteria

1. THE Platform SHALL use Docker Compose for orchestrating all services
2. THE Platform SHALL use Traefik (latest stable version) as the API gateway and reverse proxy
3. THE Platform SHALL use PostgreSQL (latest stable version) as the primary database
4. THE Platform SHALL use Redis (latest stable version) for caching and message queuing
5. WHEN services are started, THE Gateway SHALL route requests to appropriate backend services based on path prefixes
6. THE Platform SHALL support hot-reload for development mode

### Requirement 4: 认证服务 (Auth Service)

**User Story:** As a user, I want to register, login and logout, so that I can securely access the platform.

#### Acceptance Criteria

1. THE Auth_Service SHALL be implemented using Django with Django REST Framework
2. THE Auth_Service SHALL provide user registration endpoint
3. THE Auth_Service SHALL provide user login endpoint with JWT token generation
4. THE Auth_Service SHALL provide user logout endpoint with token invalidation
5. THE Auth_Service SHALL provide token refresh endpoint
6. THE Auth_Service SHALL store user credentials securely with password hashing

### Requirement 5: Feeds 服务架构

**User Story:** As a developer, I want a scalable feeds service architecture, so that I can handle high-volume feed operations.

#### Acceptance Criteria

1. THE Feed_Service SHALL support retrieving paginated feed items
2. THE Feed_Service SHALL support like, repost, comment, bookmark, and share operations
3. THE Feed_Service SHALL be designed for future migration to high-performance languages (Go/Rust/C++)
4. THE Feed_Service SHALL integrate with Redis for feed caching

### Requirement 6: 帖子服务架构

**User Story:** As a user, I want to create different types of posts, so that I can share content in various formats.

#### Acceptance Criteria

1. THE Post_Service SHALL support three post types: Story (24h auto-delete), Short Text, and Column (long-form)
2. THE Post_Service SHALL automatically delete Story posts after 24 hours
3. THE Post_Service SHALL validate post content based on type-specific rules
4. THE Post_Service SHALL store posts in PostgreSQL with appropriate indexing

### Requirement 7: 搜索服务架构

**User Story:** As a user, I want to search for articles and posts, so that I can find relevant content.

#### Acceptance Criteria

1. THE Search_Service SHALL provide full-text search for posts and articles
2. THE Search_Service SHALL support filtering by post type, date range, and author
3. THE Search_Service SHALL return paginated search results

### Requirement 8: 通知服务架构

**User Story:** As a user, I want to receive notifications, so that I can stay updated on interactions with my content.

#### Acceptance Criteria

1. THE Notification_Service SHALL track likes, comments, replies, bookmarks, and mentions
2. THE Notification_Service SHALL track new followers
3. THE Notification_Service SHALL support real-time notification delivery via WebSocket

### Requirement 9: 聊天服务架构

**User Story:** As a user, I want to chat with others, so that I can communicate privately or in groups.

#### Acceptance Criteria

1. THE Chat_Service SHALL support private chat (1:1)
2. THE Chat_Service SHALL support group chat (multiple users)
3. THE Chat_Service SHALL support channel chat (broadcast to subscribers)
4. THE Chat_Service SHALL be implemented in Go for high-performance WebSocket handling
5. THE Chat_Service SHALL persist messages to PostgreSQL

### Requirement 10: Flutter 移动客户端架构

**User Story:** As a mobile user, I want a well-structured Flutter app, so that I can use the platform on mobile devices.

#### Acceptance Criteria

1. THE Flutter_Client SHALL follow feature-first architecture with clear separation of concerns
2. THE Flutter_Client SHALL include navigation module with bottom navigation bar (5 tabs)
3. THE Flutter_Client SHALL include feeds module for viewing and interacting with posts
4. THE Flutter_Client SHALL include search module for content discovery
5. THE Flutter_Client SHALL include post creation module with type selection
6. THE Flutter_Client SHALL include notifications module for messages and alerts
7. THE Flutter_Client SHALL include profile/settings module for user management
8. THE Flutter_Client SHALL use Riverpod for state management

### Requirement 11: React Web 客户端架构

**User Story:** As a web user, I want a responsive React web app, so that I can use the platform on desktop browsers.

#### Acceptance Criteria

1. THE React_Client SHALL use Next.js for server-side rendering and routing
2. THE React_Client SHALL mirror the Flutter client's feature structure
3. THE React_Client SHALL use TypeScript for type safety
4. THE React_Client SHALL use TailwindCSS for styling

### Requirement 12: 环境配置管理

**User Story:** As a developer, I want separate environment configurations, so that I can safely develop without affecting production.

#### Acceptance Criteria

1. THE Platform SHALL maintain separate `.env.dev` and `.env.prod` configuration files
2. THE Platform SHALL not commit sensitive credentials to version control
3. THE Platform SHALL provide `.env.example` templates for both environments
4. WHEN environment variables are missing, THE Platform SHALL fail with clear error messages
