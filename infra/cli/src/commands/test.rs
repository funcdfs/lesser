use anyhow::Result;
use console::style;

use crate::docker::health::{HealthCheckResult, HealthChecker, HealthStatus, ServiceEndpoints};
use crate::ui::{self, Spinner};

/// 执行 test 命令
pub async fn execute() -> Result<()> {
    ui::header("测试服务连通性");
    
    let spinner = Spinner::new("正在测试服务健康状态...");
    
    let checker = HealthChecker::default();
    let endpoints = ServiceEndpoints::all();
    
    // 并发检查所有服务
    let results = checker.check_all_concurrent(&endpoints).await;
    
    spinner.finish_and_clear();
    
    // 打印结果表格
    print_health_results(&results);
    
    // 统计结果
    let healthy_count = results.iter().filter(|r| r.is_healthy()).count();
    let total_count = results.len();
    
    ui::separator();
    
    if healthy_count == total_count {
        ui::success(&format!("✅ 所有服务健康 ({}/{})", healthy_count, total_count));
        Ok(())
    } else {
        ui::warn(&format!(
            "⚠️  部分服务不健康 ({}/{})",
            healthy_count, total_count
        ));
        ui::info("使用 'devlesser logs <service>' 查看服务日志");
        Ok(())
    }
}

/// 打印健康检查结果
fn print_health_results(results: &[HealthCheckResult]) {
    // 表头
    println!(
        "{:15} {:30} {:12} {:15}",
        style("服务").bold().cyan(),
        style("端点").bold().cyan(),
        style("状态").bold().cyan(),
        style("响应时间").bold().cyan(),
    );
    
    println!("{}", style("─".repeat(75)).dim());
    
    for result in results {
        let status_display = match &result.status {
            HealthStatus::Healthy => style("✅ 健康").green().to_string(),
            HealthStatus::Unhealthy(msg) => style(format!("❌ {}", msg)).red().to_string(),
            HealthStatus::Unreachable => style("❌ 不可达").red().to_string(),
            HealthStatus::Timeout => style("⏱️  超时").yellow().to_string(),
        };
        
        let response_time = result
            .response_time_ms
            .map(|ms| format!("{}ms", ms))
            .unwrap_or_else(|| "-".to_string());
        
        println!(
            "{:15} {:30} {:12} {:15}",
            result.service,
            result.url,
            status_display,
            response_time,
        );
    }
}
