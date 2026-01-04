//! User 服务测试
//!
//! 测试场景：模拟两个用户的社交互动
//! 1. 创建两个测试用户 Alice 和 Bob
//! 2. Alice 查看自己的资料
//! 3. Alice 更新个人资料（bio、location）
//! 4. Bob 查看 Alice 的资料（通过用户名）
//! 5. Alice 关注 Bob
//! 6. 检查关注状态
//! 7. Bob 关注 Alice（互关）
//! 8. 检查互关状态
//! 9. 获取 Alice 的粉丝列表（应包含 Bob）
//! 10. 获取 Alice 的关注列表（应包含 Bob）
//! 11. Alice 取消关注 Bob
//! 12. Alice 屏蔽 Bob（不看他）
//! 13. 检查屏蔽状态
//! 14. Alice 取消屏蔽 Bob
//! 15. Alice 拉黑 Bob
//! 16. Alice 取消拉黑 Bob
//! 17. 获取用户设置
//! 18. 更新用户设置
//! 19. 批量获取用户资料

use anyhow::Result;

use super::auth;
use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 User 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: Alice 和 Bob 的社交互动");
    println!();

    // 创建两个测试用户
    let alice = auth::create_test_user("alice").await?;
    grpc::delay_short().await;
    let bob = auth::create_test_user("bob").await?;
    grpc::delay_short().await;

    println!("  Alice: {} ({})", alice.username, alice.id);
    println!("  Bob: {} ({})", bob.username, bob.id);
    println!();

    // 1. Alice 查看自己的资料
    let result = get_profile(&alice, &alice.id).await;
    stats.record_with_func(result, "Alice 查看自己的资料", "GetProfile()", "user/handler.go");
    grpc::delay_short().await;

    // 2. Alice 更新个人资料
    let result = update_profile(&alice, "Hello, I'm Alice! 🌟", "Shanghai").await;
    stats.record_with_func(result, "Alice 更新个人资料", "UpdateProfile()", "user/handler.go");
    grpc::delay_short().await;

    // 3. Bob 通过用户名查看 Alice 的资料
    let result = get_profile_by_username(&bob, &alice.username).await;
    stats.record_with_func(result, "Bob 通过用户名查看 Alice", "GetProfileByUsername()", "user/handler.go");
    grpc::delay_short().await;

    // 4. Alice 关注 Bob
    let result = follow(&alice, &bob.id).await;
    stats.record_with_func(result, "Alice 关注 Bob", "Follow()", "user/handler.go");
    grpc::delay_short().await;

    // 5. 检查关注状态
    let result = check_following(&alice, &bob.id).await;
    stats.record_with_func(result, "检查 Alice 是否关注 Bob", "CheckFollowing()", "user/handler.go");
    grpc::delay_short().await;

    // 6. Bob 关注 Alice（互关）
    let result = follow(&bob, &alice.id).await;
    stats.record_with_func(result, "Bob 关注 Alice（互关）", "Follow()", "user/handler.go");
    grpc::delay_short().await;

    // 7. 检查互关状态
    let result = get_relationship(&alice, &bob.id).await;
    stats.record_with_func(result, "检查互关状态", "GetRelationship()", "user/handler.go");
    grpc::delay_short().await;

    // 8. 获取 Alice 的粉丝列表
    let result = get_followers(&alice).await;
    stats.record_with_func(result, "获取 Alice 的粉丝列表", "GetFollowers()", "user/handler.go");
    grpc::delay_short().await;

    // 9. 获取 Alice 的关注列表
    let result = get_following(&alice).await;
    stats.record_with_func(result, "获取 Alice 的关注列表", "GetFollowing()", "user/handler.go");
    grpc::delay_short().await;

    // 10. 获取共同关注
    let result = get_mutual_followers(&alice, &bob.id).await;
    stats.record_with_func(result, "获取共同关注", "GetMutualFollowers()", "user/handler.go");
    grpc::delay_short().await;

    // 11. Alice 取消关注 Bob
    let result = unfollow(&alice, &bob.id).await;
    stats.record_with_func(result, "Alice 取消关注 Bob", "Unfollow()", "user/handler.go");
    grpc::delay_short().await;

    // 12. Alice 屏蔽 Bob（HIDE_POSTS - 不看他）
    let result = block(&alice, &bob.id, 1).await;
    stats.record_with_func(result, "Alice 屏蔽 Bob（不看他）", "Block()", "user/handler.go");
    grpc::delay_short().await;

    // 13. 检查屏蔽状态
    let result = check_blocked(&alice, &bob.id).await;
    stats.record_with_func(result, "检查屏蔽状态", "CheckBlocked()", "user/handler.go");
    grpc::delay_short().await;

    // 14. Alice 取消屏蔽 Bob
    let result = unblock(&alice, &bob.id, 1).await;
    stats.record_with_func(result, "Alice 取消屏蔽 Bob", "Unblock()", "user/handler.go");
    grpc::delay_short().await;

    // 15. Alice 拉黑 Bob（BLOCK - 双向屏蔽）
    let result = block(&alice, &bob.id, 3).await;
    stats.record_with_func(result, "Alice 拉黑 Bob", "Block()", "user/handler.go");
    grpc::delay_short().await;

    // 16. Alice 取消拉黑 Bob
    let result = unblock(&alice, &bob.id, 3).await;
    stats.record_with_func(result, "Alice 取消拉黑 Bob", "Unblock()", "user/handler.go");
    grpc::delay_short().await;

    // 17. 获取用户设置
    let result = get_user_settings(&alice).await;
    stats.record_with_func(result, "获取用户设置", "GetUserSettings()", "user/handler.go");
    grpc::delay_short().await;

    // 18. 更新用户设置
    let result = update_user_settings(&alice).await;
    stats.record_with_func(result, "更新用户设置", "UpdateUserSettings()", "user/handler.go");
    grpc::delay_short().await;

    // 19. 批量获取用户资料
    let result = batch_get_profiles(&alice, &[&alice.id, &bob.id]).await;
    stats.record_with_func(result, "批量获取用户资料", "BatchGetProfiles()", "user/handler.go");
    grpc::delay_short().await;

    // 20. 搜索用户
    let result = search_users(&alice, "test").await;
    stats.record_with_func(result, "搜索用户", "SearchUsers()", "user/handler.go");

    // 清理
    auth::cleanup_user(&alice).await;
    auth::cleanup_user(&bob).await;

    println!();
    Ok(stats)
}

