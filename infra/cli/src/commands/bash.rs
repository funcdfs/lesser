use anyhow::{bail, Result};

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 bash 命令 - 进入容器 sh shell
pub async fn execute(service: String) -> Result<()> {
    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // 规范化服务名称
    let container_name = normalize_service_name(&service);

    // 检查服务是否运行
    let statuses = compose.ps_json().await?;
    let service_running = statuses
        .iter()
        .any(|s| s.service_name() == container_name && s.is_running());

    if !service_running {
        // 如果是 gateway，尝试启动
        if container_name == "gateway" {
            ui::warn("Gateway 服务未运行，正在启动...");
            let spinner = Spinner::new("正在启动 Gateway 服务...");
            compose.up_wait(&["gateway"]).await?;
            spinner.finish_and_clear();
            ui::success("Gateway 服务已启动");

            // 等待服务完全启动
            tokio::time::sleep(tokio::time::Duration::from_secs(3)).await;
        } else {
            ui::error(&format!("服务 {} 未运行", container_name));
            ui::info("运行 'devlesser start' 启动服务");
            bail!("服务未运行");
        }
    }

    // 进入容器 sh
    ui::step(&format!("进入 {} 容器 (sh)...", container_name));
    ui::info("使用 exit 或 Ctrl+D 退出");

    let result = compose.exec(&container_name, &["sh"], true).await;

    match result {
        Ok(()) => Ok(()),
        Err(e) => {
            ui::error(&format!("进入容器失败: {}", e));
            bail!("进入容器失败");
        }
    }
}

/// 规范化服务名称
fn normalize_service_name(service: &str) -> String {
    match service.to_lowercase().as_str() {
        "go" => "chat".to_string(),
        "db" | "database" | "postgresql" => "postgres".to_string(),
        "cache" => "redis".to_string(),
        "mq" | "rabbitmq" | "rabbit" => "rabbitmq".to_string(),
        other => other.to_string(),
    }
}
