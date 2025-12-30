use std::path::PathBuf;
use std::sync::OnceLock;

use anyhow::{Context, Result};

use crate::error::DevError;

// ============================================================================
// 路径常量
// ============================================================================

/// Docker Compose 文件相对路径
pub const COMPOSE_FILE: &str = "infra/docker-compose.yml";

/// Docker Compose 生产环境文件相对路径
#[allow(dead_code)]
const COMPOSE_FILE_PROD: &str = "infra/docker-compose.prod.yml";

/// 新环境变量文件路径
#[allow(dead_code)]
const ENV_FILE_NEW: &str = "infra/env/dev.env";

/// 旧环境变量文件路径 (兼容)
#[allow(dead_code)]
const ENV_FILE_LEGACY: &str = "infra/.env.dev";

/// 生产环境变量文件路径
#[allow(dead_code)]
const ENV_FILE_PROD: &str = "infra/.env.prod";

/// Proto 生成脚本路径
pub const PROTO_SCRIPT: &str = "scripts/proto/generate.sh";

/// Flutter 客户端目录
pub const FLUTTER_DIR: &str = "client/mobile_flutter";

/// React 客户端目录
pub const REACT_DIR: &str = "client/web_react";

/// 项目根目录标记文件
const ROOT_MARKERS: &[&str] = &["infra/docker-compose.yml", ".git"];

// ============================================================================
// 缓存的项目根目录
// ============================================================================

/// 缓存的项目根目录路径
static PROJECT_ROOT_CACHE: OnceLock<PathBuf> = OnceLock::new();

/// 查找项目根目录
///
/// 从当前目录向上查找，直到找到以下标记文件之一：
/// - infra/docker-compose.yml
/// - .git
///
/// 结果会被缓存以提高性能。
///
/// # Errors
///
/// 如果无法找到项目根目录，返回 `DevError::ProjectRootNotFound`
pub fn find_project_root() -> Result<PathBuf> {
    // 尝试从缓存获取
    if let Some(cached) = PROJECT_ROOT_CACHE.get() {
        return Ok(cached.clone());
    }

    let root = find_project_root_uncached()?;

    // 缓存结果
    let _ = PROJECT_ROOT_CACHE.set(root.clone());

    Ok(root)
}

/// 查找项目根目录（不使用缓存）
fn find_project_root_uncached() -> Result<PathBuf> {
    let current = std::env::current_dir().context("无法获取当前目录")?;
    let mut path = current.as_path();
    
    // 设置最大搜索深度，防止无限循环
    const MAX_DEPTH: usize = 50;
    let mut depth = 0;

    loop {
        // 检查所有标记文件
        for marker in ROOT_MARKERS {
            if path.join(marker).exists() {
                return Ok(path.to_path_buf());
            }
        }

        depth += 1;
        if depth > MAX_DEPTH {
            anyhow::bail!(DevError::ProjectRootNotFound);
        }

        // 向上一级目录
        path = path
            .parent()
            .ok_or(DevError::ProjectRootNotFound)
            .context("无法找到项目根目录")?;
    }
}

/// 获取 compose 文件的完整路径
pub fn get_compose_file() -> Result<PathBuf> {
    let root = find_project_root()?;
    Ok(root.join(COMPOSE_FILE))
}

/// 获取环境变量文件的完整路径
///
/// 优先使用新位置 (infra/env/dev.env)，如果不存在则使用旧位置 (infra/.env.dev)
pub fn get_env_file() -> Result<PathBuf> {
    let root = find_project_root()?;

    let new_path = root.join(ENV_FILE_NEW);
    if new_path.exists() {
        return Ok(new_path);
    }

    let legacy_path = root.join(ENV_FILE_LEGACY);
    if legacy_path.exists() {
        return Ok(legacy_path);
    }

    // 返回新路径（即使不存在，用于错误提示）
    Ok(new_path)
}

/// 获取 proto 生成脚本的完整路径
pub fn get_proto_script() -> Result<PathBuf> {
    let root = find_project_root()?;
    Ok(root.join(PROTO_SCRIPT))
}

/// 获取 Flutter 客户端目录的完整路径
#[allow(dead_code)]
fn get_flutter_dir() -> Result<PathBuf> {
    let root = find_project_root()?;
    Ok(root.join(FLUTTER_DIR))
}

/// 获取 React 客户端目录的完整路径
#[allow(dead_code)]
fn get_react_dir() -> Result<PathBuf> {
    let root = find_project_root()?;
    Ok(root.join(REACT_DIR))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_root_markers_defined() {
        // 验证根目录标记包含预期的文件
        assert!(ROOT_MARKERS.contains(&".git"));
        assert!(ROOT_MARKERS.contains(&"infra/docker-compose.yml"));
    }

    #[test]
    fn test_path_constants_defined() {
        // 验证路径常量包含预期的路径
        assert!(COMPOSE_FILE.contains("docker-compose"));
        assert!(FLUTTER_DIR.contains("flutter"));
        assert!(REACT_DIR.contains("react"));
    }
}
