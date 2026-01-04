use std::process::Stdio;

use anyhow::{bail, Context, Result};
use tokio::process::Command;

use crate::config::paths;
use crate::ui::{self, Spinner};

/// 生产环境必需的环境变量
const REQUIRED_VARS: &[&str] = &[
    "POSTGRES_USER",
    "POSTGRES_PASSWORD",
    "POSTGRES_DB",
    "JWT_SECRET_KEY",
    "REDIS_URL",
];

/// 生产环境子命令
#[derive(Clone, Debug, PartialEq)]
pub enum ProdCommand {
    /// 启动生产环境
    Start,
    /// 停止生产环境
    Stop,
    /// 重启服务
    Restart,
    /// 查看状态
    Status,
    /// 查看日志
    Logs { service: Option<String>, lines: u32 },
    /// 部署更新
    Deploy,
    /// 备份数据库
    Backup,
    /// 验证环境变量
    Validate,
}

/// 执行 prod 命令
pub async fn execute(command: ProdCommand, force: bool) -> Result<()> {
    let project_root = paths::find_project_root()?;
    let compose_file = project_root.join("infra/docker-compose.prod.yml");
    let env_file = project_root.join("infra/env/prod.env");

    // 检查 Docker
    check_docker().await?;

    match command {
        ProdCommand::Start => start_services(&compose_file, &env_file).await,
        ProdCommand::Stop => stop_services(&compose_file, force).await,
        ProdCommand::Restart => restart_services(&compose_file, &env_file).await,
        ProdCommand::Status => show_status(&compose_file).await,
        ProdCommand::Logs { service, lines } => show_logs(&compose_file, service, lines).await,
        ProdCommand::Deploy => deploy(&compose_file, &env_file).await,
        ProdCommand::Backup => backup_database(&compose_file, &env_file, &project_root).await,
        ProdCommand::Validate => validate_env(&env_file).await,
    }
}

