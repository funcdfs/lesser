use anyhow::Result;
use console::style;

use crate::config::Config;
use crate::docker::{ContainerStats, DockerCompose, ServiceStatus};
use crate::ui::{self, Spinner};

/// 服务分组
const SERVICE_GROUPS: &[(&str, &[&str])] = &[
    (
        "基础设施",
        &["postgres", "redis", "rabbitmq", "traefik", "dozzle"],
    ),
    ("网关", &["gateway"]),
    (
        "Workers",
        &[
            "auth-worker",
            "user-worker",
            "post-worker",
            "feed-worker",
            "notification-worker",
            "search-worker",
        ],
    ),
    ("聊天", &["chat"]),
];

/// 执行 status 命令
pub async fn execute() -> Result<()> {
    let config = Config::load()?;

    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    ui::banner("服务状态");

    let spinner = Spinner::new("获取服务状态...");
    let statuses = compose.ps_json().await?;
    let stats = compose.stats().await.unwrap_or_default();
    spinner.finish_and_clear();

    if statuses.is_empty() {
        ui::info("没有运行中的服务");
        println!();
        ui::hint("运行 'devlesser start' 启动服务");
        ui::hint("运行 'devlesser init' 初始化环境");
        return Ok(());
    }

    // 按分组显示
    for (group_name, group_services) in SERVICE_GROUPS {
        let group_statuses: Vec<_> = statuses
            .iter()
            .filter(|s| group_services.contains(&s.service_name()))
            .collect();

        if group_statuses.is_empty() {
            continue;
        }

        println!("  {} {}", ui::style_dim("▸"), group_name);
        
        for status in group_statuses {
            print_service_status(status, &stats);
        }
        println!();
    }

    // 显示未分组的服务
    let grouped_services: Vec<&str> = SERVICE_GROUPS
        .iter()
        .flat_map(|(_, services)| services.iter().copied())
        .collect();

    let ungrouped: Vec<_> = statuses
        .iter()
        .filter(|s| !grouped_services.contains(&s.service_name()))
        .collect();

    if !ungrouped.is_empty() {
        println!("  {} 其他", ui::style_dim("▸"));
        for status in ungrouped {
            print_service_status(status, &stats);
        }
        println!();
    }

    // 显示快速访问链接
    print_quick_links(&statuses);

    Ok(())
}

/// 打印单个服务状态
fn print_service_status(status: &ServiceStatus, stats: &[ContainerStats]) {
    let name = status.service_name();

    // 状态图标
    let status_icon = if status.is_running() {
        match status.health.as_deref() {
            Some("healthy") => style("●").green(),
            Some("unhealthy") => style("●").red(),
            Some("starting") => style("●").yellow(),
            _ => style("●").green(),
        }
    } else {
        style("○").dim()
    };

    // 资源使用
    let (cpu, mem) = stats
        .iter()
        .find(|s| s.name.contains(name))
        .map(|s| (format!("{:.1}%", s.cpu_percent), format!("{:.1}%", s.memory_percent)))
        .unwrap_or_else(|| ("-".to_string(), "-".to_string()));

    // 端口
    let ports = status.ports();
    let port_str = if ports.is_empty() {
        "-".to_string()
    } else {
        ports.iter().map(|p| p.to_string()).collect::<Vec<_>>().join(",")
    };

    println!(
        "    {} {:20} {:>6} {:>6}  {}",
        status_icon,
        name,
        style(cpu).dim(),
        style(mem).dim(),
        style(port_str).dim(),
    );
}

/// 打印快速访问链接
fn print_quick_links(statuses: &[ServiceStatus]) {
    let running: Vec<_> = statuses.iter().filter(|s| s.is_running()).collect();

    if running.is_empty() {
        return;
    }

    ui::separator();
    println!("  {} 快速访问", ui::style_dim("▸"));

    // 检查各服务是否运行
    let has_gateway = running.iter().any(|s| s.service_name() == "gateway");
    let has_chat = running.iter().any(|s| s.service_name() == "chat");
    let has_traefik = running.iter().any(|s| s.service_name() == "traefik");
    let has_rabbitmq = running.iter().any(|s| s.service_name() == "rabbitmq");
    let has_dozzle = running.iter().any(|s| s.service_name() == "dozzle");

    if has_gateway {
        ui::kv("    Gateway gRPC", "localhost:50051");
    }
    if has_chat {
        ui::kv("    Chat gRPC", "localhost:50060");
    }
    if has_traefik {
        ui::kv("    Traefik", "http://localhost:8088");
    }
    if has_rabbitmq {
        ui::kv("    RabbitMQ", "http://localhost:15672");
    }
    if has_dozzle {
        ui::kv("    Dozzle", "http://localhost:9999");
    }

    println!();
}
