use anyhow::Result;
use std::time::Duration;

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
const INFRA: ServiceGroup = ServiceGroup {
    name: "基础设施",
    services: &["postgres", "redis", "rabbitmq", "traefik", "dozzle"],
    emoji: "🔧",
};

/// Gateway 服务
const GATEWAY: ServiceGroup = ServiceGroup {
    name: "Gateway",
    services: &["gateway"],
    emoji: "🚪",
};

/// Worker 服务
const WORKERS: ServiceGroup = ServiceGroup {
    name: "Workers",
    services: &[
        "auth-worker",
        "user-worker", 
        "post-worker",
        "feed-worker",
        "notification-worker",
        "search-worker",
    ],
    emoji: "⚙️",
};

/// Chat 服务
const CHAT: ServiceGroup = ServiceGroup {
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
        StartTarget::All => start_all(&compose, &config).await,
        StartTarget::Infra => start_infra(&compose).await,
        StartTarget::Service => start_services(&compose).await,
        StartTarget::Flutter => start_flutter(&config).await,
    }
}

/// 启动所有服务
async fn start_all(compose: &DockerCompose, config: &Config) -> Result<()> {
    ui::banner("启动 Lesser 开发环境");

    // 1. 基础设施
    start_group(compose, &INFRA).await?;
    
    // 等待基础设施就绪
    let spinner = Spinner::new("等待基础设施就绪...");
    tokio::time::sleep(Duration::from_secs(3)).await;
    spinner.finish_and_clear();

    // 2. Gateway
    start_group(compose, &GATEWAY).await?;

    // 3. Workers
    start_group(compose, &WORKERS).await?;

    // 4. Chat
    start_group(compose, &CHAT).await?;

    // 打印服务信息
    ui::separator();
    print_service_info(config);

    Ok(())
}

/// 仅启动基础设施
async fn start_infra(compose: &DockerCompose) -> Result<()> {
    ui::banner("启动基础设施");
    start_group(compose, &INFRA).await?;
    
    ui::separator();
    ui::success("基础设施已就绪");
    println!();
    ui::kv("PostgreSQL", "localhost:5432");
    ui::kv("Redis", "localhost:6379");
    ui::kv("RabbitMQ", "localhost:5672 (管理: http://localhost:15672)");
    ui::kv("Traefik", "http://localhost:8088");
    
    Ok(())
}

/// 仅启动后端服务
async fn start_services(compose: &DockerCompose) -> Result<()> {
    ui::banner("启动后端服务");

    // 确保基础设施运行
    let spinner = Spinner::new("检查基础设施...");
    compose.up_wait(INFRA.services).await?;
    spinner.finish_and_clear();
    ui::step_done("基础设施就绪");

    start_group(compose, &GATEWAY).await?;
    start_group(compose, &WORKERS).await?;
    start_group(compose, &CHAT).await?;

    ui::separator();
    ui::success("后端服务已启动");
    println!();
    ui::kv("Gateway gRPC", "localhost:50053");
    ui::kv("Chat gRPC", "localhost:50052");
    ui::kv("Chat WebSocket", "ws://localhost:8081/ws/chat");

    Ok(())
}

/// 启动指定服务组
async fn start_group(compose: &DockerCompose, group: &ServiceGroup) -> Result<()> {
    let spinner = Spinner::new(&format!("启动 {}...", group.name));
    compose.up_wait(group.services).await?;
    spinner.finish_and_clear();
    ui::step_done(&format!("{} {} 已启动", group.emoji, group.name));
    Ok(())
}

/// 启动 Flutter Web
async fn start_flutter(config: &Config) -> Result<()> {
    use std::process::Stdio;
    use tokio::process::Command;

    ui::banner("启动 Flutter Web 开发服务器");

    let flutter_dir = &config.flutter_dir;

    if !flutter_dir.exists() {
        ui::error(&format!("Flutter 目录不存在: {}", flutter_dir.display()));
        return Ok(());
    }

    // 检查 flutter
    let flutter_check = Command::new("flutter")
        .arg("--version")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    if !flutter_check.map(|s| s.success()).unwrap_or(false) {
        ui::error("Flutter 未安装，请先安装 Flutter SDK");
        ui::info("安装指南: https://docs.flutter.dev/get-started/install");
        return Ok(());
    }

    // 安装依赖
    let spinner = Spinner::new("安装 Flutter 依赖...");
    let pub_get = Command::new("flutter")
        .args(["pub", "get"])
        .current_dir(flutter_dir)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await?;

    spinner.finish_and_clear();

    if !pub_get.success() {
        ui::error("flutter pub get 失败");
        return Ok(());
    }
    ui::step_done("依赖已安装");

    // 启动双用户实例
    let users = [
        ("testuser1", config.flutter_port),
        ("testuser2", config.flutter_port + 1),
    ];

    ui::info("启动双用户开发环境...");
    println!();

    for (username, port) in users {
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

        ui::step_done(&format!("用户 {} → http://localhost:{}", username, port));
    }

    Ok(())
}

/// 打印服务信息
fn print_service_info(config: &Config) {
    ui::success("🎉 Lesser 开发环境已就绪!");
    println!();

    println!("  {} gRPC 端点", ui::style_dim("▸"));
    ui::kv("    Gateway", "localhost:50053");
    ui::kv("    Chat", "localhost:50052");
    println!();

    println!("  {} WebSocket", ui::style_dim("▸"));
    ui::kv("    Chat", "ws://localhost:8081/ws/chat");
    println!();

    println!("  {} 管理界面", ui::style_dim("▸"));
    ui::kv("    Traefik", "http://localhost:8088");
    ui::kv("    RabbitMQ", "http://localhost:15672");
    ui::kv("    Dozzle", "http://localhost:9999");
    println!();

    println!("  {} Flutter Web", ui::style_dim("▸"));
    ui::kv("    用户1", &format!("http://localhost:{}", config.flutter_port));
    ui::kv("    用户2", &format!("http://localhost:{}", config.flutter_port + 1));
    println!();

    ui::hint("运行 'devlesser status' 查看服务状态");
    ui::hint("运行 'devlesser logs <service>' 查看日志");
}
