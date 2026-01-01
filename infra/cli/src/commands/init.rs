use anyhow::Result;
use std::time::Duration;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 测试用户配置
const TEST_USERS: &[(&str, &str, &str)] = &[
    ("testuser1", "testuser1@example.com", "testtesttest"),
    ("testuser2", "testuser2@example.com", "testtesttest"),
];

/// 执行 init 命令
pub async fn execute(force: bool) -> Result<()> {
    let config = Config::load()?;

    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    ui::banner("初始化 Lesser 开发环境");

    // 检查是否已有运行的服务
    let statuses = compose.ps_json().await.unwrap_or_default();
    if !statuses.is_empty() && !force {
        ui::warn("检测到已有运行的服务");
        let confirmed = ui::confirm("是否先清理再初始化?", true)?;
        if confirmed {
            let spinner = Spinner::new("清理现有环境...");
            compose.down(true, true).await?;
            spinner.finish_and_clear();
            ui::step_done("环境已清理");
        }
    }

    // Step 1: 启动基础设施
    ui::step("1/4", "启动基础设施");
    let spinner = Spinner::new("启动 PostgreSQL, Redis, RabbitMQ...");
    compose
        .up_wait(&["postgres", "redis", "rabbitmq", "traefik", "dozzle"])
        .await?;
    spinner.finish_and_clear();
    ui::step_done("基础设施已启动");

    // 等待数据库就绪
    let spinner = Spinner::new("等待数据库就绪...");
    wait_for_postgres(&compose).await?;
    spinner.finish_and_clear();

    // Step 2: 启动后端服务
    ui::step("2/4", "启动后端服务");
    let spinner = Spinner::new("启动 Gateway, Workers, Chat...");
    compose
        .up_wait(&[
            "gateway",
            "chat",
            "auth-worker",
            "user-worker",
            "post-worker",
            "feed-worker",
            "notification-worker",
            "search-worker",
        ])
        .await?;
    spinner.finish_and_clear();
    ui::step_done("后端服务已启动");

    // 等待服务就绪
    let spinner = Spinner::new("等待服务就绪...");
    tokio::time::sleep(Duration::from_secs(3)).await;
    spinner.finish_and_clear();

    // Step 3: 创建测试用户
    ui::step("3/4", "创建测试用户");
    create_test_users().await?;

    // Step 4: 完成
    ui::step("4/4", "初始化完成");
    println!();

    // 打印结果
    print_init_result(&config);

    Ok(())
}

/// 等待 PostgreSQL 就绪
async fn wait_for_postgres(compose: &DockerCompose) -> Result<()> {
    for _ in 0..30 {
        let result = compose
            .exec(
                "postgres",
                &["pg_isready", "-U", "lesser"],
                false,
            )
            .await;

        if result.is_ok() {
            return Ok(());
        }

        tokio::time::sleep(Duration::from_secs(1)).await;
    }

    anyhow::bail!("PostgreSQL 启动超时")
}

/// 创建测试用户
async fn create_test_users() -> Result<()> {
    use std::process::Stdio;
    use tokio::process::Command;

    for (username, email, password) in TEST_USERS {
        let spinner = Spinner::new(&format!("创建用户 {}...", username));

        // 使用 grpcurl 调用 Gateway 注册接口
        let payload = format!(
            r#"{{"username": "{}", "email": "{}", "password": "{}"}}"#,
            username, email, password
        );

        let result = Command::new("grpcurl")
            .args([
                "-plaintext",
                "-d",
                &payload,
                "localhost:50053",
                "gateway.GatewayService/Register",
            ])
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .output()
            .await;

        spinner.finish_and_clear();

        match result {
            Ok(output) => {
                let stdout = String::from_utf8_lossy(&output.stdout);
                let stderr = String::from_utf8_lossy(&output.stderr);

                if output.status.success() && stdout.contains("access_token") {
                    ui::step_done(&format!("用户 {} 创建成功", username));
                } else if stderr.contains("already exists") || stdout.contains("already exists") {
                    ui::step_done(&format!("用户 {} 已存在", username));
                } else {
                    ui::warn(&format!("用户 {} 创建失败: {}", username, stderr.trim()));
                }
            }
            Err(e) => {
                // grpcurl 可能未安装
                if e.kind() == std::io::ErrorKind::NotFound {
                    ui::warn("grpcurl 未安装，跳过用户创建");
                    ui::hint("安装: brew install grpcurl");
                    break;
                }
                ui::warn(&format!("用户 {} 创建失败: {}", username, e));
            }
        }
    }

    Ok(())
}

/// 打印初始化结果
fn print_init_result(_config: &Config) {
    ui::separator();
    ui::success("🎉 Lesser 开发环境初始化完成!");
    println!();

    println!("  {} 测试账号", ui::style_dim("▸"));
    for (username, email, password) in TEST_USERS {
        println!("    {} / {} / {}", username, email, password);
    }
    println!();

    println!("  {} 服务端点", ui::style_dim("▸"));
    ui::kv("    Gateway gRPC", "localhost:50053");
    ui::kv("    Chat gRPC", "localhost:50052");
    ui::kv("    Chat WebSocket", "ws://localhost:8081/ws/chat");
    println!();

    println!("  {} 管理界面", ui::style_dim("▸"));
    ui::kv("    Traefik", "http://localhost:8088");
    ui::kv("    RabbitMQ", "http://localhost:15672 (guest/guest)");
    ui::kv("    Dozzle", "http://localhost:9999");
    println!();

    println!("  {} 下一步", ui::style_dim("▸"));
    println!(
        "    运行 {} 启动 Flutter 开发服务器",
        ui::style_cmd("devlesser start flutter")
    );
    println!(
        "    运行 {} 查看服务状态",
        ui::style_cmd("devlesser status")
    );
    println!(
        "    运行 {} 查看日志",
        ui::style_cmd("devlesser logs <service>")
    );
    println!();
}
