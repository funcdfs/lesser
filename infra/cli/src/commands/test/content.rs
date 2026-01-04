//! Content 服务测试
//!
//! 测试场景：模拟用户发布和管理内容
//! 1. 创建测试用户
//! 2. 发布 SHORT 类型内容（类似 Twitter）
//! 3. 获取内容详情
//! 4. 更新内容
//! 5. 发布 ARTICLE 类型内容（草稿）
//! 6. 获取用户草稿列表
//! 7. 发布草稿
//! 8. 获取用户内容列表
//! 9. 置顶内容
//! 10. 取消置顶
//! 11. 批量获取内容
//! 12. 删除内容

use anyhow::Result;

use super::auth;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Content 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: 用户发布和管理内容");
    println!();

    // 创建测试用户
    let user = auth::create_test_user("content_test").await?;
    grpc::delay_short().await;

    println!("  用户: {} ({})", user.username, user.id);
    println!();

    // 1. 发布 SHORT 类型内容
    let (success, content_id) = create_short_content(&user).await;
    stats.record_with_func(success, "发布 SHORT 内容", "CreateContent()", "content/handler.go");
    grpc::delay_short().await;

    // 2. 获取内容详情
    if !content_id.is_empty() {
        let result = get_content(&user, &content_id).await;
        stats.record_with_func(result, "获取内容详情", "GetContent()", "content/handler.go");
        grpc::delay_short().await;

        // 3. 更新内容
        let result = update_content(&user, &content_id).await;
        stats.record_with_func(result, "更新内容", "UpdateContent()", "content/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "获取内容详情（跳过：无内容 ID）");
        stats.record(false, "更新内容（跳过：无内容 ID）");
    }

    // 4. 发布 ARTICLE 草稿
    let (success, draft_id) = create_article_draft(&user).await;
    stats.record_with_func(success, "创建 ARTICLE 草稿", "CreateContent()", "content/handler.go");
    grpc::delay_short().await;

    // 5. 获取用户草稿列表
    let result = get_user_drafts(&user).await;
    stats.record_with_func(result, "获取用户草稿列表", "GetUserDrafts()", "content/handler.go");
    grpc::delay_short().await;

    // 6. 发布草稿
    if !draft_id.is_empty() {
        let result = publish_draft(&user, &draft_id).await;
        stats.record_with_func(result, "发布草稿", "PublishDraft()", "content/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "发布草稿（跳过：无草稿 ID）");
    }

    // 7. 获取用户内容列表
    let result = list_user_contents(&user).await;
    stats.record_with_func(result, "获取用户内容列表", "ListContents()", "content/handler.go");
    grpc::delay_short().await;

    // 8. 置顶内容
    if !content_id.is_empty() {
        let result = pin_content(&user, &content_id, true).await;
        stats.record_with_func(result, "置顶内容", "PinContent()", "content/handler.go");
        grpc::delay_short().await;

        // 9. 取消置顶
        let result = pin_content(&user, &content_id, false).await;
        stats.record_with_func(result, "取消置顶", "PinContent()", "content/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "置顶内容（跳过：无内容 ID）");
        stats.record(false, "取消置顶（跳过：无内容 ID）");
    }

    // 10. 批量获取内容
    let content_ids: Vec<&str> = [content_id.as_str(), draft_id.as_str()]
        .into_iter()
        .filter(|id| !id.is_empty())
        .collect();
    if !content_ids.is_empty() {
        let result = batch_get_contents(&user, &content_ids).await;
        stats.record_with_func(result, "批量获取内容", "BatchGetContents()", "content/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "批量获取内容（跳过：无内容 ID）");
    }

    // 11. 删除内容
    if !content_id.is_empty() {
        let result = delete_content(&user, &content_id).await;
        stats.record_with_func(result, "删除内容", "DeleteContent()", "content/handler.go");
    } else {
        stats.record(false, "删除内容（跳过：无内容 ID）");
    }

    // 清理
    auth::cleanup_user(&user).await;

    println!();
    Ok(stats)
}

/// 创建 SHORT 类型内容
async fn create_short_content(user: &TestUser) -> (bool, String) {
    let ts = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_millis();

    let data = format!(
        r#"{{"author_id":"{}","type":2,"text":"这是一条测试短文 #{} 🚀 #test #lesser","tags":["test","lesser"]}}"#,
        user.id, ts
    );

    let result = grpc::call_gateway("content.ContentService/CreateContent", &data, Some(&user.access_token)).await;

    if result.contains("content") {
        let content_id = result.extract_field("id").unwrap_or_default();
        (true, content_id)
    } else {
        (false, String::new())
    }
}

/// 获取内容详情
async fn get_content(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"content_id":"{}","viewer_id":"{}"}}"#,
        content_id, user.id
    );

    let result = grpc::call_gateway("content.ContentService/GetContent", &data, Some(&user.access_token)).await;
    result.contains("content") || result.contains("text")
}

