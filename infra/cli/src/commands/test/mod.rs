//! 测试模块
//!
//! 按服务划分的 gRPC API 测试，模拟真实用户行为

mod grpc;
mod runner;

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

pub use runner::{execute, TestTarget};
