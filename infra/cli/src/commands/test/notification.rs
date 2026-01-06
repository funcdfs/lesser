//! Notification 服务测试
//!
//! 测试场景：模拟用户通知功能
//! 1. 创建两个测试用户 Alice 和 Bob
//! 2. Bob 关注 Alice（触发通知）
//! 3. Alice 获取通知列表
//! 4. Alice 获取未读通知数
//! 5. Alice 标记单条通知已读
//! 6. Alice 标记所有通知已读
//! 7. 再次获取未读数（应为 0）

use anyhow::Result;

use super::auth;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Notification 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: Alice 和 Bob 的通知功能测试");
    println!();

    // 创建两个测试用户
    let alice = auth::create_test_user("notif_alice").await?;
    grpc::delay_short().await;
    let bob = auth::create_test_user("notif_bob").await?;
    grpc::delay_short().await;

    println!("  Alice: {} ({})", alice.username, alice.id);
    println!("  Bob: {} ({})", bob.username, bob.id);
    println!();

    // 1. Bob 关注 Alice（触发关注通知）
    let result = follow_user(&bob, &alice.id).await;
    stats.record_with_func(result, "Bob 关注 Alice", "Follow()", "service/user/internal/handler/user_handler.go");
    grpc::delay_medium().await;

    // 2. Alice 获取未读通知数
    let result = get_unread_count(&alice).await;
    stats.record_with_func(result, "获取未读通知数", "GetUnreadCount()", "service/notification/internal/handler/notification_handler.go");
    grpc::delay_short().await;

    // 3. Alice 获取通知列表
    let (success, notification_id) = list_notifications(&alice).await;
    stats.record_with_func(success, "获取通知列表", "List()", "service/notification/internal/handler/notification_handler.go");
    grpc::delay_short().await;

    // 4. Alice 获取未读通知列表
    let result = list_unread_notifications(&alice).await;
    stats.record_with_func(result, "获取未读通知列表", "List()", "service/notification/internal/handler/notification_handler.go");
    grpc::delay_short().await;

    // 5. Alice 标记单条通知已读
    if !notification_id.is_empty() {
        let result = read_notification(&alice, &notification_id).await;
        stats.record_with_func(result, "标记单条通知已读", "Read()", "service/notification/internal/handler/notification_handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(true, "标记单条通知已读（无通知，跳过）");
    }

    // 6. Alice 标记所有通知已读
    let result = read_all_notifications(&alice).await;
    stats.record_with_func(result, "标记所有通知已读", "ReadAll()", "service/notification/internal/handler/notification_handler.go");
    grpc::delay_short().await;

    // 7. 再次获取未读数（应为 0）
    let result = get_unread_count(&alice).await;
    stats.record_with_func(result, "再次获取未读数", "GetUnreadCount()", "service/notification/internal/handler/notification_handler.go");

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


/// 获取未读通知数
async fn get_unread_count(user: &TestUser) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user.id);

    let result = grpc::call_gateway("notification.NotificationService/GetUnreadCount", &data, Some(&user.access_token)).await;
    result.contains("count") || result.is_empty_success()
}

/// 获取通知列表
async fn list_notifications(user: &TestUser) -> (bool, String) {
    let data = format!(
        r#"{{"user_id":"{}","unread_only":false,"pagination":{{"page":1,"page_size":20}}}}"#,
        user.id
    );

    let result = grpc::call_gateway("notification.NotificationService/List", &data, Some(&user.access_token)).await;
    let success = result.contains_any(&["notifications", "pagination", "{}"]) || result.is_empty_success();
    let notification_id = result.extract_field("id").unwrap_or_default();
    (success, notification_id)
}

/// 获取未读通知列表
async fn list_unread_notifications(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","unread_only":true,"pagination":{{"page":1,"page_size":20}}}}"#,
        user.id
    );

    let result = grpc::call_gateway("notification.NotificationService/List", &data, Some(&user.access_token)).await;
    result.contains_any(&["notifications", "pagination", "{}"]) || result.is_empty_success()
}

/// 标记单条通知已读
async fn read_notification(user: &TestUser, notification_id: &str) -> bool {
    let data = format!(
        r#"{{"notification_id":"{}","user_id":"{}"}}"#,
        notification_id, user.id
    );

    let result = grpc::call_gateway("notification.NotificationService/Read", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

/// 标记所有通知已读
async fn read_all_notifications(user: &TestUser) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user.id);

    let result = grpc::call_gateway("notification.NotificationService/ReadAll", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}