/// 检查 Docker 是否可用
async fn check_docker() -> Result<()> {
    // 检查 docker 命令
    let status = Command::new("docker")
        .arg("info")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    if status.is_err() || !status.unwrap().success() {
        ui::error("Docker 未运行或未安装");
        bail!("Docker 不可用");
    }

    // 检查 docker compose
    let status = Command::new("docker")
        .args(["compose", "version"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    if status.is_err() || !status.unwrap().success() {
        ui::error("Docker Compose 未安装");
        bail!("Docker Compose 不可用");
    }

    Ok(())
}

/// 验证环境变量
async fn validate_env(env_file: &std::path::Path) -> Result<()> {
    ui::header("环境变量验证");

    if !env_file.exists() {
        ui::error(&format!("生产环境变量文件不存在: {}", env_file.display()));
        ui::hint("请创建 infra/env/prod.env 文件，可参考 prod.env.example");
        bail!("环境变量文件不存在");
    }

    // 读取环境变量文件
    let content = tokio::fs::read_to_string(env_file).await?;
    let mut env_vars = std::collections::HashMap::new();

    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        if let Some((key, value)) = line.split_once('=') {
            env_vars.insert(key.trim().to_string(), value.trim().to_string());
        }
    }

    // 检查必需变量
    let mut missing = Vec::new();
    for var in REQUIRED_VARS {
        if !env_vars.contains_key(*var) || env_vars.get(*var).map(|v| v.is_empty()).unwrap_or(true)
        {
            missing.push(*var);
        }
    }

    if !missing.is_empty() {
        ui::error("缺少必需的环境变量:");
        for var in &missing {
            println!("  - {}", var);
        }
        bail!("环境变量验证失败");
    }

    // 检查不安全的默认值
    let mut insecure = Vec::new();

    if let Some(jwt) = env_vars.get("JWT_SECRET_KEY") {
        if jwt.contains("dev") || jwt.contains("secret") || jwt.len() < 32 {
            insecure.push("JWT_SECRET_KEY (使用了不安全的默认值或长度不足)");
        }
    }

    if let Some(pwd) = env_vars.get("POSTGRES_PASSWORD") {
        if pwd.contains("dev") || pwd == "password" || pwd.len() < 12 {
            insecure.push("POSTGRES_PASSWORD (使用了不安全的默认值或长度不足)");
        }
    }

    if !insecure.is_empty() {
        ui::warn("检测到不安全的配置:");
        for item in &insecure {
            println!("  - {}", item);
        }
        println!();
    }

    ui::success("环境变量验证通过");
    Ok(())
}

/// 启动生产环境
async fn start_services(
    compose_file: &std::path::Path,
    env_file: &std::path::Path,
) -> Result<()> {
    // 先验证环境变量
    validate_env(env_file).await?;

    ui::header("启动生产环境");

    // 拉取最新镜像
    ui::step("1/3", "拉取最新镜像");
    let spinner = Spinner::new("拉取镜像中...");

    let status = Command::new("docker")
        .args([
            "compose",
            "-f",
            compose_file.to_str().unwrap(),
            "--env-file",
            env_file.to_str().unwrap(),
            "pull",
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await?;

    spinner.finish_and_clear();

    if !status.success() {
        ui::warn("部分镜像拉取失败，继续启动...");
    } else {
        ui::step_done("镜像拉取完成");
    }

    // 启动服务
    ui::step("2/3", "启动服务");
    let spinner = Spinner::new("启动服务中...");

    let status = Command::new("docker")
        .args([
            "compose",
            "-f",
            compose_file.to_str().unwrap(),
            "--env-file",
            env_file.to_str().unwrap(),
            "up",
            "-d",
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await?;

    spinner.finish_and_clear();

    if !status.success() {
        ui::error("服务启动失败");
        bail!("服务启动失败");
    }

    ui::step_done("服务已启动");

    // 等待服务就绪
    ui::step("3/3", "等待服务就绪");
    let spinner = Spinner::new("等待中...");
    tokio::time::sleep(std::time::Duration::from_secs(10)).await;
    spinner.finish_and_clear();

    // 显示状态
    show_status(compose_file).await?;

    ui::success("生产环境已启动");
    Ok(())
}

/// 停止生产环境
async fn stop_services(compose_file: &std::path::Path, force: bool) -> Result<()> {
    ui::header("停止生产环境");

    if !force {
        ui::warn("即将停止所有生产服务");
        let confirmed = ui::confirm("确定要停止吗?", false)?;
        if !confirmed {
            ui::info("操作已取消");
            return Ok(());
        }
    }

    let spinner = Spinner::new("停止服务中...");

    let status = Command::new("docker")
        .args(["compose", "-f", compose_file.to_str().unwrap(), "down"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await?;

    spinner.finish_and_clear();

    if status.success() {
        ui::success("服务已停止");
    } else {
        ui::error("停止服务失败");
    }

    Ok(())
}

/// 重启服务
async fn restart_services(
    compose_file: &std::path::Path,
    env_file: &std::path::Path,
) -> Result<()> {
    ui::header("重启生产环境");

    let spinner = Spinner::new("重启服务中...");

    let status = Command::new("docker")
        .args([
            "compose",
            "-f",
            compose_file.to_str().unwrap(),
            "--env-file",
            env_file.to_str().unwrap(),
            "restart",
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await?;

    spinner.finish_and_clear();

    if !status.success() {
        ui::error("重启失败");
        bail!("重启失败");
    }

    // 等待服务就绪
    tokio::time::sleep(std::time::Duration::from_secs(5)).await;

    show_status(compose_file).await?;

    ui::success("服务已重启");
    Ok(())
}

/// 显示服务状态
async fn show_status(compose_file: &std::path::Path) -> Result<()> {
    ui::header("服务状态");

    let status = Command::new("docker")
        .args(["compose", "-f", compose_file.to_str().unwrap(), "ps"])
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .await?;

    if !status.success() {
        ui::warn("无法获取服务状态");
    }

    Ok(())
}

/// 显示日志
async fn show_logs(
    compose_file: &std::path::Path,
    service: Option<String>,
    lines: u32,
) -> Result<()> {
    let mut args = vec![
        "compose".to_string(),
        "-f".to_string(),
        compose_file.to_str().unwrap().to_string(),
        "logs".to_string(),
        "-f".to_string(),
        format!("--tail={}", lines),
    ];

    if let Some(svc) = service {
        args.push(svc);
    }

    let _ = Command::new("docker")
        .args(&args)
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .await;

    Ok(())
}

/// 部署更新
async fn deploy(compose_file: &std::path::Path, env_file: &std::path::Path) -> Result<()> {
    ui::header("部署更新");

    // 拉取最新代码
    ui::step("1/4", "拉取最新代码");
    let spinner = Spinner::new("git pull...");

    let status = Command::new("git")
        .args(["pull", "origin", "main"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    spinner.finish_and_clear();

    if status.is_err() || !status.unwrap().success() {
        ui::warn("代码拉取失败，继续部署...");
    } else {
        ui::step_done("代码已更新");
    }

    // 拉取最新镜像
    ui::step("2/4", "拉取最新镜像");
    let spinner = Spinner::new("docker pull...");

    let _ = Command::new("docker")
        .args([
            "compose",
            "-f",
            compose_file.to_str().unwrap(),
            "--env-file",
            env_file.to_str().unwrap(),
            "pull",
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    spinner.finish_and_clear();
    ui::step_done("镜像已更新");

    // 重新构建
    ui::step("3/4", "重新构建");
    let spinner = Spinner::new("docker build...");

    let _ = Command::new("docker")
        .args([
            "compose",
            "-f",
            compose_file.to_str().unwrap(),
            "--env-file",
            env_file.to_str().unwrap(),
            "build",
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    spinner.finish_and_clear();
    ui::step_done("构建完成");

    // 重启服务
    ui::step("4/4", "重启服务");
    let spinner = Spinner::new("重启中...");

    let status = Command::new("docker")
        .args([
            "compose",
            "-f",
            compose_file.to_str().unwrap(),
            "--env-file",
            env_file.to_str().unwrap(),
            "up",
            "-d",
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await?;

    spinner.finish_and_clear();

    if !status.success() {
        ui::error("服务启动失败");
        bail!("部署失败");
    }

    ui::step_done("服务已重启");

    // 显示状态
    show_status(compose_file).await?;

    ui::success("部署完成");
    Ok(())
}

/// 备份数据库
async fn backup_database(
    compose_file: &std::path::Path,
    env_file: &std::path::Path,
    project_root: &std::path::Path,
) -> Result<()> {
    ui::header("数据库备份");

    // 读取环境变量
    let content = tokio::fs::read_to_string(env_file).await?;
    let mut postgres_user = "lesser".to_string();
    let mut postgres_db = "lesser_db".to_string();

    for line in content.lines() {
        if let Some((key, value)) = line.split_once('=') {
            match key.trim() {
                "POSTGRES_USER" => postgres_user = value.trim().to_string(),
                "POSTGRES_DB" => postgres_db = value.trim().to_string(),
                _ => {}
            }
        }
    }

    // 创建备份目录
    let backup_dir = project_root.join("backups");
    tokio::fs::create_dir_all(&backup_dir).await?;

    // 生成备份文件名
    let timestamp = chrono::Local::now().format("%Y%m%d_%H%M%S");
    let backup_file = backup_dir.join(format!("backup_{}.sql", timestamp));

    ui::step("1/1", "创建备份");
    let spinner = Spinner::new("备份中...");

    // 执行 pg_dump
    let output = Command::new("docker")
        .args([
            "compose",
            "-f",
            compose_file.to_str().unwrap(),
            "exec",
            "-T",
            "postgres",
            "pg_dump",
            "-U",
            &postgres_user,
            &postgres_db,
        ])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .await
        .context("执行 pg_dump 失败")?;

    spinner.finish_and_clear();

    if output.status.success() {
        tokio::fs::write(&backup_file, &output.stdout).await?;
        ui::success(&format!("备份已创建: {}", backup_file.display()));
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr);
        ui::error(&format!("备份失败: {}", stderr));
        bail!("备份失败");
    }

    Ok(())
}
