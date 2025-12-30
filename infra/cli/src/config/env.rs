use std::path::Path;

use anyhow::{bail, Result};

use crate::error::DevError;

// ============================================================================
// 必需的环境变量
// ============================================================================

/// 必需的环境变量列表
#[allow(dead_code)]
const REQUIRED_ENV_VARS: &[&str] = &[
    "POSTGRES_USER",
    "POSTGRES_PASSWORD",
    "POSTGRES_DB",
    "REDIS_URL",
    "DJANGO_SECRET_KEY",
];

/// 敏感环境变量关键字（用于掩码）
const SENSITIVE_KEYWORDS: &[&str] = &["PASSWORD", "SECRET", "TOKEN", "KEY", "CREDENTIAL"];

// ============================================================================
// 环境变量加载
// ============================================================================

/// 从指定路径加载环境变量文件
///
/// # Arguments
///
/// * `path` - 环境变量文件路径
///
/// # Returns
///
/// 如果文件存在且加载成功，返回 Ok(true)
/// 如果文件不存在，返回 Ok(false)
/// 如果加载失败，返回错误
#[allow(dead_code)]
pub fn load_env_file(path: &Path) -> Result<bool> {
    if !path.exists() {
        return Ok(false);
    }

    dotenvy::from_path(path).map_err(|e| {
        anyhow::anyhow!(
            "无法加载环境变量文件 {}: {}",
            path.display(),
            e
        )
    })?;

    Ok(true)
}

// ============================================================================
// 环境变量验证
// ============================================================================

/// 验证必需的环境变量
///
/// 检查所有必需的环境变量是否已设置。
/// 如果有缺失的变量，返回包含所有缺失变量名的错误。
///
/// # Returns
///
/// 如果所有必需变量都已设置，返回 Ok(())
/// 否则返回 DevError::MissingEnvVars
#[allow(dead_code)]
fn validate_env() -> Result<()> {
    let missing = get_missing_env_vars();

    if !missing.is_empty() {
        bail!(DevError::MissingEnvVars(missing));
    }
    Ok(())
}

/// 获取缺失的必需环境变量列表
#[allow(dead_code)]
fn get_missing_env_vars() -> Vec<String> {
    REQUIRED_ENV_VARS
        .iter()
        .filter(|var| std::env::var(var).is_err())
        .map(|s| s.to_string())
        .collect()
}

/// 检查特定环境变量是否已设置
#[allow(dead_code)]
fn is_env_var_set(name: &str) -> bool {
    std::env::var(name).is_ok()
}

/// 获取环境变量值，如果不存在则返回默认值
pub fn get_env_or_default(name: &str, default: &str) -> String {
    std::env::var(name).unwrap_or_else(|_| default.to_string())
}

/// 获取环境变量值并解析为指定类型
#[allow(dead_code)]
fn get_env_parsed<T: std::str::FromStr>(name: &str, default: T) -> T {
    std::env::var(name)
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(default)
}

// ============================================================================
// 敏感值处理
// ============================================================================

/// 检查环境变量名是否为敏感值
///
/// 如果变量名包含以下关键字（不区分大小写），则认为是敏感值：
/// - PASSWORD
/// - SECRET
/// - TOKEN
/// - KEY
/// - CREDENTIAL
fn is_sensitive_key(key: &str) -> bool {
    let key_upper = key.to_uppercase();
    SENSITIVE_KEYWORDS
        .iter()
        .any(|keyword| key_upper.contains(keyword))
}

/// 掩码敏感值
///
/// 如果 key 是敏感变量名，返回 "********"
/// 否则返回原始值
fn mask_sensitive_value(key: &str, value: &str) -> String {
    if is_sensitive_key(key) {
        "********".to_string()
    } else {
        value.to_string()
    }
}

/// 获取所有环境变量（敏感值已掩码）
#[allow(dead_code)]
fn get_all_env_vars_masked() -> Vec<(String, String)> {
    std::env::vars()
        .map(|(k, v)| {
            let masked_value = mask_sensitive_value(&k, &v);
            (k, masked_value)
        })
        .collect()
}

/// 获取项目相关的环境变量（敏感值已掩码）
///
/// 只返回与项目相关的环境变量，过滤掉系统环境变量
pub fn get_project_env_vars_masked() -> Vec<(String, String)> {
    let project_prefixes = [
        "POSTGRES_",
        "REDIS_",
        "DJANGO_",
        "CHAT_",
        "TRAEFIK_",
        "JWT_",
        "CELERY_",
        "EXTERNAL_",
        "FLUTTER_",
        "REACT_",
        "DATABASE_",
        "DEBUG",
    ];

    std::env::vars()
        .filter(|(k, _)| {
            project_prefixes
                .iter()
                .any(|prefix| k.starts_with(prefix))
        })
        .map(|(k, v)| {
            let masked_value = mask_sensitive_value(&k, &v);
            (k, masked_value)
        })
        .collect()
}

// ============================================================================
// 测试
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_sensitive_key_password() {
        assert!(is_sensitive_key("POSTGRES_PASSWORD"));
        assert!(is_sensitive_key("password"));
        assert!(is_sensitive_key("DB_PASSWORD"));
    }

    #[test]
    fn test_is_sensitive_key_secret() {
        assert!(is_sensitive_key("DJANGO_SECRET_KEY"));
        assert!(is_sensitive_key("JWT_SECRET"));
        assert!(is_sensitive_key("secret_value"));
    }

    #[test]
    fn test_is_sensitive_key_token() {
        assert!(is_sensitive_key("ACCESS_TOKEN"));
        assert!(is_sensitive_key("token"));
        assert!(is_sensitive_key("API_TOKEN"));
    }

    #[test]
    fn test_is_sensitive_key_non_sensitive() {
        assert!(!is_sensitive_key("POSTGRES_USER"));
        assert!(!is_sensitive_key("POSTGRES_DB"));
        assert!(!is_sensitive_key("REDIS_URL"));
        assert!(!is_sensitive_key("DEBUG"));
    }

    #[test]
    fn test_mask_sensitive_value() {
        assert_eq!(
            mask_sensitive_value("POSTGRES_PASSWORD", "my_secret"),
            "********"
        );
        assert_eq!(
            mask_sensitive_value("POSTGRES_USER", "lesser"),
            "lesser"
        );
    }

    #[test]
    fn test_get_env_or_default() {
        // 测试不存在的变量
        assert_eq!(get_env_or_default("TEST_VAR_NOT_EXISTS_12345", "default"), "default");
    }

    #[test]
    fn test_get_env_parsed() {
        // 测试不存在的变量使用默认值
        assert_eq!(get_env_parsed::<u16>("TEST_PORT_NOT_EXISTS_12345", 3000), 3000);
    }

    #[test]
    fn test_required_env_vars_defined() {
        // 验证必需的环境变量列表包含预期的变量
        assert!(REQUIRED_ENV_VARS.contains(&"POSTGRES_USER"));
        assert!(REQUIRED_ENV_VARS.contains(&"POSTGRES_PASSWORD"));
    }

    #[test]
    fn test_sensitive_keywords_defined() {
        // 验证敏感关键字列表包含预期的关键字
        assert!(SENSITIVE_KEYWORDS.contains(&"PASSWORD"));
        assert!(SENSITIVE_KEYWORDS.contains(&"SECRET"));
    }
}
