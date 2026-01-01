use anyhow::{bail, Result};

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui;

/// 执行 enter 命令 - 进入容器
pub async fn execute(service: String) -> Result<()> {
    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // 规范化服务名称并获取命令
    let (container_name, command) = get_service_command(&service)?;

    // 检查服务是否运行
    let statuses = compose.ps_json().await?;
    let service_running = statuses
        .iter()
        .any(|s| s.service_name() == container_name && s.is_running());

    if !service_running {
        ui::error(&format!("服务 {} 未运行", container_name));
        ui::info(&format!("运行 'devlesser start {}' 启动服务", container_name));
        bail!("服务未运行");
    }

    // 进入容器
    ui::step(&format!("进入 {} 容器...", container_name));
    compose.exec(&container_name, &command.iter().map(|s| s.as_str()).collect::<Vec<_>>(), true).await?;

    Ok(())
}

/// 获取服务命令
fn get_service_command(service: &str) -> Result<(String, Vec<String>)> {
    let service_lower = service.to_lowercase();
    
    match service_lower.as_str() {
        // Gateway / Go
        "gateway" => Ok(("gateway".to_string(), vec!["sh".to_string()])),
        // Chat / Go
        "chat" | "go" => Ok(("chat".to_string(), vec!["sh".to_string()])),
        // PostgreSQL / DB - 从环境变量读取连接参数
        "postgres" | "postgresql" | "db" | "database" => {
            let user = std::env::var("POSTGRES_USER").unwrap_or_else(|_| "lesser".to_string());
            let db = std::env::var("POSTGRES_DB").unwrap_or_else(|_| "lesser_db".to_string());
            Ok((
                "postgres".to_string(),
                vec!["psql".to_string(), "-U".to_string(), user, "-d".to_string(), db],
            ))
        }
        // Redis / Cache
        "redis" | "cache" => Ok(("redis".to_string(), vec!["redis-cli".to_string()])),
        // Traefik
        "traefik" => Ok(("traefik".to_string(), vec!["sh".to_string()])),
        // RabbitMQ
        "rabbitmq" | "mq" | "rabbit" => Ok(("rabbitmq".to_string(), vec!["sh".to_string()])),
        // Workers
        "auth-worker" | "auth" => Ok(("auth-worker".to_string(), vec!["sh".to_string()])),
        "post-worker" | "post" => Ok(("post-worker".to_string(), vec!["sh".to_string()])),
        "feed-worker" | "feed" => Ok(("feed-worker".to_string(), vec!["sh".to_string()])),
        "user-worker" | "user" => Ok(("user-worker".to_string(), vec!["sh".to_string()])),
        "notification-worker" | "notification" => Ok(("notification-worker".to_string(), vec!["sh".to_string()])),
        "search-worker" | "search" => Ok(("search-worker".to_string(), vec!["sh".to_string()])),
        "chat-worker" => Ok(("chat-worker".to_string(), vec!["sh".to_string()])),
        _ => {
            ui::error(&format!("未知服务: {}", service));
            println!();
            print_usage();
            bail!("未知服务");
        }
    }
}

/// 打印使用说明
fn print_usage() {
    println!("用法: devlesser enter <service>");
    println!();
    println!("可用服务:");
    ui::separator();
    println!("  gateway             进入 Gateway 容器 (sh)");
    println!("  chat, go            进入 Chat 容器 (sh)");
    println!("  postgres, db        进入 PostgreSQL (psql)");
    println!("  redis, cache        进入 Redis (redis-cli)");
    println!("  traefik             进入 Traefik 容器 (sh)");
    println!("  rabbitmq, mq        进入 RabbitMQ 容器 (sh)");
    println!("  auth-worker         进入 Auth Worker 容器 (sh)");
    println!("  post-worker         进入 Post Worker 容器 (sh)");
    println!("  feed-worker         进入 Feed Worker 容器 (sh)");
    println!();
}
