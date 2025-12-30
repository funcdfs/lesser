use anyhow::Result;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui;

/// 执行 logs 命令
pub async fn execute(service: Option<String>, lines: u32, follow: bool) -> Result<()> {
    let config = Config::load()?;
    
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    match &service {
        Some(svc) => {
            if follow {
                ui::info(&format!("📋 跟踪 {} 日志 (Ctrl+C 退出)...", svc));
            } else {
                ui::info(&format!("📋 显示 {} 最近 {} 行日志", svc, lines));
            }
        }
        None => {
            if follow {
                ui::info("📋 跟踪所有服务日志 (Ctrl+C 退出)...");
            } else {
                ui::info(&format!("📋 显示所有服务最近 {} 行日志", lines));
            }
        }
    }
    
    ui::separator();
    
    // 流式输出日志
    compose.logs(service.as_deref(), lines, follow).await?;
    
    Ok(())
}
