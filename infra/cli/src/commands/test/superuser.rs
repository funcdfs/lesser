//! SuperUser 服务测试
//!
//! 测试场景：模拟超级管理员操作
//! 1. SuperUser 登录
//! 2. 创建一个僵尸测试用户
//! 3. 获取用户列表
//! 4. 获取用户详情
//! 5. 封禁僵尸用户
//! 6. 解封僵尸用户
//! 7. 获取系统统计信息
//! 8. 获取数据库状态
//! 9. 获取审计日志
//! 10. 删除僵尸用户
//! 11. SuperUser 登出

use anyhow::Result;

use super::auth;
use super::grpc::{self};
use super::runner::TestStats;

/// SuperUser 信息
struct SuperUserInfo {
    access_token: String,
}

/// 运行 SuperUser 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();

    println!("  场景: 超级管理员操作测试");
    println!();

    // 1. SuperUser 登录
    let (success, su_info) = superuser_login().await;
    stats.record_with_func(success, "SuperUser 登录", "Login()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    if su_info.access_token.is_empty() {
        println!("  ⚠️  SuperUser 登录失败，跳过后续测试");
        println!("  提示: 请确保 SuperUser 服务已启动且默认管理员账户已创建");
        return Ok(stats);
    }

    // 2. 创建一个僵尸测试用户
    let zombie = auth::create_test_user("zombie").await?;
    grpc::delay_short().await;
    println!("  僵尸用户: {} ({})", zombie.username, zombie.id);
    println!();

    // 3. 获取用户列表
    let result = list_users(&su_info).await;
    stats.record_with_func(result, "获取用户列表", "ListUsers()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    // 4. 获取用户详情
    let result = get_user(&su_info, &zombie.id).await;
    stats.record_with_func(result, "获取用户详情", "GetUser()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    // 5. 封禁僵尸用户
    let result = ban_user(&su_info, &zombie.id, "测试封禁").await;
    stats.record_with_func(result, "封禁用户", "BanUser()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    // 6. 解封僵尸用户
    let result = unban_user(&su_info, &zombie.id).await;
    stats.record_with_func(result, "解封用户", "UnbanUser()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    // 7. 获取系统统计信息
    let result = get_system_stats(&su_info).await;
    stats.record_with_func(result, "获取系统统计信息", "GetSystemStats()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    // 8. 获取数据库状态
    let result = get_database_status(&su_info).await;
    stats.record_with_func(result, "获取数据库状态", "GetDatabaseStatus()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    // 9. 获取审计日志
    let result = get_audit_logs(&su_info).await;
    stats.record_with_func(result, "获取审计日志", "GetAuditLogs()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    // 10. 删除僵尸用户
    let result = delete_user(&su_info, &zombie.id).await;
    stats.record_with_func(result, "删除用户", "DeleteUser()", "service/superuser/internal/handler/superuser_handler.go");
    grpc::delay_short().await;

    // 11. SuperUser 登出
    let result = superuser_logout(&su_info).await;
    stats.record_with_func(result, "SuperUser 登出", "Logout()", "service/superuser/internal/handler/superuser_handler.go");

    println!();
    Ok(stats)
}


/// SuperUser 登录
async fn superuser_login() -> (bool, SuperUserInfo) {
    // 使用默认管理员账户 (funcdfs / fw142857)
    let data = r#"{"username":"funcdfs","password":"fw142857"}"#;
    let result = grpc::call_superuser("superuser.SuperUserService/Login", data, None).await;

    if result.contains_any(&["accessToken", "access_token"]) {
        let token = result
            .extract_field("accessToken")
            .or_else(|| result.extract_field("access_token"))
            .unwrap_or_default();
        (true, SuperUserInfo { access_token: token })
    } else {
        (false, SuperUserInfo { access_token: String::new() })
    }
}

/// SuperUser 登出
async fn superuser_logout(su: &SuperUserInfo) -> bool {
    let data = format!(r#"{{"access_token":"{}"}}"#, su.access_token);
    let result = grpc::call_superuser("superuser.SuperUserService/Logout", &data, Some(&su.access_token)).await;
    result.is_empty_success() || result.success
}

/// 获取用户列表
async fn list_users(su: &SuperUserInfo) -> bool {
    let data = r#"{"page":1,"page_size":10}"#;
    let result = grpc::call_superuser("superuser.SuperUserService/ListUsers", data, Some(&su.access_token)).await;
    result.contains_any(&["users", "total"]) || result.is_empty_success()
}


/// 获取用户详情
async fn get_user(su: &SuperUserInfo, user_id: &str) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user_id);
    let result = grpc::call_superuser("superuser.SuperUserService/GetUser", &data, Some(&su.access_token)).await;
    result.contains("username") || result.contains("id")
}

/// 封禁用户
async fn ban_user(su: &SuperUserInfo, user_id: &str, reason: &str) -> bool {
    let data = format!(
        r#"{{"user_id":"{}","reason":"{}","duration_seconds":3600}}"#,
        user_id, reason
    );
    let result = grpc::call_superuser("superuser.SuperUserService/BanUser", &data, Some(&su.access_token)).await;
    result.contains("success") || result.is_empty_success()
}

/// 解封用户
async fn unban_user(su: &SuperUserInfo, user_id: &str) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user_id);
    let result = grpc::call_superuser("superuser.SuperUserService/UnbanUser", &data, Some(&su.access_token)).await;
    result.contains("success") || result.is_empty_success()
}

/// 删除用户
async fn delete_user(su: &SuperUserInfo, user_id: &str) -> bool {
    let data = format!(r#"{{"user_id":"{}","hard_delete":false}}"#, user_id);
    let result = grpc::call_superuser("superuser.SuperUserService/DeleteUser", &data, Some(&su.access_token)).await;
    result.contains("success") || result.is_empty_success()
}


/// 获取系统统计信息
async fn get_system_stats(su: &SuperUserInfo) -> bool {
    let result = grpc::call_superuser("superuser.SuperUserService/GetSystemStats", "{}", Some(&su.access_token)).await;
    result.contains_any(&["totalUsers", "total_users", "activeUsers"]) || result.is_empty_success()
}

/// 获取数据库状态
async fn get_database_status(su: &SuperUserInfo) -> bool {
    let result = grpc::call_superuser("superuser.SuperUserService/GetDatabaseStatus", "{}", Some(&su.access_token)).await;
    result.contains_any(&["connected", "version", "tables"]) || result.is_empty_success()
}

/// 获取审计日志
async fn get_audit_logs(su: &SuperUserInfo) -> bool {
    let data = r#"{"page":1,"page_size":10}"#;
    let result = grpc::call_superuser("superuser.SuperUserService/GetAuditLogs", data, Some(&su.access_token)).await;
    result.contains_any(&["logs", "total"]) || result.is_empty_success()
}
