//! Search 服务测试
//!
//! 测试场景：模拟用户搜索行为
//! 1. 创建测试用户并发布内容
//! 2. 搜索帖子（关键词搜索）
//! 3. 搜索用户
//! 4. 搜索评论
//! 5. 综合搜索（帖子 + 用户 + 评论）
//! 6. 语义搜索（如果支持）

use anyhow::Result;

use super::auth;
use super::content;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Search 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: 用户搜索功能测试");
    println!();

    // 创建测试用户
    let user = auth::create_test_user("search_test").await?;
    grpc::delay_short().await;

    println!("  用户: {} ({})", user.username, user.id);
    println!();

    // 1. 发布一条内容（用于搜索）
    let _ = content::create_test_content(&user).await;
    grpc::delay_medium().await;

    // 2. 搜索帖子
    let result = search_posts(&user, "test").await;
    stats.record(result, "搜索帖子");
    grpc::delay_short().await;

    // 3. 搜索用户
    let result = search_users(&user, "test").await;
    stats.record(result, "搜索用户");
    grpc::delay_short().await;

    // 4. 搜索评论
    let result = search_comments(&user, "test").await;
    stats.record(result, "搜索评论");
    grpc::delay_short().await;

    // 5. 综合搜索
    let result = search_all(&user, "test").await;
    stats.record(result, "综合搜索");
    grpc::delay_short().await;

    // 6. 语义搜索帖子
    let result = search_posts_semantic(&user, "测试内容").await;
    stats.record(result, "语义搜索帖子");

    // 清理
    auth::cleanup_user(&user).await;

    println!();
    Ok(stats)
}

/// 搜索帖子
async fn search_posts(user: &TestUser, query: &str) -> bool {
    let data = format!(
        r#"{{"query":"{}","pagination":{{"page":1,"page_size":10}},"use_semantic":false}}"#,
        query
    );

    let result = grpc::call_gateway("search.SearchService/SearchPosts", &data, Some(&user.access_token)).await;
    result.contains_any(&["posts", "pagination", "{}"]) || result.is_empty_success()
}

/// 语义搜索帖子
async fn search_posts_semantic(user: &TestUser, query: &str) -> bool {
    let data = format!(
        r#"{{"query":"{}","pagination":{{"page":1,"page_size":10}},"use_semantic":true}}"#,
        query
    );

    let result = grpc::call_gateway("search.SearchService/SearchPosts", &data, Some(&user.access_token)).await;
    result.contains_any(&["posts", "pagination", "{}"]) || result.is_empty_success()
}


/// 搜索用户
async fn search_users(user: &TestUser, query: &str) -> bool {
    let data = format!(
        r#"{{"query":"{}","pagination":{{"page":1,"page_size":10}},"use_semantic":false}}"#,
        query
    );

    let result = grpc::call_gateway("search.SearchService/SearchUsers", &data, Some(&user.access_token)).await;
    result.contains_any(&["users", "pagination", "{}"]) || result.is_empty_success()
}

/// 搜索评论
async fn search_comments(user: &TestUser, query: &str) -> bool {
    let data = format!(
        r#"{{"query":"{}","pagination":{{"page":1,"page_size":10}},"use_semantic":false}}"#,
        query
    );

    let result = grpc::call_gateway("search.SearchService/SearchComments", &data, Some(&user.access_token)).await;
    result.contains_any(&["comments", "pagination", "{}"]) || result.is_empty_success()
}

/// 综合搜索
async fn search_all(user: &TestUser, query: &str) -> bool {
    let data = format!(
        r#"{{"query":"{}","limit":10,"use_semantic":false}}"#,
        query
    );

    let result = grpc::call_gateway("search.SearchService/SearchAll", &data, Some(&user.access_token)).await;
    result.contains_any(&["posts", "users", "comments", "{}"]) || result.is_empty_success()
}