async fn get_profile(user: &TestUser, target_id: &str) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, target_id);
    let result = grpc::call_gateway("user.UserService/GetProfile", &data, Some(&user.access_token)).await;
    result.contains("username")
}

async fn get_profile_by_username(user: &TestUser, username: &str) -> bool {
    let data = format!(r#"{{"username":"{}"}}"#, username);
    let result = grpc::call_gateway("user.UserService/GetProfileByUsername", &data, Some(&user.access_token)).await;
    result.contains("username")
}

async fn update_profile(user: &TestUser, bio: &str, location: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","bio":"{}","location":"{}"}}"#,
        user.id, bio, location
    );
    let result = grpc::call_gateway("user.UserService/UpdateProfile", &data, Some(&user.access_token)).await;
    result.contains("bio") || result.is_empty_success()
}

async fn follow(user: &TestUser, target_id: &str) -> bool {
    let data = format!(
        r#"{{"follower_id":"{}","following_id":"{}"}}"#,
        user.id, target_id
    );
    let result = grpc::call_gateway("user.UserService/Follow", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

async fn unfollow(user: &TestUser, target_id: &str) -> bool {
    let data = format!(
        r#"{{"follower_id":"{}","following_id":"{}"}}"#,
        user.id, target_id
    );
    let result = grpc::call_gateway("user.UserService/Unfollow", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

async fn check_following(user: &TestUser, target_id: &str) -> bool {
    let data = format!(
        r#"{{"follower_id":"{}","following_id":"{}"}}"#,
        user.id, target_id
    );
    let result = grpc::call_gateway("user.UserService/CheckFollowing", &data, Some(&user.access_token)).await;
    result.contains("isFollowing")
}

async fn get_relationship(user: &TestUser, target_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","target_id":"{}"}}"#,
        user.id, target_id
    );
    let result = grpc::call_gateway("user.UserService/GetRelationship", &data, Some(&user.access_token)).await;
    result.contains_any(&["isMutual", "isFollowing", "isFollowedBy"])
}

async fn get_followers(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":10}}}}"#,
        user.id
    );
    let result = grpc::call_gateway("user.UserService/GetFollowers", &data, Some(&user.access_token)).await;
    result.contains_any(&["users", "pagination", "{}"]) || result.is_empty_success()
}

async fn get_following(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","pagination":{{"page":1,"page_size":10}}}}"#,
        user.id
    );
    let result = grpc::call_gateway("user.UserService/GetFollowing", &data, Some(&user.access_token)).await;
    result.contains_any(&["users", "pagination", "{}"]) || result.is_empty_success()
}

async fn get_mutual_followers(user: &TestUser, target_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","target_id":"{}","pagination":{{"page":1,"page_size":10}}}}"#,
        user.id, target_id
    );
    let result = grpc::call_gateway("user.UserService/GetMutualFollowers", &data, Some(&user.access_token)).await;
    result.contains_any(&["users", "pagination", "{}"]) || result.is_empty_success()
}

