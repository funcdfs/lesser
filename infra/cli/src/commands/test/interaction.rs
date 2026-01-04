//! Interaction 服务测试
//!
//! 测试场景：模拟用户交互行为（点赞、收藏、转发）
//! 1. 创建两个测试用户 Alice 和 Bob
//! 2. Alice 发布一条内容
//! 3. Bob 点赞 Alice 的内容
//! 4. 检查点赞状态
//! 5. Bob 收藏 Alice 的内容
//! 6. Bob 转发 Alice 的内容（带引用）
//! 7. 批量获取交互状态
//! 8. 获取 Bob 的收藏列表
//! 9. Bob 取消点赞
//! 10. Bob 取消收藏
//! 11. Bob 删除转发

use anyhow::Result;

use super::auth;
use super::content;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Interaction 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: Alice 和 Bob 的交互行为");
    println!();

    // 创建两个测试用户
    let alice = auth::create_test_user("inter_alice").await?;
    grpc::delay_short().await;
    let bob = auth::create_test_user("inter_bob").await?;
    grpc::delay_short().await;

    println!("  Alice: {} ({})", alice.username, alice.id);
    println!("  Bob: {} ({})", bob.username, bob.id);
    println!();

    // 1. Alice 发布一条内容
    let content_id = match content::create_test_content(&alice).await {
        Ok(id) => id,
        Err(_) => {
            stats.record(false, "Alice 发布内容");
            auth::cleanup_user(&alice).await;
            auth::cleanup_user(&bob).await;
            return Ok(stats);
        }
    };
    stats.record_with_func(true, "Alice 发布内容", "CreateContent()", "content/handler.go");
    grpc::delay_short().await;

    // 2. Bob 点赞 Alice 的内容
    let result = like_content(&bob, &content_id).await;
    stats.record_with_func(result, "Bob 点赞内容", "Like()", "interaction/handler.go");
    grpc::delay_short().await;

    // 3. 检查点赞状态
    let result = check_liked(&bob, &content_id).await;
    stats.record_with_func(result, "检查点赞状态", "CheckLiked()", "interaction/handler.go");
    grpc::delay_short().await;

    // 4. Bob 收藏 Alice 的内容
    let result = bookmark_content(&bob, &content_id).await;
    stats.record_with_func(result, "Bob 收藏内容", "Bookmark()", "interaction/handler.go");
    grpc::delay_short().await;

    // 5. Bob 转发 Alice 的内容（带引用）
    let result = create_repost(&bob, &content_id, "好内容，分享给大家！").await;
    stats.record_with_func(result, "Bob 转发内容（带引用）", "CreateRepost()", "interaction/handler.go");
    grpc::delay_short().await;

    // 6. 批量获取交互状态
    let result = batch_get_interaction_status(&bob, &[&content_id]).await;
    stats.record_with_func(result, "批量获取交互状态", "BatchGetInteractionStatus()", "interaction/handler.go");
    grpc::delay_short().await;

    // 7. 获取 Bob 的收藏列表
    let result = list_bookmarks(&bob).await;
    stats.record_with_func(result, "获取收藏列表", "ListBookmarks()", "interaction/handler.go");
    grpc::delay_short().await;

    // 8. Bob 取消点赞
    let result = unlike_content(&bob, &content_id).await;
    stats.record_with_func(result, "Bob 取消点赞", "Unlike()", "interaction/handler.go");
    grpc::delay_short().await;

    // 9. Bob 取消收藏
    let result = unbookmark_content(&bob, &content_id).await;
    stats.record_with_func(result, "Bob 取消收藏", "Unbookmark()", "interaction/handler.go");
    grpc::delay_short().await;

    // 10. Bob 删除转发
    let result = delete_repost(&bob, &content_id).await;
    stats.record_with_func(result, "Bob 删除转发", "DeleteRepost()", "interaction/handler.go");

    // 清理
    auth::cleanup_user(&alice).await;
    auth::cleanup_user(&bob).await;

    println!();
    Ok(stats)
}


/// 点赞内容
async fn like_content(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","content_id":"{}"}}"#,
        user.id, content_id
    );

    let result = grpc::call_gateway("interaction.InteractionService/Like", &data, Some(&user.access_token)).await;
    result.contains("success") || result.contains("likeCount") || result.is_empty_success()
}

/// 取消点赞
async fn unlike_content(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","content_id":"{}"}}"#,
        user.id, content_id
    );

    let result = grpc::call_gateway("interaction.InteractionService/Unlike", &data, Some(&user.access_token)).await;
    result.contains("success") || result.contains("likeCount") || result.is_empty_success()
}

/// 检查是否已点赞
async fn check_liked(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","content_id":"{}"}}"#,
        user.id, content_id
    );

    let result = grpc::call_gateway("interaction.InteractionService/CheckLiked", &data, Some(&user.access_token)).await;
    result.contains("isLiked") || result.is_empty_success()
}

/// 收藏内容
async fn bookmark_content(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","content_id":"{}"}}"#,
        user.id, content_id
    );

    let result = grpc::call_gateway("interaction.InteractionService/Bookmark", &data, Some(&user.access_token)).await;
    result.contains("success") || result.contains("bookmarkCount") || result.is_empty_success()
}

/// 取消收藏
async fn unbookmark_content(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","content_id":"{}"}}"#,
        user.id, content_id
    );

    let result = grpc::call_gateway("interaction.InteractionService/Unbookmark", &data, Some(&user.access_token)).await;
    result.contains("success") || result.contains("bookmarkCount") || result.is_empty_success()
}


/// 获取收藏列表
async fn list_bookmarks(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":10}}}}"#,
        user.id
    );

    let result = grpc::call_gateway("interaction.InteractionService/ListBookmarks", &data, Some(&user.access_token)).await;
    result.contains_any(&["bookmarks", "pagination", "{}"]) || result.is_empty_success()
}

/// 创建转发
async fn create_repost(user: &TestUser, content_id: &str, quote: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","content_id":"{}","quote":"{}"}}"#,
        user.id, content_id, quote
    );

    let result = grpc::call_gateway("interaction.InteractionService/CreateRepost", &data, Some(&user.access_token)).await;
    result.contains("repost") || result.contains("repostCount") || result.is_empty_success()
}

/// 删除转发
async fn delete_repost(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","content_id":"{}"}}"#,
        user.id, content_id
    );

    let result = grpc::call_gateway("interaction.InteractionService/DeleteRepost", &data, Some(&user.access_token)).await;
    result.contains("success") || result.contains("repostCount") || result.is_empty_success()
}

/// 批量获取交互状态
async fn batch_get_interaction_status(user: &TestUser, content_ids: &[&str]) -> bool {
    let ids: Vec<String> = content_ids.iter().map(|id| format!(r#""{}""#, id)).collect();
    let data = format!(
        r#"{{"user_id":"{}","content_ids":[{}]}}"#,
        user.id,
        ids.join(",")
    );

    let result = grpc::call_gateway("interaction.InteractionService/BatchGetInteractionStatus", &data, Some(&user.access_token)).await;
    result.contains("statuses") || result.is_empty_success()
}
