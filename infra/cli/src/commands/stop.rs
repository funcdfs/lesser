use anyhow::Result;
use std::process::Stdio;
use tokio::process::Command;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 stop 命令
pub async fn execute(target: Option<String>) -> Result<()> {
    let config = Config::load()?;

    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    match target.as_deref() {
        None | Some("all") => stop_all(&compose).await,
        Some("infra") => stop_infra(&compose).await,
        Some("service") | Some("services") => stop_services(&compose).await,
        Some("flutter") => stop_flutter().await,
        Some(service) => stop_service(&compose, service).await,
    }
}

/// 停止所有服务
async fn stop_all(compose: &DockerCompose) -> Result<()> {
    ui::banner("停止所有服务");

    // 停止 Flutter 进程
    let _ = stop_flutter_internal().await;

    let spinner = Spinner::new("停止 Docker 服务...");
    compose.down(false, true).await?;
    spinner.finish_and_clear();

    ui::success("🛑 所有服务已停止");
    Ok(())
}

/// 停止基础设施
async fn stop_infra(compose: &DockerCompose) -> Result<()> {
    ui::banner("停止基础设施");
    ui::warn("这将影响所有依赖服务");

    let spinner = Spinner::new("停止基础设施...");
    compose
        .stop(&["postgres", "redis", "rabbitmq", "traefik", "dozzle"])
        .await?;
    spinner.finish_and_clear();

    ui::success("🛑 基础设施已停止");
    Ok(())
}

/// 停止后端服务
async fn stop_services(compose: &DockerCompose) -> Result<()> {
    ui::banner("停止后端服务");

    let services = [
        "gateway",
        "chat",
        "auth-worker",
        "user-worker",
        "post-worker",
        "feed-worker",
        "notification-worker",
        "search-worker",
    ];

    let spinner = Spinner::new("停止后端服务...");
    compose.stop(&services).await?;
    spinner.finish_and_clear();

    ui::success("🛑 后端服务已停止");
    Ok(())
}

/// 停止指定服务
async fn stop_service(compose: &DockerCompose, service: &str) -> Result<()> {
    let spinner = Spinner::new(&format!("停止 {}...", service));
    compose.stop(&[service]).await?;
    spinner.finish_and_clear();

    ui::success(&format!("🛑 {} 已停止", service));
    Ok(())
}

/// 停止 Flutter
async fn stop_flutter() -> Result<()> {
    ui::banner("停止 Flutter");
    stop_flutter_internal().await?;
    ui::success("🛑 Flutter 进程已停止");
    Ok(())
}

/// 停止 Flutter (内部实现)
async fn stop_flutter_internal() -> Result<()> {
    // 停止 flutter 进程
    let _ = Command::new("pkill")
        .args(["-f", "flutter.*run"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    // 停止 chrome 调试进程
    let _ = Command::new("pkill")
        .args(["-f", "chrome.*remote-debugging"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    Ok(())
}
