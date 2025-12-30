use anyhow::Result;
use console::style;

use crate::config::Config;
use crate::docker::{ContainerStats, DockerCompose, ServiceStatus};
use crate::ui::{self, Spinner};

/// 执行 status 命令
pub async fn execute() -> Result<()> {
    let config = Config::load()?;
    
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    ui::header("服务状态");
    
    let spinner = Spinner::new("正在获取服务状态...");
    
    // 获取服务状态
    let statuses = compose.ps_json().await?;
    
    // 获取资源使用情况
    let stats = compose.stats().await.unwrap_or_default();
    
    spinner.finish_and_clear();
    
    if statuses.is_empty() {
        ui::info("没有运行中的服务");
        ui::info("使用 'devlesser start' 启动服务");
        return Ok(());
    }
    
    // 打印状态表格
    print_status_table(&statuses, &stats);
    
    // 打印访问地址
    ui::separator();
    print_service_urls(&statuses);
    
    Ok(())
}

/// 打印服务状态表格
fn print_status_table(statuses: &[ServiceStatus], stats: &[ContainerStats]) {
    // 表头
    println!(
        "{:15} {:12} {:12} {:10} {:10} {:20}",
        style("服务").bold().cyan(),
        style("状态").bold().cyan(),
        style("健康").bold().cyan(),
        style("CPU").bold().cyan(),
        style("内存").bold().cyan(),
        style("端口").bold().cyan(),
    );
    
    println!("{}", style("─".repeat(80)).dim());
    
    // 按服务名排序
    let mut sorted_statuses = statuses.to_vec();
    sorted_statuses.sort_by(|a, b| a.service_name().cmp(b.service_name()));
    
    for status in &sorted_statuses {
        let service_name = status.service_name();
        
        // 状态显示
        let state_display = if status.is_running() {
            style("运行中").green().to_string()
        } else {
            style(&status.state).red().to_string()
        };
        
        // 健康状态显示
        let health_display = match status.health.as_deref() {
            Some("healthy") => style("健康").green().to_string(),
            Some("unhealthy") => style("不健康").red().to_string(),
            Some("starting") => style("启动中").yellow().to_string(),
            Some(h) => style(h).yellow().to_string(),
            None => style("-").dim().to_string(),
        };
        
        // 查找资源使用情况
        let (cpu, mem) = stats
            .iter()
            .find(|s| s.name.contains(service_name))
            .map(|s| {
                (
                    format!("{:.1}%", s.cpu_percent),
                    format!("{:.1}%", s.memory_percent),
                )
            })
            .unwrap_or_else(|| ("-".to_string(), "-".to_string()));
        
        // 端口显示
        let ports = status.ports();
        let ports_display = if ports.is_empty() {
            "-".to_string()
        } else {
            ports
                .iter()
                .map(|p| p.to_string())
                .collect::<Vec<_>>()
                .join(", ")
        };
        
        println!(
            "{:15} {:12} {:12} {:10} {:10} {:20}",
            service_name,
            state_display,
            health_display,
            cpu,
            mem,
            ports_display,
        );
    }
}

/// 打印服务访问地址
fn print_service_urls(statuses: &[ServiceStatus]) {
    let running_services: Vec<_> = statuses.iter().filter(|s| s.is_running()).collect();
    
    if running_services.is_empty() {
        return;
    }
    
    ui::info("服务访问地址:");
    
    for status in &running_services {
        let service_name = status.service_name();
        let ports = status.ports();
        
        match service_name {
            "django" => {
                if ports.contains(&8000) {
                    ui::url("Django API", "http://localhost:8000");
                    ui::url("Django Admin", "http://localhost:8000/admin");
                }
            }
            "chat" => {
                if ports.contains(&8081) {
                    ui::url("Chat HTTP", "http://localhost:8081");
                    ui::url("Chat Health", "http://localhost:8081/health");
                }
            }
            "traefik" => {
                if ports.contains(&8088) {
                    ui::url("Traefik Dashboard", "http://localhost:8088");
                }
            }
            "postgres" => {
                if ports.contains(&5432) {
                    ui::url("PostgreSQL", "localhost:5432");
                }
            }
            "redis" => {
                if ports.contains(&6379) {
                    ui::url("Redis", "localhost:6379");
                }
            }
            _ => {
                // 其他服务显示端口
                for port in &ports {
                    ui::url(service_name, &format!("localhost:{}", port));
                }
            }
        }
    }
}
