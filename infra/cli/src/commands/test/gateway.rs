//! Gateway 服务测试
//!
//! 测试场景：验证 Gateway 路由转发功能
//! 1. 测试无认证请求（应被拒绝）
//! 2. 测试无效 Token 请求（应被拒绝）
//! 3. 测试有效 Token 请求（应成功）
//! 4. 测试各服务路由是否正常
//! 5. 测试限流功能（可选）

use anyhow::Result;

use super::auth;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Gateway 路由测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: Gateway 路由和认证测试");
    println!();

    // 创建测试用户
    let user = auth::create_test_user("gateway_test").await?;
    grpc::delay_short().await;

    println!("  用户: {} ({})", user.username, user.id);
    println!();

    // 1. 测试无认证请求访问受保护接口（应被拒绝）
    let result = test_unauthenticated_request().await;
    stats.record(result, "无认证请求被拒绝");
    grpc::delay_short().await;

    // 2. 测试无效 Token 请求（应被拒绝）
    let result = test_invalid_token_request().await;
    stats.record(result, "无效 Token 请求被拒绝");
    grpc::delay_short().await;

    // 3. 测试有效 Token 请求（应成功）
    let result = test_valid_token_request(&user).await;
    stats.record(result, "有效 Token 请求成功");
    grpc::delay_short().await;

    // 4. 测试 Auth 服务路由
    let result = test_auth_route().await;
    stats.record(result, "Auth 服务路由正常");
    grpc::delay_short().await;

    // 5. 测试 User 服务路由
    let result = test_user_route(&user).await;
    stats.record(result, "User 服务路由正常");
    grpc::delay_short().await;

    // 6. 测试 Content 服务路由
    let result = test_content_route(&user).await;
    stats.record(result, "Content 服务路由正常");
    grpc::delay_short().await;

    // 7. 测试 Timeline 服务路由
    let result = test_timeline_route(&user).await;
    stats.record(result, "Timeline 服务路由正常");
    grpc::delay_short().await;

    // 8. 测试 Search 服务路由
    let result = test_search_route(&user).await;
    stats.record(result, "Search 服务路由正常");
    grpc::delay_short().await;

    // 9. 测试 Notification 服务路由
    let result = test_notification_route(&user).await;
    stats.record(result, "Notification 服务路由正常");

    // 清理
    auth::cleanup_user(&user).await;

    println!();
    Ok(stats)
}

/// 测试无认证请求
async fn test_unauthenticated_request() -> bool {
    let data = format!(r#"{{"user_id":"test"}}"#);
    let result = grpc::call_gateway("user.UserService/GetProfile", &data, None).await;
    // 应该返回 Unauthenticated 错误
    !result.success || result.contains_any(&["Unauthenticated", "unauthenticated", "token"])
}


/// 测试无效 Token 请求
async fn test_invalid_token_request() -> bool {
    let data = format!(r#"{{"user_id":"test"}}"#);
    let result = grpc::call_gateway("user.UserService/GetProfile", &data, Some("invalid_token_12345")).await;
    // 应该返回认证错误
    !result.success || result.contains_any(&["Unauthenticated", "invalid", "token", "expired"])
}

/// 测试有效 Token 请求
async fn test_valid_token_request(user: &TestUser) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user.id);
    let result = grpc::call_gateway("user.UserService/GetProfile", &data, Some(&user.access_token)).await;
    result.contains("username")
}

/// 测试 Auth 服务路由（公开接口）
async fn test_auth_route() -> bool {
    let result = grpc::call_gateway("auth.AuthService/GetPublicKey", "{}", None).await;
    result.contains_any(&["publicKey", "public_key"])
}

/// 测试 User 服务路由
async fn test_user_route(user: &TestUser) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user.id);
    let result = grpc::call_gateway("user.UserService/GetProfile", &data, Some(&user.access_token)).await;
    result.success || result.contains("username")
}

/// 测试 Content 服务路由
async fn test_content_route(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"author_id":"{}","pagination":{{"page":1,"page_size":10}}}}"#,
        user.id
    );
    let result = grpc::call_gateway("content.ContentService/ListContents", &data, Some(&user.access_token)).await;
    result.contains_any(&["contents", "pagination", "{}"]) || result.is_empty_success()
}

/// 测试 Timeline 服务路由
async fn test_timeline_route(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":10}}}}"#,
        user.id
    );
    let result = grpc::call_gateway("timeline.TimelineService/GetFollowingFeed", &data, Some(&user.access_token)).await;
    result.contains_any(&["items", "pagination", "{}"]) || result.is_empty_success()
}


/// 测试 Search 服务路由
async fn test_search_route(user: &TestUser) -> bool {
    let data = r#"{"query":"test","pagination":{"page":1,"page_size":10}}"#;
    let result = grpc::call_gateway("search.SearchService/SearchPosts", data, Some(&user.access_token)).await;
    result.contains_any(&["posts", "pagination", "{}"]) || result.is_empty_success()
}

/// 测试 Notification 服务路由
async fn test_notification_route(user: &TestUser) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user.id);
    let result = grpc::call_gateway("notification.NotificationService/GetUnreadCount", &data, Some(&user.access_token)).await;
    result.contains("count") || result.is_empty_success()
}
