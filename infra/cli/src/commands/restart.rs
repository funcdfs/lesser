use anyhow::Result;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 restart 命令
pub async fn execute(service: Option<String>) -> Result<()> {
    let config = Config::load()?;

    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    match service.as_deref() {
        None | Some("all") => restart_all(&compose).await,
        Some(svc) => restart_service(&compose, svc).await,
    }
}

/// 重启所有服务
async fn restart_all(compose: &DockerCompose) -> Result<()> {
    ui::banner("重启所有服务");

    let spinner = Spinner::new("重启中...");
    compose.restart(&[]).await?;
    spinner.finish_and_clear();

    ui::success("🔄 所有服务已重启");
    ui::hint("运行 'devlesser status' 查看服务状态");
    Ok(())
}

/// 重启指定服务
async fn restart_service(compose: &DockerCompose, service: &str) -> Result<()> {
    let spinner = Spinner::new(&format!("重启 {}...", service));
    compose.restart(&[service]).await?;
    spinner.finish_and_clear();

    ui::success(&format!("🔄 {} 已重启", service));
    Ok(())
}
