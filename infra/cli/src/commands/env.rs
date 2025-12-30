use std::collections::HashMap;
use std::fs;

use anyhow::Result;

use crate::config::paths;
use crate::ui;

/// 执行 env 命令 - 显示环境变量
pub async fn execute() -> Result<()> {
    ui::header("环境变量");

    // 显示环境变量文件位置
    let env_file = paths::get_env_file()?;
    ui::info(&format!("配置文件: {}", env_file.display()));
    println!();

    // 直接从文件读取环境变量
    let mut env_vars = read_env_file(&env_file)?;

    if env_vars.is_empty() {
        ui::warn("环境变量文件为空或不存在");
        ui::info("请检查配置文件是否正确");
        return Ok(());
    }

    // 按名称排序
    env_vars.sort_by(|a, b| a.0.cmp(&b.0));

    // 分组显示
    print_env_group("数据库配置", &env_vars, &["POSTGRES_", "DATABASE_"]);
    print_env_group("Redis 配置", &env_vars, &["REDIS_"]);
    print_env_group("Django 配置", &env_vars, &["DJANGO_"]);
    print_env_group("Chat 服务配置", &env_vars, &["CHAT_"]);
    print_env_group("JWT 配置", &env_vars, &["JWT_"]);
    print_env_group("Celery 配置", &env_vars, &["CELERY_"]);
    print_env_group("客户端配置", &env_vars, &["FLUTTER_", "REACT_"]);
    print_env_group("其他配置", &env_vars, &["TRAEFIK_", "EXTERNAL_", "DEBUG", "DOZZLE_"]);

    println!();

    Ok(())
}

/// 从环境变量文件读取
fn read_env_file(path: &std::path::Path) -> Result<Vec<(String, String)>> {
    if !path.exists() {
        return Ok(Vec::new());
    }

    let content = fs::read_to_string(path)?;
    let mut env_vars = HashMap::new();

    for line in content.lines() {
        let line = line.trim();
        
        // 跳过空行和注释
        if line.is_empty() || line.starts_with('#') {
            continue;
        }

        // 解析 KEY=VALUE 格式
        if let Some((key, value)) = line.split_once('=') {
            let key = key.trim().to_string();
            let value = value.trim().trim_matches('"').trim_matches('\'').to_string();
            env_vars.insert(key, value);
        }
    }

    let mut result: Vec<_> = env_vars.into_iter().collect();
    result.sort_by(|a, b| a.0.cmp(&b.0));
    Ok(result)
}

/// 打印环境变量分组
fn print_env_group(title: &str, env_vars: &[(String, String)], prefixes: &[&str]) {
    let filtered: Vec<_> = env_vars
        .iter()
        .filter(|(k, _)| prefixes.iter().any(|p| k.starts_with(p)))
        .collect();

    if filtered.is_empty() {
        return;
    }

    println!("{}:", title);
    ui::separator();

    for (key, value) in filtered {
        println!("  {} = {}", key, value);
    }

    println!();
}
