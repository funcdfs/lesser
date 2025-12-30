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
        Some("service") | Some("services") => stop_services(&compose).await,
        Some("infra") => stop_infra(&compose).await,
        Some("django") => stop_service(&compose, "django").await,
        Some("chat") => stop_service(&compose, "chat").await,
        Some("client") | Some("clients") => stop_clients().await,
        Some("flutter") => stop_flutter().await,
        Some("react") => stop_react().await,
        Some(service) => stop_service(&compose, service).await,
    }
}

/// 停止所有服务
async fn stop_all(compose: &DockerCompose) -> Result<()> {
    ui::header("停止所有服务");
    
    let spinner = Spinner::new("正在停止所有服务...");
    compose.down(false, true).await?;
    spinner.finish_and_clear();
    
    ui::success("🛑 所有服务已停止");
    
    Ok(())
}

/// 停止后端服务 (Django + Chat)
async fn stop_services(compose: &DockerCompose) -> Result<()> {
    ui::header("停止后端服务");
    
    let spinner = Spinner::new("正在停止后端服务...");
    compose.stop(&["django", "chat"]).await?;
    spinner.finish_and_clear();
    
    ui::success("🛑 后端服务已停止");
    
    Ok(())
}

/// 停止基础设施服务
async fn stop_infra(compose: &DockerCompose) -> Result<()> {
    ui::header("停止基础设施");
    
    ui::warn("停止基础设施将影响所有依赖服务");
    
    let spinner = Spinner::new("正在停止基础设施...");
    compose.stop(&["postgres", "redis", "traefik"]).await?;
    spinner.finish_and_clear();
    
    ui::success("🛑 基础设施已停止");
    
    Ok(())
}

/// 停止指定服务
async fn stop_service(compose: &DockerCompose, service: &str) -> Result<()> {
    ui::step(&format!("停止服务: {}", service));
    
    let spinner = Spinner::new(&format!("正在停止 {}...", service));
    compose.stop(&[service]).await?;
    spinner.finish_and_clear();
    
    ui::success(&format!("🛑 {} 已停止", service));
    
    Ok(())
}

/// 停止所有客户端
async fn stop_clients() -> Result<()> {
    ui::header("停止客户端");
    
    // 停止 Flutter
    if let Err(e) = stop_flutter_internal().await {
        ui::warn(&format!("停止 Flutter 失败: {}", e));
    }
    
    // 停止 React
    if let Err(e) = stop_react_internal().await {
        ui::warn(&format!("停止 React 失败: {}", e));
    }
    
    Ok(())
}

/// 停止 Flutter
async fn stop_flutter() -> Result<()> {
    ui::step("停止 Flutter");
    stop_flutter_internal().await
}

/// 停止 Flutter (内部实现)
async fn stop_flutter_internal() -> Result<()> {
    let spinner = Spinner::new("正在停止 Flutter 进程...");
    
    // 使用 pkill 停止 flutter 进程
    // 注意：pkill 返回 1 表示没有匹配的进程，这不是错误
    let result = Command::new("pkill")
        .args(["-f", "flutter.*run"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;
    
    spinner.finish_and_clear();
    
    match result {
        Ok(status) if status.success() || status.code() == Some(1) => {
            // 退出码 0 = 成功终止进程，退出码 1 = 没有匹配的进程
            if status.success() {
                ui::success("📱 Flutter 进程已停止");
            } else {
                ui::info("📱 没有运行中的 Flutter 进程");
            }
        }
        Ok(status) => {
            ui::warn(&format!("pkill 返回异常退出码: {:?}", status.code()));
        }
        Err(e) => {
            ui::warn(&format!("执行 pkill 失败: {}", e));
        }
    }
    
    Ok(())
}

/// 停止 React
async fn stop_react() -> Result<()> {
    ui::step("停止 React");
    stop_react_internal().await
}

/// 停止 React (内部实现)
async fn stop_react_internal() -> Result<()> {
    let spinner = Spinner::new("正在停止 React 进程...");
    
    // 尝试停止 next 进程 (Next.js)
    let _ = Command::new("pkill")
        .args(["-f", "next-server"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;
    
    // 尝试停止 vite 进程 (Vite)
    let _ = Command::new("pkill")
        .args(["-f", "vite"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;
    
    // 尝试停止 node 开发服务器进程
    // 使用更精确的匹配模式避免误杀其他 node 进程
    let result = Command::new("pkill")
        .args(["-f", "node.*dev"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;
    
    spinner.finish_and_clear();
    
    match result {
        Ok(status) if status.success() => {
            ui::success("⚛️  React 进程已停止");
        }
        _ => {
            ui::info("⚛️  没有运行中的 React 进程");
        }
    }
    
    Ok(())
}
