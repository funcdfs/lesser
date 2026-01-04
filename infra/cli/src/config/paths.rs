use std::path::PathBuf;
use std::sync::OnceLock;

use anyhow::{Context, Result};

use crate::error::DevError;

// ============================================================================
// 路径常量
// ============================================================================

/// Docker Compose 文件相对路径
pub const COMPOSE_FILE: &str = "infra/docker-compose.yml";

/// 新环境变量文件路径
const ENV_FILE_NEW: &str = "infra/env/dev.env";

/// 旧环境变量文件路径 (兼容)
const ENV_FILE_LEGACY: &str = "infra/.env.dev";

/// Proto 生成脚本路径（用于 proto 命令）
#[allow(dead_code)]
pub const PROTO_SCRIPT: &str = "scripts/proto/generate.sh";

/// Flutter 客户端目录
pub const FLUTTER_DIR: &str = "client/mobile_flutter";

/// 项目根目录标记文件
const ROOT_MARKERS: &[&str] = &["infra/docker-compose.yml", ".git"];

// ============================================================================
// 缓存的项目根目录
// ============================================================================

/// 缓存的项目根目录路径
static PROJECT_ROOT_CACHE: OnceLock<PathBuf> = OnceLock::new();

/// 查找项目根目录
pub fn find_project_root() -> Result<PathBuf> {
    if let Some(cached) = PROJECT_ROOT_CACHE.get() {
        return Ok(cached.clone());
    }

    let root = find_project_root_uncached()?;
    let _ = PROJECT_ROOT_CACHE.set(root.clone());
    Ok(root)
}

/// 查找项目根目录（不使用缓存）
fn find_project_root_uncached() -> Result<PathBuf> {
    let current = std::env::current_dir().context("无法获取当前目录")?;
    let mut path = current.as_path();
    
    const MAX_DEPTH: usize = 50;
    let mut depth = 0;

    loop {
        for marker in ROOT_MARKERS {
            if path.join(marker).exists() {
                return Ok(path.to_path_buf());
            }
        }

        depth += 1;
        if depth > MAX_DEPTH {
            anyhow::bail!(DevError::ProjectRootNotFound);
        }

        path = path
            .parent()
            .ok_or(DevError::ProjectRootNotFound)
            .context("无法找到项目根目录")?;
    }
}

/// 获取环境变量文件的完整路径
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

    Ok(new_path)
}

/// 获取 proto 生成脚本的完整路径
#[allow(dead_code)]
pub fn get_proto_script() -> Result<PathBuf> {
    let root = find_project_root()?;
    Ok(root.join(PROTO_SCRIPT))
}