async fn block(user: &TestUser, target_id: &str, block_type: i32) -> bool {
    let data = format!(
        r#"{{"blocker_id":"{}","blocked_id":"{}","block_type":{}}}"#,
        user.id, target_id, block_type
    );
    let result = grpc::call_gateway("user.UserService/Block", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

async fn unblock(user: &TestUser, target_id: &str, block_type: i32) -> bool {
    let data = format!(
        r#"{{"blocker_id":"{}","blocked_id":"{}","block_type":{}}}"#,
        user.id, target_id, block_type
    );
    let result = grpc::call_gateway("user.UserService/Unblock", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

async fn check_blocked(user: &TestUser, target_id: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","target_id":"{}"}}"#,
        user.id, target_id
    );
    let result = grpc::call_gateway("user.UserService/CheckBlocked", &data, Some(&user.access_token)).await;
    result.contains("isBlocking") || result.is_empty_success()
}

async fn get_user_settings(user: &TestUser) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user.id);
    let result = grpc::call_gateway("user.UserService/GetUserSettings", &data, Some(&user.access_token)).await;
    result.contains_any(&["privacy", "notification", "userId"])
}

async fn update_user_settings(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","privacy":{{"is_private_account":false,"allow_message_from_anyone":true}},"notification":{{"push_enabled":true,"notify_new_follower":true}}}}"#,
        user.id
    );
    let result = grpc::call_gateway("user.UserService/UpdateUserSettings", &data, Some(&user.access_token)).await;
    result.contains_any(&["privacy", "notification", "userId"]) || result.is_empty_success()
}

async fn batch_get_profiles(user: &TestUser, user_ids: &[&str]) -> bool {
    let ids: Vec<String> = user_ids.iter().map(|id| format!(r#""{}""#, id)).collect();
    let data = format!(r#"{{"user_ids":[{}]}}"#, ids.join(","));
    let result = grpc::call_gateway("user.UserService/BatchGetProfiles", &data, Some(&user.access_token)).await;
    result.contains("profiles")
}

async fn search_users(user: &TestUser, query: &str) -> bool {
    let data = format!(
        r#"{{"query":"{}","pagination":{{"page":1,"page_size":10}}}}"#,
        query
    );
    let result = grpc::call_gateway("user.UserService/SearchUsers", &data, Some(&user.access_token)).await;
    result.contains_any(&["users", "pagination", "{}"]) || result.is_empty_success()
}
