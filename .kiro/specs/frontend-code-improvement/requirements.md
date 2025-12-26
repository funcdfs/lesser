# Requirements Document

## Introduction

本文档定义了 Flutter 前端代码库的完善计划需求。基于对现有代码的全面分析，识别出多个需要改进的领域，包括代码质量问题、缺失功能、测试覆盖不足等。本计划旨在系统性地解决这些问题，提升代码质量和可维护性。

## Glossary

- **Frontend_System**: Flutter 前端应用程序，包含所有 UI 组件、状态管理和网络层
- **Riverpod_Provider**: 使用 Riverpod 框架创建的状态管理提供者
- **Repository**: 数据访问层，负责与 API 交互并处理数据转换
- **Freezed_Model**: 使用 Freezed 库创建的不可变数据模型
- **Auth_Module**: 用户认证模块，包含登录、注册、登出功能
- **Feeds_Module**: 动态流模块，包含帖子列表、详情、创建功能
- **Chat_Module**: 聊天模块，包含消息列表和聊天功能
- **Search_Module**: 搜索模块，包含搜索功能和热门标签
- **Settings_Module**: 设置模块，包含用户资料和应用设置

## Requirements

### Requirement 1: 修复 Riverpod API 弃用警告

**User Story:** 作为开发者，我希望代码使用最新的 Riverpod API，以避免未来版本升级时的兼容性问题。

#### Acceptance Criteria

1. WHEN 使用 `@riverpod` 注解定义 Provider THEN Frontend_System SHALL 使用 `Ref` 类型替代已弃用的特定 Ref 类型（如 `ApiClientRef`、`UserRepositoryRef`）
2. WHEN 代码分析工具运行 THEN Frontend_System SHALL 不产生任何 `deprecated_member_use_from_same_package` 警告

### Requirement 2: 修复 Freezed 模型 JsonKey 注解问题

**User Story:** 作为开发者，我希望 Freezed 模型正确使用 JsonKey 注解，以确保 JSON 序列化/反序列化正常工作。

#### Acceptance Criteria

1. WHEN 定义 Freezed 模型 THEN Frontend_System SHALL 将 `@JsonKey` 注解放置在 factory 构造函数的参数上
2. WHEN 代码分析工具运行 THEN Frontend_System SHALL 不产生任何 `invalid_annotation_target` 警告
3. FOR ALL Freezed 模型，序列化后再反序列化 SHALL 产生等价的对象（round-trip property）

### Requirement 3: 统一错误处理机制

**User Story:** 作为开发者，我希望有统一的错误处理机制，以便在整个应用中一致地处理和展示错误。

#### Acceptance Criteria

1. THE Repository 层 SHALL 定义统一的异常类型层次结构
2. WHEN API 调用失败 THEN Repository SHALL 抛出具有明确错误类型和消息的自定义异常
3. WHEN Provider 捕获异常 THEN Frontend_System SHALL 将错误转换为用户友好的消息
4. IF 网络连接失败 THEN Frontend_System SHALL 显示网络错误提示并提供重试选项
5. IF 认证令牌过期 THEN Frontend_System SHALL 自动登出用户并导航到登录页面

### Requirement 4: 完善输入验证

**User Story:** 作为用户，我希望在输入无效数据时获得即时反馈，以便快速纠正错误。

#### Acceptance Criteria

1. WHEN 用户输入邮箱 THEN Frontend_System SHALL 验证邮箱格式符合标准邮箱正则表达式
2. WHEN 用户输入用户名 THEN Frontend_System SHALL 验证用户名长度在 3-20 字符之间且只包含字母数字和下划线
3. WHEN 用户输入密码 THEN Frontend_System SHALL 验证密码长度至少 8 字符
4. WHEN 验证失败 THEN Frontend_System SHALL 在对应输入框下方显示具体的错误消息
5. WHEN 用户提交空白内容的帖子 THEN Frontend_System SHALL 阻止提交并显示错误提示

### Requirement 5: 完善路由系统

**User Story:** 作为用户，我希望能够通过 URL 直接访问应用的各个页面，以便分享链接和使用浏览器导航。

#### Acceptance Criteria

