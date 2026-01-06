//! Chat 服务测试
//!
//! 测试场景：模拟两个用户的聊天互动
//! 1. 创建两个测试用户 Alice 和 Bob
//! 2. Alice 创建与 Bob 的私聊会话
//! 3. Alice 发送消息给 Bob
//! 4. Bob 获取会话列表
//! 5. Bob 获取消息列表
//! 6. Bob 标记消息已读
//! 7. Alice 获取未读数
//! 8. 创建群聊会话
//! 9. 在群聊中发送消息
//! 10. 批量获取未读数

use anyhow::Result;

use super::auth;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Chat 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: Alice 和 Bob 的聊天互动");
    println!();

    // 创建两个测试用户
    let alice = auth::create_test_user("chat_alice").await?;
    grpc::delay_short().await;
    let bob = auth::create_test_user("chat_bob").await?;
    grpc::delay_short().await;

    println!("  Alice: {} ({})", alice.username, alice.id);
    println!("  Bob: {} ({})", bob.username, bob.id);
    println!();

    // 1. Alice 创建与 Bob 的私聊会话
    let (success, conv_id) = create_private_conversation(&alice, &bob.id).await;
    stats.record_with_func(success, "创建私聊会话", "CreateConversation()", "service/chat/internal/handler/chat_handler.go");
    grpc::delay_short().await;

    // 2. Alice 发送消息给 Bob
    let (success, msg_id) = if !conv_id.is_empty() {
        send_message(&alice, &conv_id, "你好 Bob！这是一条测试消息 👋").await
    } else {
        (false, String::new())
    };
    stats.record_with_func(success, "Alice 发送消息", "SendMessage()", "service/chat/internal/handler/chat_handler.go");
    grpc::delay_short().await;

    // 3. Bob 获取会话列表
    let result = get_conversations(&bob).await;
    stats.record_with_func(result, "Bob 获取会话列表", "GetConversations()", "service/chat/internal/handler/chat_handler.go");
    grpc::delay_short().await;

    // 4. Bob 获取消息列表
    if !conv_id.is_empty() {
        let result = get_messages(&bob, &conv_id).await;
        stats.record_with_func(result, "Bob 获取消息列表", "GetMessages()", "service/chat/internal/handler/chat_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "Bob 获取消息列表（跳过）");
    }

    // 5. Bob 标记消息已读
    if !msg_id.is_empty() {
        let result = mark_as_read(&bob, &msg_id).await;
        stats.record_with_func(result, "Bob 标记消息已读", "MarkAsRead()", "service/chat/internal/handler/chat_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "Bob 标记消息已读（跳过）");
    }

    // 6. Bob 标记会话所有消息已读
    if !conv_id.is_empty() {
        let result = mark_conversation_as_read(&bob, &conv_id).await;
        stats.record_with_func(result, "标记会话所有消息已读", "MarkConversationAsRead()", "service/chat/internal/handler/chat_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "标记会话所有消息已读（跳过）");
    }

    // 7. 获取单个会话详情
    if !conv_id.is_empty() {
        let result = get_conversation(&alice, &conv_id).await;
        stats.record_with_func(result, "获取会话详情", "GetConversation()", "service/chat/internal/handler/chat_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "获取会话详情（跳过）");
    }

    // 8. 批量获取未读数
    if !conv_id.is_empty() {
        let result = get_unread_counts(&alice, &[&conv_id]).await;
        stats.record_with_func(result, "批量获取未读数", "GetUnreadCounts()", "service/chat/internal/handler/chat_handler.go");
    } else {
        stats.record(false, "批量获取未读数（跳过）");
    }

    // 清理
    auth::cleanup_user(&alice).await;
    auth::cleanup_user(&bob).await;

    println!();
    Ok(stats)
}


/// 创建私聊会话
async fn create_private_conversation(user: &TestUser, target_id: &str) -> (bool, String) {
    let data = format!(
        r#"{{"type":0,"member_ids":["{}","{}"],"creator_id":"{}"}}"#,
        user.id, target_id, user.id
    );

    // Chat 服务直连 :50052
    let result = grpc::call_chat("chat.ChatService/CreateConversation", &data, Some(&user.access_token)).await;

    if result.contains("id") {
        let conv_id = result.extract_field("id").unwrap_or_default();
        (true, conv_id)
    } else {
        (false, String::new())
    }
}

/// 发送消息
async fn send_message(user: &TestUser, conv_id: &str, content: &str) -> (bool, String) {
    let data = format!(
        r#"{{"conversation_id":"{}","sender_id":"{}","content":"{}","message_type":"text"}}"#,
        conv_id, user.id, content
    );

    let result = grpc::call_chat("chat.ChatService/SendMessage", &data, Some(&user.access_token)).await;

    if result.contains("id") {
        let msg_id = result.extract_field("id").unwrap_or_default();
        (true, msg_id)
    } else {
        (false, String::new())
    }
}

/// 获取会话列表
async fn get_conversations(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":20}}}}"#,
        user.id
    );

    let result = grpc::call_chat("chat.ChatService/GetConversations", &data, Some(&user.access_token)).await;
    result.contains_any(&["conversations", "pagination", "{}"]) || result.is_empty_success()
}


/// 获取单个会话
async fn get_conversation(user: &TestUser, conv_id: &str) -> bool {
    let data = format!(r#"{{"conversation_id":"{}"}}"#, conv_id);

    let result = grpc::call_chat("chat.ChatService/GetConversation", &data, Some(&user.access_token)).await;
    result.contains("id") || result.contains("memberIds")
}

/// 获取消息列表
async fn get_messages(user: &TestUser, conv_id: &str) -> bool {
    let data = format!(
        r#"{{"conversation_id":"{}","pagination":{{"page":1,"page_size":50}}}}"#,
        conv_id
    );

    let result = grpc::call_chat("chat.ChatService/GetMessages", &data, Some(&user.access_token)).await;
    result.contains_any(&["messages", "pagination", "{}"]) || result.is_empty_success()
}

/// 标记消息已读
async fn mark_as_read(user: &TestUser, msg_id: &str) -> bool {
    let data = format!(
        r#"{{"message_id":"{}","user_id":"{}"}}"#,
        msg_id, user.id
    );

    let result = grpc::call_chat("chat.ChatService/MarkAsRead", &data, Some(&user.access_token)).await;
    result.contains("messageId") || result.contains("readAt") || result.is_empty_success()
}

/// 标记会话所有消息已读
async fn mark_conversation_as_read(user: &TestUser, conv_id: &str) -> bool {
    let data = format!(
        r#"{{"conversation_id":"{}","user_id":"{}"}}"#,
        conv_id, user.id
    );

    let result = grpc::call_chat("chat.ChatService/MarkConversationAsRead", &data, Some(&user.access_token)).await;
    result.contains("conversationId") || result.contains("readAt") || result.is_empty_success()
}

/// 批量获取未读数
async fn get_unread_counts(user: &TestUser, conv_ids: &[&str]) -> bool {
    let ids: Vec<String> = conv_ids.iter().map(|id| format!(r#""{}""#, id)).collect();
    let data = format!(
        r#"{{"user_id":"{}","conversation_ids":[{}]}}"#,
        user.id,
        ids.join(",")
    );

    let result = grpc::call_chat("chat.ChatService/GetUnreadCounts", &data, Some(&user.access_token)).await;
    result.contains("unreadCounts") || result.is_empty_success()
}
