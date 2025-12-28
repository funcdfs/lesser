# Requirements Document

## Introduction

本功能旨在创建一个 Django 和 Go 聊天服务之间 gRPC 通信的完整演示模板。包括创建测试用户、建立好友关系、测试聊天消息发送/接收，以及一个简单的前端页面来展示用户列表和聊天功能。这将作为后续开发中 Django 与 Go 服务间通信的参考模板。

## Glossary

- **Django_Service**: Django 核心服务，负责用户认证、关注关系等核心业务
- **Chat_Service**: Go 聊天服务，负责实时消息处理和 WebSocket 连接
- **Friend_Relationship**: 好友关系，定义为两个用户互相关注
- **gRPC**: 服务间高效通信协议
- **Test_User**: 用于演示的测试用户账户

## Requirements

### Requirement 1: 后端服务启动

**User Story:** As a developer, I want to start all backend services, so that I can test the chat integration.

#### Acceptance Criteria

1. WHEN the developer runs the start command, THE System SHALL start PostgreSQL, Redis, Django, and Chat services
2. WHEN all services are started, THE System SHALL verify database connectivity
3. WHEN services are ready, THE System SHALL apply database migrations

### Requirement 2: 测试用户创建

**User Story:** As a developer, I want to create test users with predefined credentials, so that I can test the chat functionality.

#### Acceptance Criteria

1. WHEN the setup script runs, THE Django_Service SHALL create user "test1" with email "test1@example.com" and password "testtesttest"
2. WHEN the setup script runs, THE Django_Service SHALL create user "test2" with email "test2@example.com" and password "testtesttest"
3. IF a test user already exists, THEN THE Django_Service SHALL skip creation and continue

### Requirement 3: 好友关系建立

**User Story:** As a developer, I want test users to have mutual follow relationships, so that they can chat with each other.

#### Acceptance Criteria

1. WHEN test users are created, THE Django_Service SHALL create a follow relationship from test1 to test2
2. WHEN test users are created, THE Django_Service SHALL create a follow relationship from test2 to test1
3. WHEN both follow relationships exist, THE System SHALL consider them as friends

### Requirement 4: Go 聊天服务测试

**User Story:** As a developer, I want to test the chat service message sending and receiving, so that I can verify the gRPC communication works correctly.

#### Acceptance Criteria

1. WHEN a test is executed, THE Chat_Service SHALL create a private conversation between test1 and test2
2. WHEN test1 sends a message, THE Chat_Service SHALL store the message and return it with a valid ID
3. WHEN messages are retrieved, THE Chat_Service SHALL return all messages in the conversation
4. WHEN the test completes, THE System SHALL verify message content integrity

### Requirement 5: Django 与 Go gRPC 通信

**User Story:** As a developer, I want Django to communicate with Go chat service via gRPC, so that I have a reference template for future development.

#### Acceptance Criteria

1. WHEN Django needs user validation, THE Chat_Service SHALL call Django's gRPC endpoint to validate tokens
2. WHEN creating a conversation, THE Chat_Service SHALL verify user existence through Django
3. THE System SHALL provide clear code examples of gRPC client/server implementation

### Requirement 6: 前端聊天页面

**User Story:** As a developer, I want a simple frontend page showing user list and chat functionality, so that I can visually test the integration.

#### Acceptance Criteria

1. WHEN the page loads, THE Frontend SHALL display a list of users (friends)
2. WHEN a user is selected, THE Frontend SHALL open a chat interface
3. WHEN a message is sent, THE Frontend SHALL call the chat API and display the response
4. WHEN messages are received, THE Frontend SHALL display them in the chat window
5. THE Frontend SHALL use gRPC-Web or REST API to communicate with backend

### Requirement 7: 集成测试脚本

**User Story:** As a developer, I want a script to run the complete integration test, so that I can verify the entire flow works.

#### Acceptance Criteria

1. WHEN the test script runs, THE System SHALL start all services
2. WHEN services are ready, THE System SHALL create test users and relationships
3. WHEN setup is complete, THE System SHALL run chat integration tests
4. WHEN tests complete, THE System SHALL report success or failure with details
