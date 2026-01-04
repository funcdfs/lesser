//! 测试模块
//!
//! 按服务划分的 gRPC API 测试，模拟真实用户行为。
//!
//! ## 模块结构
//!
//! - `runner`: 测试运行器，提供统一的测试执行入口
//! - `database`: 数据库分表验证模块
//! - `rounds`: 测试轮次运行器（三轮测试流程）
//! - `integration`: 服务联动测试模块
//! - `grpc`: gRPC 调用工具（内部使用）
//!
//! ## 服务测试模块
//!
//! - `auth`: Auth 服务测试
//! - `user`: User 服务测试
//! - `content`: Content 服务测试
//! - `comment`: Comment 服务测试
//! - `interaction`: Interaction 服务测试
//! - `timeline`: Timeline 服务测试
//! - `search`: Search 服务测试
//! - `notification`: Notification 服务测试
//! - `chat`: Chat 服务测试
//! - `gateway`: Gateway 服务测试
//! - `superuser`: SuperUser 服务测试

// 内部模块（不对外暴露）
mod grpc;

// 核心模块
mod runner;
pub mod database;
pub mod rounds;
pub mod integration;

// 服务测试模块
pub mod auth;
pub mod chat;
pub mod comment;
pub mod content;
pub mod gateway;
pub mod interaction;
pub mod notification;
pub mod search;
pub mod superuser;
pub mod timeline;
pub mod user;

// ============================================================================
// 公共接口导出
// ============================================================================

// 测试运行器接口
// Requirements: 2.1, 2.2, 2.3, 2.4
pub use runner::{execute, TestTarget};

// 以下导出供外部模块使用，当前模块内部未使用
#[allow(unused_imports)]
pub use runner::{TestStats, TestProgressTracker};
#[allow(unused_imports)]
pub use runner::{init_progress_tracker, update_progress, increment_progress, print_current_progress};

// 测试轮次接口
// Requirements: 3.1-3.6, 4.1-4.7, 5.1-5.5
#[allow(unused_imports)]
pub use rounds::{execute_round, execute_full_test, TestRound, RoundStats, FullTestStats, BugReport};

// 数据库验证接口
// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
#[allow(unused_imports)]
pub use database::{
    verify_database_schema, 
    DatabaseConfig, 
    DatabaseSchema, 
    TableInfo, 
    TableVerificationResult, 
    DatabaseVerificationResult
};

// 联动测试接口
// Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6
#[allow(unused_imports)]
pub use integration::{run_integration_tests, IntegrationScenario, IntegrationResult};
