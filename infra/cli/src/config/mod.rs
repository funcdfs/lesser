pub mod env;
pub mod paths;

use std::path::PathBuf;

use anyhow::Result;

pub use env::{get_env_or_default, get_project_env_vars_masked};
pub use paths::{find_project_root, get_env_file, COMPOSE_FILE, FLUTTER_DIR, PROTO_SCRIPT, REACT_DIR};

/// CLI 配置
pub struct Config {
    #[allow(dead_code)]
    pub project_root: PathBuf,
    pub compose_file: PathBuf,
    pub env_file: PathBuf,
    pub flutter_dir: PathBuf,
    pub react_dir: PathBuf,
    #[allow(dead_code)]
    pub proto_script: PathBuf,
    pub flutter_port: u16,
    pub react_port: u16,
}

impl Config {
    /// 加载配置
    pub fn load() -> Result<Self> {
        let project_root = find_project_root()?;
        let env_file = get_env_file()?;

        // 加载环境变量
        if env_file.exists() {
            dotenvy::from_path(&env_file).ok();
        }

        Ok(Self {
            compose_file: project_root.join(COMPOSE_FILE),
            env_file,
            flutter_dir: project_root.join(FLUTTER_DIR),
            react_dir: project_root.join(REACT_DIR),
            proto_script: project_root.join(PROTO_SCRIPT),
            flutter_port: std::env::var("FLUTTER_WEB_PORT")
                .unwrap_or_else(|_| "3000".to_string())
                .parse()
                .unwrap_or(3000),
            react_port: std::env::var("REACT_PORT")
                .unwrap_or_else(|_| "3001".to_string())
                .parse()
                .unwrap_or(3001),
            project_root,
        })
    }
}
