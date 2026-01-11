use anyhow::Result;
use std::path::PathBuf;
use std::time::Duration;

use crate::cli::StartTarget;
use crate::config::{find_project_root, Config};
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

/// gRPC 服务集群
const SERVICES: ServiceGroup = ServiceGroup {
    name: "Services",
    services: &[
        "auth",
        "user",
        "content",
        "interaction",
        "comment",
        "timeline",
        "search",
        "notification",
        "superuser",
    ],
    emoji: "⚙️",
};

/// Chat 服务
const CHAT: ServiceGroup = ServiceGroup {
    name: "Chat",
    services: &["chat"],
    emoji: "💬",
};

/// Channel 服务（广播频道）
const CHANNEL: ServiceGroup = ServiceGroup {
    name: "Channel",
    services: &["channel"],
    emoji: "📢",
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
        StartTarget::Flutter => start_flutter_interactive(&config).await,
        StartTarget::FlutterWeb => start_flutter_web(&config).await,
        StartTarget::FlutterAndroid => start_flutter_android(&config).await,
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

    // 3. gRPC Services
    start_group(compose, &SERVICES).await?;

    // 4. Chat
    start_group(compose, &CHAT).await?;

    // 5. Channel（广播频道）
    start_group(compose, &CHANNEL).await?;

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
    start_group(compose, &SERVICES).await?;
    start_group(compose, &CHAT).await?;
    start_group(compose, &CHANNEL).await?;

    ui::separator();
    ui::success("后端服务已启动");
    println!();
    ui::kv("Gateway gRPC", "localhost:50053");
    ui::kv("Auth gRPC", "localhost:50054");
    ui::kv("User gRPC", "localhost:50055");
    ui::kv("Content gRPC", "localhost:50056");
    ui::kv("Search gRPC", "localhost:50058");
    ui::kv("Notification gRPC", "localhost:50059");
    ui::kv("Interaction gRPC", "localhost:50060");
    ui::kv("Comment gRPC", "localhost:50061");
    ui::kv("Timeline gRPC", "localhost:50062");
    ui::kv("SuperUser gRPC", "localhost:50063");
    ui::kv("Chat gRPC", "localhost:50052");
    ui::kv("Channel gRPC", "localhost:50062");

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

/// Flutter 交互式选择平台
async fn start_flutter_interactive(config: &Config) -> Result<()> {
    use std::io::{self, Write};

    ui::banner("启动 Flutter 开发环境");
    
    println!();
    println!("  请选择目标平台:");
    println!();
    println!("    [1] 🌐 Web (Chrome)");
    println!("    [2] 📱 Android");
    println!("    [3] 🍎 iOS (macOS only)");
    println!();
    print!("  请输入选项 [1-3]: ");
    io::stdout().flush()?;

    let mut input = String::new();
    io::stdin().read_line(&mut input)?;

    match input.trim() {
        "1" | "web" | "w" => start_flutter_web(config).await,
        "2" | "android" | "a" => start_flutter_android(config).await,
        "3" | "ios" | "i" => start_flutter_ios(config).await,
        _ => {
            ui::error("无效选项，请输入 1、2 或 3");
            Ok(())
        }
    }
}

/// 启动 Flutter Web
async fn start_flutter_web(config: &Config) -> Result<()> {
    use std::fs::File;
    use std::process::Stdio;
    use tokio::process::Command;

    ui::banner("启动 Flutter Web 开发服务器");

    let flutter_dir = &config.flutter_dir;

    if !flutter_dir.exists() {
        ui::error(&format!("Flutter 目录不存在: {}", flutter_dir.display()));
        return Ok(());
    }

    // 检查 flutter
    if !check_flutter().await {
        return Ok(());
    }

    // 安装依赖
    if !flutter_pub_get(flutter_dir).await? {
        return Ok(());
    }

    // 创建日志目录
    let log_dir = create_flutter_log_dir()?;

    // 启动双用户实例
    let users = [
        ("testuser1", config.flutter_port),
        ("testuser2", config.flutter_port + 1),
    ];

    ui::info("启动双用户开发环境...");
    println!();

    for (i, (username, port)) in users.iter().enumerate() {
        // 创建日志文件
        let log_file = log_dir.join(format!("web_{:02}.log", i + 1));
        let log_file_handle = File::create(&log_file)?;
        let log_file_stderr = log_file_handle.try_clone()?;

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
            .stdout(Stdio::from(log_file_handle))
            .stderr(Stdio::from(log_file_stderr))
            .spawn()?;

        ui::step_done(&format!(
            "用户 {} → http://localhost:{} (日志: {})",
            username,
            port,
            log_file.display()
        ));
    }

    Ok(())
}

/// 启动 Flutter Android
async fn start_flutter_android(config: &Config) -> Result<()> {
    use std::fs::File;
    use std::process::Stdio;
    use tokio::process::Command;

    ui::banner("启动 Flutter Android 开发");

    let flutter_dir = &config.flutter_dir;

    if !flutter_dir.exists() {
        ui::error(&format!("Flutter 目录不存在: {}", flutter_dir.display()));
        return Ok(());
    }

    // 检查 flutter
    if !check_flutter().await {
        return Ok(());
    }

    // 安装依赖
    if !flutter_pub_get(flutter_dir).await? {
        return Ok(());
    }

    // 检查 Android 设备，解析 JSON 获取设备 ID
    let spinner = Spinner::new("检查 Android 设备...");
    let devices_output = Command::new("flutter")
        .args(["devices", "--machine"])
        .current_dir(flutter_dir)
        .output()
        .await?;
    spinner.finish_and_clear();

    let devices_str = String::from_utf8_lossy(&devices_output.stdout);
    
    // 解析 JSON 查找 Android 设备（targetPlatform 包含 "android"）
    let android_device_id = parse_android_device_id(&devices_str);

    if android_device_id.is_none() {
        ui::warn("未检测到 Android 设备或模拟器");
        ui::info("请确保:");
        println!("    • Android 模拟器已启动，或");
        println!("    • Android 设备已通过 USB 连接并启用调试模式");
        println!();
        ui::hint("运行 'flutter devices' 查看可用设备");
        return Ok(());
    }

    let device_id = android_device_id.unwrap();
    ui::step_done(&format!("检测到 Android 设备: {}", device_id));

    // 设置 adb reverse 端口转发
    ui::info("设置 ADB 端口转发...");
    let ports = ["50050", "50051", "50060", "50062"]; // Traefik, Gateway, Chat, Channel 端口
    for port in ports {
        let _ = Command::new("adb")
            .args(["reverse", &format!("tcp:{}", port), &format!("tcp:{}", port)])
            .output()
            .await;
    }
    ui::step_done(&format!("ADB 端口转发已配置 ({})", ports.join(", ")));

    // 创建日志目录和文件
    let log_dir = create_flutter_log_dir()?;
    let log_file = log_dir.join("android.log");
    let log_file_handle = File::create(&log_file)?;
    let log_file_stderr = log_file_handle.try_clone()?;

    // 启动 Flutter，使用实际设备 ID
    ui::info(&format!("启动 Flutter Android... (日志: {})", log_file.display()));
    println!();

    let status = Command::new("flutter")
        .args(["run", "-d", &device_id])
        .current_dir(flutter_dir)
        .stdout(Stdio::from(log_file_handle))
        .stderr(Stdio::from(log_file_stderr))
        .status()
        .await?;

    if !status.success() {
        ui::error("Flutter 启动失败");
    }

    Ok(())
}

/// 从 flutter devices --machine 的 JSON 输出中解析 Android 设备 ID
fn parse_android_device_id(json_str: &str) -> Option<String> {
    // 简单解析：查找 targetPlatform 包含 "android" 的设备，提取其 id
    // JSON 格式: [{"id":"R52T9011ZYB","targetPlatform":"android-arm64",...},...]
    
    // 查找所有 "targetPlatform":"android 的位置
    let mut search_pos = 0;
    while let Some(platform_pos) = json_str[search_pos..].find("\"targetPlatform\"") {
        let abs_pos = search_pos + platform_pos;
        
        // 检查这个 targetPlatform 的值是否包含 android
        if let Some(value_start) = json_str[abs_pos..].find(':') {
            let value_area = &json_str[abs_pos + value_start..];
            if let Some(quote_start) = value_area.find('"') {
                let after_quote = &value_area[quote_start + 1..];
                if let Some(quote_end) = after_quote.find('"') {
                    let platform_value = &after_quote[..quote_end];
                    if platform_value.contains("android") {
                        // 找到 Android 设备，向前查找对应的 id
                        // 从当前位置向前找最近的 "id":"xxx"
                        let before_platform = &json_str[..abs_pos];
                        if let Some(id_pos) = before_platform.rfind("\"id\"") {
                            let id_area = &json_str[id_pos..abs_pos];
                            if let Some(colon) = id_area.find(':') {
                                let after_colon = &id_area[colon + 1..];
                                if let Some(q1) = after_colon.find('"') {
                                    let after_q1 = &after_colon[q1 + 1..];
                                    if let Some(q2) = after_q1.find('"') {
                                        return Some(after_q1[..q2].to_string());
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        search_pos = abs_pos + 1;
    }
    None
}

/// 启动 Flutter iOS
async fn start_flutter_ios(config: &Config) -> Result<()> {
    use std::fs::File;
    use std::process::Stdio;
    use tokio::process::Command;

    ui::banner("启动 Flutter iOS 开发");

    let flutter_dir = &config.flutter_dir;

    if !flutter_dir.exists() {
        ui::error(&format!("Flutter 目录不存在: {}", flutter_dir.display()));
        return Ok(());
    }

    // 检查是否是 macOS
    if std::env::consts::OS != "macos" {
        ui::error("iOS 开发仅支持 macOS");
        return Ok(());
    }

    // 检查 flutter
    if !check_flutter().await {
        return Ok(());
    }

    // 安装依赖
    if !flutter_pub_get(flutter_dir).await? {
        return Ok(());
    }

    // 创建日志目录和文件
    let log_dir = create_flutter_log_dir()?;
    let log_file = log_dir.join("ios.log");
    let log_file_handle = File::create(&log_file)?;
    let log_file_stderr = log_file_handle.try_clone()?;

    // 启动 Flutter
    ui::info(&format!("启动 Flutter iOS... (日志: {})", log_file.display()));
    println!();

    let status = Command::new("flutter")
        .args(["run", "-d", "ios"])
        .current_dir(flutter_dir)
        .stdout(Stdio::from(log_file_handle))
        .stderr(Stdio::from(log_file_stderr))
        .status()
        .await?;

    if !status.success() {
        ui::error("Flutter 启动失败");
    }

    Ok(())
}

/// 检查 Flutter 是否安装
async fn check_flutter() -> bool {
    use std::process::Stdio;
    use tokio::process::Command;

    let flutter_check = Command::new("flutter")
        .arg("--version")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    if !flutter_check.map(|s| s.success()).unwrap_or(false) {
        ui::error("Flutter 未安装，请先安装 Flutter SDK");
        ui::info("安装指南: https://docs.flutter.dev/get-started/install");
        return false;
    }
    true
}

/// 创建 Flutter 日志目录
fn create_flutter_log_dir() -> Result<PathBuf> {
    let project_root = find_project_root()?;
    let log_dir = project_root.join("logs/flutter");
    std::fs::create_dir_all(&log_dir)?;
    Ok(log_dir)
}

/// 执行 flutter pub get
async fn flutter_pub_get(flutter_dir: &std::path::Path) -> Result<bool> {
    use std::process::Stdio;
    use tokio::process::Command;

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
        return Ok(false);
    }
    ui::step_done("依赖已安装");
    Ok(true)
}

/// 打印服务信息
fn print_service_info(config: &Config) {
    ui::success("🎉 Lesser 开发环境已就绪!");
    println!();

    println!("  {} gRPC 端点", ui::style_dim("▸"));
    ui::kv("    Gateway", "localhost:50053");
    ui::kv("    Auth", "localhost:50054");
    ui::kv("    User", "localhost:50055");
    ui::kv("    Content", "localhost:50056");
    ui::kv("    Search", "localhost:50058");
    ui::kv("    Notification", "localhost:50059");
    ui::kv("    Interaction", "localhost:50060");
    ui::kv("    Comment", "localhost:50061");
    ui::kv("    Timeline", "localhost:50062");
    ui::kv("    SuperUser", "localhost:50063");
    ui::kv("    Chat", "localhost:50052");
    ui::kv("    Channel", "localhost:50062");
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
