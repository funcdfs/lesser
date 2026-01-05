//! Channel 服务测试
//!
//! 测试场景：模拟用户创建和管理广播频道
//! 1. 创建测试用户 Alice（频道所有者）和 Bob（订阅者）
//! 2. Alice 创建一个公开频道
//! 3. Alice 获取频道详情
//! 4. Bob 订阅频道
//! 5. Bob 检查订阅状态
//! 6. Alice 发布频道内容
//! 7. Bob 获取频道内容列表
//! 8. Alice 置顶内容
//! 9. Alice 更新频道信息
//! 10. Bob 取消订阅
//! 11. Alice 删除频道

use anyhow::Result;

use super::auth;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// Channel 服务地址
pub const CHANNEL_ADDR: &str = "localhost:50062";

/// 运行 Channel 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: Alice 创建频道，Bob 订阅并浏览");
    println!();

    // 创建两个测试用户
    let alice = auth::create_test_user("channel_alice").await?;
    grpc::delay_short().await;
    let bob = auth::create_test_user("channel_bob").await?;
    grpc::delay_short().await;

    println!("  Alice (所有者): {} ({})", alice.username, alice.id);
    println!("  Bob (订阅者): {} ({})", bob.username, bob.id);
    println!();

    // 1. Alice 创建一个公开频道
    let (success, channel_id) = create_channel(&alice, "测试频道", "这是一个测试频道").await;
    stats.record_with_func(success, "创建频道", "CreateChannel()", "channel/handler.go");
    grpc::delay_short().await;

    // 2. Alice 获取频道详情
    if !channel_id.is_empty() {
        let result = get_channel(&alice, &channel_id).await;
        stats.record_with_func(result, "获取频道详情", "GetChannel()", "channel/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "获取频道详情（跳过）");
    }

    // 3. Bob 订阅频道
    if !channel_id.is_empty() {
        let result = subscribe(&bob, &channel_id).await;
        stats.record_with_func(result, "Bob 订阅频道", "Subscribe()", "channel/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "Bob 订阅频道（跳过）");
    }

    // 4. Bob 检查订阅状态
    if !channel_id.is_empty() {
        let result = check_subscription(&bob, &channel_id).await;
        stats.record_with_func(result, "检查订阅状态", "CheckSubscription()", "channel/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "检查订阅状态（跳过）");
    }

    // 5. Alice 发布频道内容
    let (success, post_id) = if !channel_id.is_empty() {
        publish_post(&alice, &channel_id, "这是第一条频道内容 📢").await
    } else {
        (false, String::new())
    };
    stats.record_with_func(success, "发布频道内容", "PublishPost()", "channel/handler.go");
    grpc::delay_short().await;

    // 6. Bob 获取频道内容列表
    if !channel_id.is_empty() {
        let result = get_posts(&bob, &channel_id).await;
        stats.record_with_func(result, "获取频道内容列表", "GetPosts()", "channel/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "获取频道内容列表（跳过）");
    }

    // 7. Alice 置顶内容
    if !post_id.is_empty() {
        let result = pin_post(&alice, &post_id).await;
        stats.record_with_func(result, "置顶内容", "PinPost()", "channel/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "置顶内容（跳过）");
    }

    // 8. Alice 更新频道信息
    if !channel_id.is_empty() {
        let result = update_channel(&alice, &channel_id, "更新后的频道名称").await;
        stats.record_with_func(result, "更新频道信息", "UpdateChannel()", "channel/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "更新频道信息（跳过）");
    }

    // 9. Bob 获取订阅的频道列表
    let result = get_subscribed_channels(&bob).await;
    stats.record_with_func(result, "获取订阅频道列表", "GetSubscribedChannels()", "channel/handler.go");
    grpc::delay_short().await;

    // 10. Bob 取消订阅
    if !channel_id.is_empty() {
        let result = unsubscribe(&bob, &channel_id).await;
        stats.record_with_func(result, "取消订阅", "Unsubscribe()", "channel/handler.go");
        grpc::delay_short().await;
    } else {
        stats.record(false, "取消订阅（跳过）");
    }

    // 11. Alice 删除频道
    if !channel_id.is_empty() {
        let result = delete_channel(&alice, &channel_id).await;
        stats.record_with_func(result, "删除频道", "DeleteChannel()", "channel/handler.go");
    } else {
        stats.record(false, "删除频道（跳过）");
    }

    // 清理
    auth::cleanup_user(&alice).await;
    auth::cleanup_user(&bob).await;

    println!();
    Ok(stats)
}

/// 调用 Channel 服务
async fn call_channel(method: &str, data: &str, token: Option<&str>) -> grpc::GrpcResult {
    grpc::call(CHANNEL_ADDR, method, data, token).await
}

/// 创建频道
async fn create_channel(user: &TestUser, name: &str, description: &str) -> (bool, String) {
    let data = format!(
        r#"{{"name":"{}","description":"{}","is_public":true}}"#,
        name, description
    );

    let result = call_channel("channel.ChannelService/CreateChannel", &data, Some(&user.access_token)).await;

    if result.contains("id") {
        let channel_id = result.extract_field("id").unwrap_or_default();
        (true, channel_id)
    } else {
        (false, String::new())
    }
}

/// 获取频道详情
async fn get_channel(user: &TestUser, channel_id: &str) -> bool {
    let data = format!(r#"{{"channel_id":"{}"}}"#, channel_id);

    let result = call_channel("channel.ChannelService/GetChannel", &data, Some(&user.access_token)).await;
    result.contains("id") || result.contains("name")
}

/// 订阅频道
async fn subscribe(user: &TestUser, channel_id: &str) -> bool {
    let data = format!(r#"{{"channel_id":"{}"}}"#, channel_id);

    let result = call_channel("channel.ChannelService/Subscribe", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

/// 检查订阅状态
async fn check_subscription(user: &TestUser, channel_id: &str) -> bool {
    let data = format!(r#"{{"channel_id":"{}"}}"#, channel_id);

    let result = call_channel("channel.ChannelService/CheckSubscription", &data, Some(&user.access_token)).await;
    result.contains("isSubscribed") || result.contains("is_subscribed") || result.success
}

/// 发布频道内容
async fn publish_post(user: &TestUser, channel_id: &str, content: &str) -> (bool, String) {
    let data = format!(
        r#"{{"channel_id":"{}","content":"{}"}}"#,
        channel_id, content
    );

    let result = call_channel("channel.ChannelService/PublishPost", &data, Some(&user.access_token)).await;

    if result.contains("id") {
        let post_id = result.extract_field("id").unwrap_or_default();
        (true, post_id)
    } else {
        (false, String::new())
    }
}

/// 获取频道内容列表
async fn get_posts(user: &TestUser, channel_id: &str) -> bool {
    let data = format!(
        r#"{{"channel_id":"{}","pagination":{{"page":1,"page_size":20}}}}"#,
        channel_id
    );

    let result = call_channel("channel.ChannelService/GetPosts", &data, Some(&user.access_token)).await;
    result.contains_any(&["posts", "pagination", "{}"]) || result.is_empty_success()
}

/// 置顶内容
async fn pin_post(user: &TestUser, post_id: &str) -> bool {
    let data = format!(r#"{{"post_id":"{}"}}"#, post_id);

    let result = call_channel("channel.ChannelService/PinPost", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

/// 更新频道信息
async fn update_channel(user: &TestUser, channel_id: &str, new_name: &str) -> bool {
    let data = format!(
        r#"{{"channel_id":"{}","name":"{}"}}"#,
        channel_id, new_name
    );

    let result = call_channel("channel.ChannelService/UpdateChannel", &data, Some(&user.access_token)).await;
    result.contains("id") || result.contains("name")
}

/// 获取订阅的频道列表
async fn get_subscribed_channels(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":20}}}}"#,
        user.id
    );

    let result = call_channel("channel.ChannelService/GetSubscribedChannels", &data, Some(&user.access_token)).await;
    result.contains_any(&["channels", "pagination", "{}"]) || result.is_empty_success()
}

/// 取消订阅
async fn unsubscribe(user: &TestUser, channel_id: &str) -> bool {
    let data = format!(r#"{{"channel_id":"{}"}}"#, channel_id);

    let result = call_channel("channel.ChannelService/Unsubscribe", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

/// 删除频道
async fn delete_channel(user: &TestUser, channel_id: &str) -> bool {
    let data = format!(r#"{{"channel_id":"{}"}}"#, channel_id);

    let result = call_channel("channel.ChannelService/DeleteChannel", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}
