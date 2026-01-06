//! Timeline 服务测试
//!
//! 测试场景：模拟用户获取 Feed 流
//! 1. 创建两个测试用户 Alice 和 Bob
//! 2. Alice 关注 Bob
//! 3. Bob 发布一条内容
//! 4. Alice 获取关注用户 Feed
//! 5. 获取 Bob 的用户主页 Feed
//! 6. 获取热门 Feed
//! 7. 获取推荐 Feed
//! 8. 获取内容详情（含交互状态）

use anyhow::Result;

use super::auth;
use super::content;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Timeline 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: Alice 和 Bob 的 Feed 流获取");
    println!();

    // 创建两个测试用户
    let alice = auth::create_test_user("tl_alice").await?;
    grpc::delay_short().await;
    let bob = auth::create_test_user("tl_bob").await?;
    grpc::delay_short().await;

    println!("  Alice: {} ({})", alice.username, alice.id);
    println!("  Bob: {} ({})", bob.username, bob.id);
    println!();

    // 1. Alice 关注 Bob
    let result = follow_user(&alice, &bob.id).await;
    stats.record_with_func(result, "Alice 关注 Bob", "Follow()", "service/user/internal/handler/user_handler.go");
    grpc::delay_short().await;

    // 2. Bob 发布一条内容
    let content_id = match content::create_test_content(&bob).await {
        Ok(id) => id,
        Err(_) => {
            stats.record(false, "Bob 发布内容");
            auth::cleanup_user(&alice).await;
            auth::cleanup_user(&bob).await;
            return Ok(stats);
        }
    };
    stats.record_with_func(true, "Bob 发布内容", "CreateContent()", "service/content/internal/handler/content_handler.go");
    grpc::delay_medium().await;

    // 3. Alice 获取关注用户 Feed
    let result = get_following_feed(&alice).await;
    stats.record_with_func(result, "获取关注用户 Feed", "GetFollowingFeed()", "service/timeline/internal/handler/timeline_handler.go");
    grpc::delay_short().await;

    // 4. 获取 Bob 的用户主页 Feed
    let result = get_user_feed(&alice, &bob.id).await;
    stats.record_with_func(result, "获取用户主页 Feed", "GetUserFeed()", "service/timeline/internal/handler/timeline_handler.go");
    grpc::delay_short().await;

    // 5. 获取热门 Feed
    let result = get_hot_feed(&alice).await;
    stats.record_with_func(result, "获取热门 Feed", "GetHotFeed()", "service/timeline/internal/handler/timeline_handler.go");
    grpc::delay_short().await;

    // 6. 获取推荐 Feed
    let result = get_recommend_feed(&alice).await;
    stats.record_with_func(result, "获取推荐 Feed", "GetRecommendFeed()", "service/timeline/internal/handler/timeline_handler.go");
    grpc::delay_short().await;

    // 7. 获取内容详情（含交互状态）
    let result = get_content_detail(&alice, &content_id).await;
    stats.record_with_func(result, "获取内容详情（含交互状态）", "GetContentDetail()", "service/timeline/internal/handler/timeline_handler.go");

    // 清理
    auth::cleanup_user(&alice).await;
    auth::cleanup_user(&bob).await;

    println!();
    Ok(stats)
}

/// 关注用户
async fn follow_user(user: &TestUser, target_id: &str) -> bool {
    let data = format!(
        r#"{{"follower_id":"{}","following_id":"{}"}}"#,
        user.id, target_id
    );
    let result = grpc::call_gateway("user.UserService/Follow", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}


/// 获取关注用户 Feed
async fn get_following_feed(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":20}}}}"#,
        user.id
    );

    let result = grpc::call_gateway("timeline.TimelineService/GetFollowingFeed", &data, Some(&user.access_token)).await;
    result.contains_any(&["items", "pagination", "{}"]) || result.is_empty_success()
}

/// 获取用户主页 Feed
async fn get_user_feed(viewer: &TestUser, user_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","viewer_id":"{}","pagination":{{"page":1,"page_size":20}}}}"#,
        user_id, viewer.id
    );

    let result = grpc::call_gateway("timeline.TimelineService/GetUserFeed", &data, Some(&viewer.access_token)).await;
    result.contains_any(&["items", "pagination", "{}"]) || result.is_empty_success()
}

/// 获取热门 Feed
async fn get_hot_feed(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":20}},"time_range":"week"}}"#,
        user.id
    );

    let result = grpc::call_gateway("timeline.TimelineService/GetHotFeed", &data, Some(&user.access_token)).await;
    result.contains_any(&["items", "pagination", "{}"]) || result.is_empty_success()
}

/// 获取推荐 Feed
async fn get_recommend_feed(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":20}}}}"#,
        user.id
    );

    let result = grpc::call_gateway("timeline.TimelineService/GetRecommendFeed", &data, Some(&user.access_token)).await;
    result.contains_any(&["items", "pagination", "{}"]) || result.is_empty_success()
}

/// 获取内容详情（含交互状态）
async fn get_content_detail(viewer: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"content_id":"{}","viewer_id":"{}"}}"#,
        content_id, viewer.id
    );

    let result = grpc::call_gateway("timeline.TimelineService/GetContentDetail", &data, Some(&viewer.access_token)).await;
    result.contains("item") || result.contains("content") || result.is_empty_success()
}
