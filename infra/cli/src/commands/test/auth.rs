//! Auth 服务测试
//!
//! 测试场景：
//! 1. 用户注册 - 新用户注册流程
//! 2. 用户登录 - 使用邮箱密码登录
//! 3. Token 刷新 - 使用 refresh_token 获取新的 access_token
//! 4. 获取用户信息 - 通过 token 获取当前用户信息
//! 5. 检查封禁状态 - 检查用户是否被封禁
//! 6. 获取公钥 - 获取 JWT 验签公钥
//! 7. 用户登出 - 注销当前会话
//! 8. 重复注册 - 验证重复注册被拒绝
//! 9. 错误密码登录 - 验证错误密码被拒绝

use anyhow::Result;

use super::grpc::{self, TestUser};
use super::runner::TestStats;

/// 运行 Auth 服务测试
pub async fn run_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();
    let mut user = TestUser::new("auth_test");

    println!("  场景: 完整的用户认证流程");
    println!();

    // 1. 用户注册
    let result = register_user(&mut user).await;
    stats.record_with_func(result, "注册新用户", "Register()", "auth/handler.go");
    grpc::delay_short().await;

    if user.access_token.is_empty() {
        // 注册失败，尝试登录（可能用户已存在）
        let _ = login_user(&mut user).await;
    }

    // 2. 重复注册（应该失败）
    let result = test_duplicate_register(&user).await;
    stats.record_with_func(result, "重复注册被拒绝", "Register()", "auth/handler.go");
    grpc::delay_short().await;

    // 3. 用户登出
    let result = logout_user(&user).await;
    stats.record_with_func(result, "用户登出", "Logout()", "auth/handler.go");
    grpc::delay_short().await;

    // 4. 用户登录
    let result = login_user(&mut user).await;
    stats.record_with_func(result, "用户登录", "Login()", "auth/handler.go");
    grpc::delay_short().await;

    // 5. 错误密码登录（应该失败）
    let result = test_wrong_password_login(&user).await;
    stats.record_with_func(result, "错误密码登录被拒绝", "Login()", "auth/handler.go");
    grpc::delay_short().await;

    // 6. 获取公钥
    let result = get_public_key().await;
    stats.record_with_func(result, "获取 JWT 公钥", "GetPublicKey()", "auth/handler.go");
    grpc::delay_short().await;

    // 7. 获取用户信息
    let result = get_user_info(&user).await;
    stats.record_with_func(result, "获取用户信息", "GetUser()", "auth/handler.go");
    grpc::delay_short().await;

    // 8. 检查封禁状态
    let result = check_banned(&user).await;
    stats.record_with_func(result, "检查封禁状态", "CheckBanned()", "auth/handler.go");
    grpc::delay_short().await;

    // 9. Token 刷新
    let result = refresh_token(&mut user).await;
    stats.record_with_func(result, "刷新 Token", "RefreshToken()", "auth/handler.go");
    grpc::delay_short().await;

    // 10. 最终登出
    let result = logout_user(&user).await;
    stats.record_with_func(result, "最终登出", "Logout()", "auth/handler.go");

    println!();
    Ok(stats)
}

/// 注册用户
async fn register_user(user: &mut TestUser) -> bool {
    let data = format!(
        r#"{{"username":"{}","email":"{}","password":"{}","display_name":"{}"}}"#,
        user.username, user.email, user.password, user.display_name
    );

    let result = grpc::call_gateway("auth.AuthService/Register", &data, None).await;

    if result.contains_any(&["accessToken", "access_token"]) {
        user.id = result.extract_field("id").unwrap_or_default();
        user.access_token = result
            .extract_field("accessToken")
            .or_else(|| result.extract_field("access_token"))
            .unwrap_or_default();
        user.refresh_token = result
            .extract_field("refreshToken")
            .or_else(|| result.extract_field("refresh_token"))
            .unwrap_or_default();
        true
    } else {
        false
    }
}

