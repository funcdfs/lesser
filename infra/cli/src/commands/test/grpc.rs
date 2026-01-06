//! gRPC 调用工具模块

use std::process::Stdio;
use tokio::process::Command;

/// gRPC 服务地址
pub const GATEWAY_ADDR: &str = "localhost:50051";
pub const CHAT_ADDR: &str = "localhost:50060";
pub const SUPERUSER_ADDR: &str = "localhost:50061";
pub const CHANNEL_ADDR: &str = "localhost:50062";

/// 测试用户信息
#[derive(Debug, Clone)]
pub struct TestUser {
    pub id: String,
    pub username: String,
    pub email: String,
    pub password: String,
    pub display_name: String,
    pub access_token: String,
    pub refresh_token: String,
}

impl TestUser {
    /// 创建新的测试用户配置
    pub fn new(prefix: &str) -> Self {
        let ts = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_millis();
        Self {
            id: String::new(),
            username: format!("{}_{}", prefix, ts),
            email: format!("{}_{}@test.local", prefix, ts),
            password: "TestPassword123!".to_string(),
            display_name: format!("Test {}", prefix),
            access_token: String::new(),
            refresh_token: String::new(),
        }
    }
}

/// gRPC 调用结果
#[derive(Debug)]
pub struct GrpcResult {
    pub success: bool,
    pub stdout: String,
    pub stderr: String,
}

impl GrpcResult {
    /// 检查响应是否包含指定字段
    pub fn contains(&self, field: &str) -> bool {
        self.stdout.contains(field) || self.stderr.contains(field)
    }

    /// 检查响应是否包含任一字段
    pub fn contains_any(&self, fields: &[&str]) -> bool {
        fields.iter().any(|f| self.contains(f))
    }

    /// 检查是否为空响应（成功）
    pub fn is_empty_success(&self) -> bool {
        self.success && (self.stdout.trim().is_empty() || self.stdout.trim() == "{}")
    }

    /// 提取 JSON 字段值
    pub fn extract_field(&self, field: &str) -> Option<String> {
        extract_json_field(&self.stdout, field)
    }
}

/// 执行 gRPC 调用
pub async fn call(addr: &str, method: &str, data: &str, token: Option<&str>) -> GrpcResult {
    let mut cmd = Command::new("grpcurl");
    cmd.arg("-plaintext");

    if let Some(t) = token {
        cmd.arg("-H").arg(format!("authorization: Bearer {}", t));
    }

    cmd.arg("-d").arg(data);
    cmd.arg(addr);
    cmd.arg(method);

    let output = cmd.stdout(Stdio::piped()).stderr(Stdio::piped()).output().await;

    match output {
        Ok(out) => GrpcResult {
            success: out.status.success(),
            stdout: String::from_utf8_lossy(&out.stdout).to_string(),
            stderr: String::from_utf8_lossy(&out.stderr).to_string(),
        },
        Err(e) => GrpcResult {
            success: false,
            stdout: String::new(),
            stderr: e.to_string(),
        },
    }
}

/// 通过 Gateway 调用
pub async fn call_gateway(method: &str, data: &str, token: Option<&str>) -> GrpcResult {
    call(GATEWAY_ADDR, method, data, token).await
}

/// 通过 Chat 服务调用
pub async fn call_chat(method: &str, data: &str, token: Option<&str>) -> GrpcResult {
    call(CHAT_ADDR, method, data, token).await
}

/// 通过 SuperUser 服务调用
pub async fn call_superuser(method: &str, data: &str, token: Option<&str>) -> GrpcResult {
    call(SUPERUSER_ADDR, method, data, token).await
}

/// 通过 Channel 服务调用
pub async fn call_channel(method: &str, data: &str, token: Option<&str>) -> GrpcResult {
    call(CHANNEL_ADDR, method, data, token).await
}

/// 从 JSON 字符串中提取字段值（支持嵌套对象中的字段）
pub fn extract_json_field(json: &str, field: &str) -> Option<String> {
    // 尝试多种模式匹配
    let patterns = [
        format!(r#""{}": ""#, field),
        format!(r#""{}":\s*""#, field),
        format!(r#""{}":"#, field),
    ];

    for pattern in &patterns {
        let search_pattern = pattern.trim_end_matches(r"\s*");
        if let Some(start) = json.find(search_pattern) {
            let after_key = start + search_pattern.len();
            let remaining = &json[after_key..];
            
            // 跳过空白字符
            let trimmed = remaining.trim_start();
            
            // 检查是否是字符串值
            if trimmed.starts_with('"') {
                let value_start = 1;
                if let Some(end) = trimmed[value_start..].find('"') {
                    return Some(trimmed[value_start..value_start + end].to_string());
                }
            }
        }
    }

    None
}

/// 检查 grpcurl 是否安装
pub async fn check_grpcurl_installed() -> bool {
    Command::new("which")
        .arg("grpcurl")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await
        .map(|s| s.success())
        .unwrap_or(false)
}

/// 短暂延迟，模拟真实用户操作间隔
pub async fn delay_short() {
    tokio::time::sleep(std::time::Duration::from_millis(100)).await;
}

/// 中等延迟
pub async fn delay_medium() {
    tokio::time::sleep(std::time::Duration::from_millis(300)).await;
}
