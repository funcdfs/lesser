use anyhow::Result;

use crate::cli::StartTarget;
use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 服务组定义
struct ServiceGroup {
    name: &'static str,
    services: &'static [&'static str],
    emoji: &'static str,
}

/// 基础设施服务
const INFRA_SERVICES: ServiceGroup = ServiceGroup {
    name: "基础设施",
    services: &["postgres", "redis", "traefik", "dozzle"],
    emoji: "🔧",
};

/// Django 服务
const DJANGO_SERVICES: ServiceGroup = ServiceGroup {
    name: "Django",
    services: &["django"],
    emoji: "🐍",
};

/// Chat 服务
const CHAT_SERVICES: ServiceGroup = ServiceGroup {
    name: "Chat",
    services: &["chat"],
    emoji: "💬",
};

/// 执行 start 命令
pub async fn execute(target: StartTarget) -> Result<()> {
    let config = Config::load()?;
    
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    match target {
        StartTarget::All => start_all(&compose).await,
        StartTarget::Service => start_services(&compose).await,
        StartTarget::Infra => start_group(&compose, &INFRA_SERVICES).await,
        StartTarget::Django => start_group(&compose, &DJANGO_SERVICES).await,
        StartTarget::Chat => start_group(&compose, &CHAT_SERVICES).await,
        StartTarget::Client => start_clients(&config).await,
        StartTarget::Flutter => start_flutter(&config).await,
        StartTarget::React => start_react(&config).await,
    }
}

/// 启动所有服务
async fn start_all(compose: &DockerCompose) -> Result<()> {
    ui::header("启动所有服务");
    
    let spinner = Spinner::new("正在启动基础设施...");
    compose.up_wait(INFRA_SERVICES.services).await?;
    spinner.finish_and_clear();
    ui::success(&format!("{} 基础设施已启动", INFRA_SERVICES.emoji));
    
    let spinner = Spinner::new("正在启动 Django 服务...");
    compose.up_wait(DJANGO_SERVICES.services).await?;
    spinner.finish_and_clear();
    ui::success(&format!("{} Django 服务已启动", DJANGO_SERVICES.emoji));
    
    let spinner = Spinner::new("正在启动 Chat 服务...");
    compose.up_wait(CHAT_SERVICES.services).await?;
    spinner.finish_and_clear();
    ui::success(&format!("{} Chat 服务已启动", CHAT_SERVICES.emoji));
    
    ui::separator();
    print_service_urls();
    
    Ok(())
}

/// 启动后端服务 (Django + Chat)
async fn start_services(compose: &DockerCompose) -> Result<()> {
    ui::header("启动后端服务");
    
    // 先确保基础设施运行
    let spinner = Spinner::new("正在检查基础设施...");
    compose.up_wait(INFRA_SERVICES.services).await?;
    spinner.finish_and_clear();
    ui::success(&format!("{} 基础设施就绪", INFRA_SERVICES.emoji));
    
    let spinner = Spinner::new("正在启动 Django 服务...");
    compose.up_wait(DJANGO_SERVICES.services).await?;
    spinner.finish_and_clear();
    ui::success(&format!("{} Django 服务已启动", DJANGO_SERVICES.emoji));
    
    let spinner = Spinner::new("正在启动 Chat 服务...");
    compose.up_wait(CHAT_SERVICES.services).await?;
    spinner.finish_and_clear();
    ui::success(&format!("{} Chat 服务已启动", CHAT_SERVICES.emoji));
    
    ui::separator();
    print_service_urls();
    
    Ok(())
}

/// 启动指定服务组
async fn start_group(compose: &DockerCompose, group: &ServiceGroup) -> Result<()> {
    ui::header(&format!("启动{}", group.name));
    
    let spinner = Spinner::new(&format!("正在启动{}...", group.name));
    compose.up_wait(group.services).await?;
    spinner.finish_and_clear();
    
    ui::success(&format!("{} {} 已启动", group.emoji, group.name));
    
    Ok(())
}

/// 启动所有客户端
async fn start_clients(config: &Config) -> Result<()> {
    ui::header("启动客户端");
    
    // 启动 Flutter
    if let Err(e) = start_flutter_internal(config).await {
        ui::warn(&format!("Flutter 启动失败: {}", e));
    }
    
    // 启动 React
    if let Err(e) = start_react_internal(config).await {
        ui::warn(&format!("React 启动失败: {}", e));
    }
    
    Ok(())
}

