use anyhow::{bail, Result};

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 shell 命令 - 进入 Django Python shell
pub async fn execute() -> Result<()> {
    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // 检查 Django 服务是否运行
    let statuses = compose.ps_json().await?;
    let django_running = statuses
        .iter()
        .any(|s| s.service_name() == "django" && s.is_running());

    if !django_running {
        ui::warn("Django 服务未运行，正在启动...");
        let spinner = Spinner::new("正在启动 Django 服务...");
        compose.up_wait(&["django"]).await?;
        spinner.finish_and_clear();
        ui::success("Django 服务已启动");

        // 等待服务完全启动
        tokio::time::sleep(tokio::time::Duration::from_secs(3)).await;
    }

    // 进入 Django Python shell
    ui::step("进入 Django Python shell...");
    ui::info("使用 exit() 或 Ctrl+D 退出");

    let result = compose
        .exec("django", &["python", "manage.py", "shell"], true)
        .await;

    match result {
        Ok(()) => Ok(()),
        Err(e) => {
            ui::error(&format!("进入 Django shell 失败: {}", e));
            bail!("进入 Django shell 失败");
        }
    }
}