1. THE Frontend_System SHALL 为所有主要页面定义命名路由
2. WHEN 用户未登录访问受保护页面 THEN Frontend_System SHALL 重定向到登录页面
3. WHEN 用户登录成功 THEN Frontend_System SHALL 导航到之前尝试访问的页面或主页
4. THE Frontend_System SHALL 支持深度链接（Deep Linking）
5. WHEN 路由不存在 THEN Frontend_System SHALL 显示 404 页面

### Requirement 6: 实现聊天功能

**User Story:** 作为用户，我希望能够与其他用户进行实时聊天，以便进行即时通讯。

#### Acceptance Criteria

1. THE Chat_Module SHALL 连接到后端 WebSocket 服务
2. WHEN 用户发送消息 THEN Frontend_System SHALL 立即在本地显示消息并发送到服务器
3. WHEN 收到新消息 THEN Frontend_System SHALL 实时更新聊天界面
4. WHEN 网络断开 THEN Frontend_System SHALL 显示连接状态并在恢复后自动重连
5. THE Chat_Module SHALL 支持消息的本地持久化

### Requirement 7: 实现搜索功能

**User Story:** 作为用户，我希望能够搜索用户和内容，以便快速找到感兴趣的信息。

#### Acceptance Criteria

1. WHEN 用户输入搜索关键词 THEN Frontend_System SHALL 调用搜索 API 并显示结果
2. THE Search_Module SHALL 支持搜索用户、帖子和标签
3. WHEN 搜索结果为空 THEN Frontend_System SHALL 显示友好的空状态提示
4. THE Search_Module SHALL 显示搜索历史记录
5. THE Search_Module SHALL 支持热门搜索推荐

### Requirement 8: 完善设置功能

**User Story:** 作为用户，我希望能够管理我的账户设置和应用偏好，以便个性化使用体验。

#### Acceptance Criteria

1. THE Settings_Module SHALL 支持修改用户资料（头像、昵称、简介）
2. THE Settings_Module SHALL 支持修改密码
3. THE Settings_Module SHALL 支持应用主题切换（浅色/深色/跟随系统）
4. WHEN 用户点击登出 THEN Frontend_System SHALL 清除本地令牌并导航到登录页面
5. THE Settings_Module SHALL 持久化用户偏好设置

### Requirement 9: 增加测试覆盖

**User Story:** 作为开发者，我希望有全面的测试覆盖，以确保代码质量和防止回归。

#### Acceptance Criteria

1. THE Frontend_System SHALL 为所有 Repository 类编写单元测试
2. THE Frontend_System SHALL 为所有 Provider 编写单元测试
3. THE Frontend_System SHALL 为关键 Widget 编写 Widget 测试
4. THE Frontend_System SHALL 为数据模型编写属性测试（Property-Based Tests）
5. WHEN 运行测试套件 THEN 代码覆盖率 SHALL 达到至少 70%

### Requirement 10: 清理代码和移除未使用导入

**User Story:** 作为开发者，我希望代码库保持整洁，没有未使用的代码和导入。

#### Acceptance Criteria

1. WHEN 代码分析工具运行 THEN Frontend_System SHALL 不产生任何 `unused_import` 警告
2. THE Frontend_System SHALL 移除所有未使用的变量和函数
3. THE Frontend_System SHALL 统一代码风格和命名规范
4. THE Frontend_System SHALL 为复杂逻辑添加文档注释

### Requirement 11: 统一主题系统

**User Story:** 作为开发者，我希望有统一的主题系统，以确保 UI 一致性和便于维护。

#### Acceptance Criteria

1. THE Frontend_System SHALL 合并 `app_theme.dart` 和 `shared/theme/theme.dart` 为单一主题定义
2. THE Frontend_System SHALL 使用设计令牌（Design Tokens）定义所有颜色、间距、圆角等
3. WHEN 切换主题 THEN 所有 UI 组件 SHALL 正确响应主题变化
4. THE Frontend_System SHALL 支持自定义主题扩展

### Requirement 12: 移除硬编码值

**User Story:** 作为开发者，我希望配置值可以通过环境变量或配置文件管理，以便在不同环境间切换。

#### Acceptance Criteria

1. THE Frontend_System SHALL 从环境配置读取 API 基础 URL
2. THE Frontend_System SHALL 从配置读取调试模式开关
3. THE Frontend_System SHALL 将所有魔法数字提取为命名常量
4. WHEN 切换环境 THEN Frontend_System SHALL 无需修改代码即可使用不同配置