/// 更新内容
async fn update_content(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"content_id":"{}","user_id":"{}","text":"更新后的内容 ✨ Updated!","tags":["test","updated"]}}"#,
        content_id, user.id
    );

    let result = grpc::call_gateway("content.ContentService/UpdateContent", &data, Some(&user.access_token)).await;
    result.contains("content") || result.is_empty_success()
}

/// 创建 ARTICLE 草稿
async fn create_article_draft(user: &TestUser) -> (bool, String) {
    let ts = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_millis();

    let data = format!(
        r#"{{"author_id":"{}","type":3,"title":"测试文章标题 #{}","text":"这是一篇测试文章的正文内容，支持更长的文本...","summary":"文章摘要","tags":["article","test"],"is_draft":true}}"#,
        user.id, ts
    );

    let result = grpc::call_gateway("content.ContentService/CreateContent", &data, Some(&user.access_token)).await;

    if result.contains("content") {
        let draft_id = result.extract_field("id").unwrap_or_default();
        (true, draft_id)
    } else {
        (false, String::new())
    }
}

/// 获取用户草稿列表
async fn get_user_drafts(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":10}}}}"#,
        user.id
    );

    let result = grpc::call_gateway("content.ContentService/GetUserDrafts", &data, Some(&user.access_token)).await;
    result.contains_any(&["drafts", "pagination", "{}"]) || result.is_empty_success()
}

/// 发布草稿
async fn publish_draft(user: &TestUser, draft_id: &str) -> bool {
    let data = format!(
        r#"{{"content_id":"{}","user_id":"{}"}}"#,
        draft_id, user.id
    );

    let result = grpc::call_gateway("content.ContentService/PublishDraft", &data, Some(&user.access_token)).await;
    result.contains("content") || result.is_empty_success()
}

/// 获取用户内容列表
async fn list_user_contents(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"author_id":"{}","pagination":{{"page":1,"page_size":10}},"descending":true}}"#,
        user.id
    );

    let result = grpc::call_gateway("content.ContentService/ListContents", &data, Some(&user.access_token)).await;
    result.contains_any(&["contents", "pagination", "{}"]) || result.is_empty_success()
}

/// 置顶/取消置顶内容
async fn pin_content(user: &TestUser, content_id: &str, pin: bool) -> bool {
    let data = format!(
        r#"{{"content_id":"{}","user_id":"{}","pin":{}}}"#,
        content_id, user.id, pin
    );

    let result = grpc::call_gateway("content.ContentService/PinContent", &data, Some(&user.access_token)).await;
    result.contains("success") || result.is_empty_success()
}

/// 批量获取内容
async fn batch_get_contents(user: &TestUser, content_ids: &[&str]) -> bool {
    let ids: Vec<String> = content_ids.iter().map(|id| format!(r#""{}""#, id)).collect();
    let data = format!(
        r#"{{"content_ids":[{}],"viewer_id":"{}"}}"#,
        ids.join(","),
        user.id
    );

    let result = grpc::call_gateway("content.ContentService/BatchGetContents", &data, Some(&user.access_token)).await;
    result.contains("contents") || result.is_empty_success()
}

/// 删除内容
async fn delete_content(user: &TestUser, content_id: &str) -> bool {
    let data = format!(
        r#"{{"content_id":"{}","user_id":"{}"}}"#,
        content_id, user.id
    );

    let result = grpc::call_gateway("content.ContentService/DeleteContent", &data, Some(&user.access_token)).await;
    result.contains("success") || result.is_empty_success()
}

/// 创建测试内容并返回 ID（供其他测试模块使用）
pub async fn create_test_content(user: &TestUser) -> Result<String> {
    let (success, content_id) = create_short_content(user).await;
    if success && !content_id.is_empty() {
        Ok(content_id)
    } else {
        anyhow::bail!("无法创建测试内容")
    }
}
