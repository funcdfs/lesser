/// 敏感环境变量关键字（用于掩码）
const SENSITIVE_KEYWORDS: &[&str] = &["PASSWORD", "SECRET", "TOKEN", "KEY", "CREDENTIAL"];

/// 检查环境变量名是否为敏感值
fn is_sensitive_key(key: &str) -> bool {
    let key_upper = key.to_uppercase();
    SENSITIVE_KEYWORDS
        .iter()
        .any(|keyword| key_upper.contains(keyword))
}

/// 掩码敏感值
fn mask_sensitive_value(key: &str, value: &str) -> String {
    if is_sensitive_key(key) {
        "********".to_string()
    } else {
        value.to_string()
    }
}

/// 获取项目相关的环境变量（敏感值已掩码）
#[allow(dead_code)]
pub fn get_project_env_vars_masked() -> Vec<(String, String)> {
    let project_prefixes = [
        "POSTGRES_",
        "REDIS_",
        "RABBITMQ_",
        "GATEWAY_",
        "CHAT_",
        "TRAEFIK_",
        "JWT_",
        "EXTERNAL_",
        "FLUTTER_",
        "DATABASE_",
        "DEBUG",
        "ENV",
        "DOZZLE_",
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_sensitive_key() {
        assert!(is_sensitive_key("POSTGRES_PASSWORD"));
        assert!(is_sensitive_key("JWT_SECRET_KEY"));
        assert!(!is_sensitive_key("POSTGRES_USER"));
    }

    #[test]
    fn test_mask_sensitive_value() {
        assert_eq!(mask_sensitive_value("POSTGRES_PASSWORD", "secret"), "********");
        assert_eq!(mask_sensitive_value("POSTGRES_USER", "lesser"), "lesser");
    }
}