/// 启动 Flutter Web
async fn start_flutter(config: &Config) -> Result<()> {
    ui::header("启动 Flutter Web");
    start_flutter_internal(config).await
}

/// 启动 Flutter Web (内部实现)
async fn start_flutter_internal(config: &Config) -> Result<()> {
    use std::process::Stdio;
    use tokio::process::Command;
    
    let flutter_dir = &config.flutter_dir;
    
    if !flutter_dir.exists() {
        anyhow::bail!("Flutter 目录不存在: {}", flutter_dir.display());
    }
    
    // 检查 flutter 是否安装
    let flutter_check = Command::new("flutter")
        .arg("--version")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;
    
    if !flutter_check.map(|s| s.success()).unwrap_or(false) {
        anyhow::bail!("Flutter 未安装，请先安装 Flutter SDK");
    }
    
    let spinner = Spinner::new("正在安装 Flutter 依赖...");
    
    // 运行 flutter pub get
    let pub_get = Command::new("flutter")
        .args(["pub", "get"])
        .current_dir(flutter_dir)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await?;
    
    if !pub_get.success() {
        spinner.finish_and_clear();
        anyhow::bail!("flutter pub get 失败");
    }
    
    spinner.finish_and_clear();
    ui::success("📦 Flutter 依赖已安装");
    
    // 定义要启动的用户
    let users = [
        ("testuser1", config.flutter_port),
        ("testuser2", config.flutter_port + 1),
    ];

    ui::info("🚀 正在启动双用户开发环境...");

    for (username, port) in users {
        ui::step(&format!("启动实例: {} (端口: {})", username, port));
        
        Command::new("flutter")
            .args([
                "run",
                "-d",
                "chrome",
                "--web-port",
                &port.to_string(),
                &format!("--dart-define=AUTO_LOGIN_EMAIL={}@example.com", username),
                "--dart-define=AUTO_LOGIN_PASSWORD=testtesttest",
            ])
            .current_dir(flutter_dir)
            .stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .spawn()?;
    }
    
    ui::separator();
    ui::success("🌐 Flutter Web 实例已启动:");
    for (username, port) in users {
        ui::url(&format!("用户 ({})", username), &format!("http://localhost:{}", port));
    }
    
    Ok(())
}

/// 启动 React Web
async fn start_react(config: &Config) -> Result<()> {
    ui::header("启动 React Web");
    start_react_internal(config).await
}

/// 启动 React Web (内部实现)
async fn start_react_internal(config: &Config) -> Result<()> {
    use std::process::Stdio;
    use tokio::process::Command;
    
    let react_dir = &config.react_dir;
    
    if !react_dir.exists() {
        anyhow::bail!("React 目录不存在: {}", react_dir.display());
    }
    
    // 检查 npm 是否安装
    let npm_check = Command::new("npm")
        .arg("--version")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;
    
    if !npm_check.map(|s| s.success()).unwrap_or(false) {
        anyhow::bail!("npm 未安装，请先安装 Node.js");
    }
    
    let spinner = Spinner::new("正在安装 React 依赖...");
    
    // 运行 npm install
    let npm_install = Command::new("npm")
        .args(["install"])
        .current_dir(react_dir)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await?;
    
    if !npm_install.success() {
        spinner.finish_and_clear();
        anyhow::bail!("npm install 失败");
    }
    
    spinner.finish_and_clear();
    ui::success("📦 React 依赖已安装");
    
    // 启动 React 开发服务器 (后台运行)
    ui::info(&format!(
        "⚛️  正在启动 React 开发服务器 (端口: {})...",
        config.react_port
    ));
    
    // spawn 后进程会在后台运行
    Command::new("npm")
        .args(["run", "dev"])
        .current_dir(react_dir)
        .env("PORT", config.react_port.to_string())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .spawn()?;
    
    ui::success(&format!(
        "🌐 React Web: http://localhost:{}",
        config.react_port
    ));
    
    Ok(())
}

/// 打印服务访问地址
fn print_service_urls() {
    ui::info("服务访问地址:");
    ui::url("Django API", "http://localhost:8000");
    ui::url("Django Admin", "http://localhost:8000/admin");
    ui::url("Chat HTTP", "http://localhost:8081");
    ui::url("Traefik Dashboard", "http://localhost:8088");
}
