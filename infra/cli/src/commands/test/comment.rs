//! Comment 服务测试
//!
//! 测试场景：模拟用户评论互动
//! 1. 创建两个测试用户 Alice 和 Bob
//! 2. Alice 发布一条内容
//! 3. Bob 对内容发表评论
//! 4. Alice 回复 Bob 的评论
//! 5. 获取评论列表（不同排序方式）
//! 6. Bob 点赞 Alice 的回复
//! 7. 获取评论数量
//! 8. Bob 取消点赞
//! 9. Alice 删除自己的回复
//! 10. Bob 删除自己的评论

use anyhow::Result;

use super::auth;
use super::content;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Comment 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: Alice 和 Bob 的评论互动");
    println!();

    // 创建两个测试用户
    let alice = auth::create_test_user("comment_alice").await?;
    grpc::delay_short().await;
    let bob = auth::create_test_user("comment_bob").await?;
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

    // 2. Bob 对内容发表评论
    let (success, bob_comment_id) = create_comment(&bob, &content_id, "", "这篇内容写得真好！👍").await;
    stats.record_with_func(success, "Bob 发表评论", "CreateComment()", "service/comment/internal/handler/comment_handler.go");
    grpc::delay_short().await;

    // 3. Alice 回复 Bob 的评论
    let (success, alice_reply_id) = if !bob_comment_id.is_empty() {
        create_comment(&alice, &content_id, &bob_comment_id, "谢谢你的支持！😊").await
    } else {
        (false, String::new())
    };
    stats.record_with_func(success, "Alice 回复 Bob 的评论", "CreateComment()", "service/comment/internal/handler/comment_handler.go");
    grpc::delay_short().await;

    // 4. 获取评论列表（最新优先）
    let result = list_comments(&alice, &content_id, 2).await;
    stats.record_with_func(result, "获取评论列表（最新优先）", "ListComments()", "service/comment/internal/handler/comment_handler.go");
    grpc::delay_short().await;

    // 5. 获取评论列表（最热门）
    let result = list_comments(&alice, &content_id, 3).await;
    stats.record_with_func(result, "获取评论列表（最热门）", "ListComments()", "service/comment/internal/handler/comment_handler.go");
    grpc::delay_short().await;

    // 6. 获取回复列表
    if !bob_comment_id.is_empty() {
        let result = list_replies(&alice, &content_id, &bob_comment_id).await;
        stats.record_with_func(result, "获取评论的回复列表", "ListComments()", "service/comment/internal/handler/comment_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "获取评论的回复列表（跳过）");
    }

    // 7. Bob 点赞 Alice 的回复
    if !alice_reply_id.is_empty() {
        let result = like_comment(&bob, &alice_reply_id).await;
        stats.record_with_func(result, "Bob 点赞 Alice 的回复", "LikeComment()", "service/comment/internal/handler/comment_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "Bob 点赞 Alice 的回复（跳过）");
    }

    // 8. 获取评论数量
    let result = get_comment_count(&alice, &content_id).await;
    stats.record_with_func(result, "获取评论数量", "GetCommentCount()", "service/comment/internal/handler/comment_handler.go");
    grpc::delay_short().await;

    // 9. Bob 取消点赞
    if !alice_reply_id.is_empty() {
        let result = unlike_comment(&bob, &alice_reply_id).await;
        stats.record_with_func(result, "Bob 取消点赞", "UnlikeComment()", "service/comment/internal/handler/comment_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "Bob 取消点赞（跳过）");
    }

    // 10. 获取单条评论
    if !bob_comment_id.is_empty() {
        let result = get_comment(&alice, &bob_comment_id).await;
        stats.record_with_func(result, "获取单条评论", "GetComment()", "service/comment/internal/handler/comment_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "获取单条评论（跳过）");
    }

    // 11. Alice 删除自己的回复
    if !alice_reply_id.is_empty() {
        let result = delete_comment(&alice, &alice_reply_id).await;
        stats.record_with_func(result, "Alice 删除自己的回复", "DeleteComment()", "service/comment/internal/handler/comment_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "Alice 删除自己的回复（跳过）");
    }

    // 12. Bob 删除自己的评论
    if !bob_comment_id.is_empty() {
        let result = delete_comment(&bob, &bob_comment_id).await;
        stats.record_with_func(result, "Bob 删除自己的评论", "DeleteComment()", "service/comment/internal/handler/comment_handler.go");
    } else {
        stats.record(false, "Bob 删除自己的评论（跳过）");
    }

    // 清理
    auth::cleanup_user(&alice).await;
    auth::cleanup_user(&bob).await;

    println!();
    Ok(stats)
}

/// 创建评论
async fn create_comment(user: &TestUser, content_id: &str, parent_id: &str, text: &str) -> (bool, String) {
    let data = if parent_id.is_empty() {
        format!(
            r#"{{"author_id":"{}","content_id":"{}","text":"{}"}}"#,
            user.id, content_id, text
        )
    } else {
        format!(
            r#"{{"author_id":"{}","content_id":"{}","parent_id":"{}","text":"{}"}}"#,
            user.id, content_id, parent_id, text
        )
    };

    let result = grpc::call_gateway("comment.CommentService/CreateComment", &data, Some(&user.access_token)).await;

    if result.contains("comment") {
        let comment_id = result.extract_field("id").unwrap_or_default();
        (true, comment_id)
    } else {
        (false, String::new())
    }
}

/// 获取评论列表
async fn list_comments(user: &TestUser, content_id: &str, sort_by: i32) -> bool {
    let data = format!(
        r#"{{"content_id":"{}","pagination":{{"page":1,"page_size":20}},"sort_by":{}}}"#,
        content_id, sort_by
    );

    let result = grpc::call_gateway("comment.CommentService/ListComments", &data, Some(&user.access_token)).await;
    result.contains_any(&["comments", "pagination", "{}"]) || result.is_empty_success()
}

/// 获取回复列表
async fn list_replies(user: &TestUser, content_id: &str, parent_id: &str) -> bool {
    let data = format!(
        r#"{{"content_id":"{}","parent_id":"{}","pagination":{{"page":1,"page_size":20}}}}"#,
        content_id, parent_id
    );

    let result = grpc::call_gateway("comment.CommentService/ListComments", &data, Some(&user.access_token)).await;
    result.contains_any(&["comments", "pagination", "{}"]) || result.is_empty_success()
}

/// 获取单条评论
async fn get_comment(user: &TestUser, comment_id: &str) -> bool {
    let data = format!(r#"{{"comment_id":"{}"}}"#, comment_id);

    let result = grpc::call_gateway("comment.CommentService/GetComment", &data, Some(&user.access_token)).await;
    result.contains("comment") || result.contains("text")
}

/// 点赞评论
async fn like_comment(user: &TestUser, comment_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","comment_id":"{}"}}"#,
        user.id, comment_id
    );

    let result = grpc::call_gateway("comment.CommentService/LikeComment", &data, Some(&user.access_token)).await;
    result.contains("success") || result.contains("likeCount") || result.is_empty_success()
}

/// 取消点赞评论
async fn unlike_comment(user: &TestUser, comment_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","comment_id":"{}"}}"#,
        user.id, comment_id
    );

    let result = grpc::call_gateway("comment.CommentService/UnlikeComment", &data, Some(&user.access_token)).await;
    result.contains("success") || result.contains("likeCount") || result.is_empty_success()
}

/// 获取评论数量
async fn get_comment_count(user: &TestUser, content_id: &str) -> bool {
    let data = format!(r#"{{"content_id":"{}"}}"#, content_id);

    let result = grpc::call_gateway("comment.CommentService/GetCommentCount", &data, Some(&user.access_token)).await;
    result.contains("count") || result.is_empty_success()
}

/// 删除评论
async fn delete_comment(user: &TestUser, comment_id: &str) -> bool {
    let data = format!(
        r#"{{"comment_id":"{}","user_id":"{}"}}"#,
        comment_id, user.id
    );

    let result = grpc::call_gateway("comment.CommentService/DeleteComment", &data, Some(&user.access_token)).await;
    result.contains("success") || result.is_empty_success()
}