/// 用户登录
async fn login_user(user: &mut TestUser) -> bool {
    let data = format!(
        r#"{{"email":"{}","password":"{}"}}"#,
        user.email, user.password
    );

    let result = grpc::call_gateway("auth.AuthService/Login", &data, None).await;

    if result.contains_any(&["accessToken", "access_token"]) {
        user.access_token = result
            .extract_field("accessToken")
            .or_else(|| result.extract_field("access_token"))
            .unwrap_or_default();
        user.refresh_token = result
            .extract_field("refreshToken")
            .or_else(|| result.extract_field("refresh_token"))
            .unwrap_or_default();
        if user.id.is_empty() {
            user.id = result.extract_field("id").unwrap_or_default();
        }
        true
    } else {
        false
    }
}

/// 用户登出
async fn logout_user(user: &TestUser) -> bool {
    let data = format!(r#"{{"access_token":"{}"}}"#, user.access_token);
    // Logout 需要 authorization header
    let result = grpc::call_gateway("auth.AuthService/Logout", &data, Some(&user.access_token)).await;
    result.is_empty_success() || result.success
}

/// 测试重复注册
async fn test_duplicate_register(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"username":"{}","email":"{}","password":"{}","display_name":"{}"}}"#,
        user.username, user.email, user.password, user.display_name
    );

    let result = grpc::call_gateway("auth.AuthService/Register", &data, None).await;
    // 重复注册应该失败
    result.contains_any(&["already exists", "已存在", "AlreadyExists"])
}

/// 测试错误密码登录
async fn test_wrong_password_login(user: &TestUser) -> bool {
    let data = format!(
        r#"{{"email":"{}","password":"wrong_password_123"}}"#,
        user.email
    );

    let result = grpc::call_gateway("auth.AuthService/Login", &data, None).await;
    // 错误密码应该失败
    !result.contains_any(&["accessToken", "access_token"])
}

/// 获取公钥
async fn get_public_key() -> bool {
    let result = grpc::call_gateway("auth.AuthService/GetPublicKey", "{}", None).await;
    result.contains_any(&["publicKey", "public_key"])
}

/// 获取用户信息
async fn get_user_info(user: &TestUser) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user.id);
    let result = grpc::call_gateway("auth.AuthService/GetUser", &data, Some(&user.access_token)).await;
    result.contains("username")
}

/// 检查封禁状态
async fn check_banned(user: &TestUser) -> bool {
    let data = format!(r#"{{"user_id":"{}"}}"#, user.id);
    let result = grpc::call_gateway("auth.AuthService/CheckBanned", &data, Some(&user.access_token)).await;
    // 正常用户应该返回 banned: false 或空响应
    result.is_empty_success() || result.contains("banned")
}

/// 刷新 Token
async fn refresh_token(user: &mut TestUser) -> bool {
    let data = format!(r#"{{"refresh_token":"{}"}}"#, user.refresh_token);
    let result = grpc::call_gateway("auth.AuthService/RefreshToken", &data, None).await;

    if result.contains_any(&["accessToken", "access_token"]) {
        user.access_token = result
            .extract_field("accessToken")
            .or_else(|| result.extract_field("access_token"))
            .unwrap_or_default();
        user.refresh_token = result
            .extract_field("refreshToken")
            .or_else(|| result.extract_field("refresh_token"))
            .unwrap_or(user.refresh_token.clone());
        true
    } else {
        false
    }
}

/// 创建测试用户并返回（供其他测试模块使用）
pub async fn create_test_user(prefix: &str) -> Result<TestUser> {
    let mut user = TestUser::new(prefix);

    // 尝试注册
    let registered = register_user(&mut user).await;

    if !registered || user.access_token.is_empty() {
        // 注册失败，尝试登录
        login_user(&mut user).await;
    }

    if user.access_token.is_empty() {
        anyhow::bail!("无法创建测试用户");
    }

    Ok(user)
}

/// 清理测试用户（登出）
pub async fn cleanup_user(user: &TestUser) {
    let _ = logout_user(user).await;
}
