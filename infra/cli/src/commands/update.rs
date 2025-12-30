use anyhow::Result;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 update 命令 - 更新环境 (重新生成 proto、重建服务、运行迁移)
pub async fn execute() -> Result<()> {
    ui::header("更新开发环境");

    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // Step 1: 重新生成 Proto 代码
    ui::step("重新生成 Proto 代码...");
    match crate::commands::proto::execute("all".to_string()).await {
        Ok(()) => {}
        Err(e) => {
            ui::warn(&format!("Proto 代码生成失败: {}", e));
            ui::info("继续执行其他更新步骤...");
        }
    }

    // Step 2: 重建服务
    ui::step("重建服务镜像...");
    let spinner = Spinner::new("正在重建 Docker 镜像...");
    let build_result = compose.build_with_progress(None, true).await;
    spinner.finish_and_clear();

    match build_result {
        Ok(()) => {
            ui::success("Docker 镜像重建完成");
        }
        Err(e) => {
            ui::error(&format!("Docker 镜像重建失败: {}", e));
            return Err(e);
        }
    }

    // Step 3: 重启服务
    ui::step("重启服务...");
    let spinner = Spinner::new("正在重启服务...");
    let restart_result = compose.restart(&[]).await;
    spinner.finish_and_clear();

    match restart_result {
        Ok(()) => {
            ui::success("服务重启完成");
        }
        Err(e) => {
            ui::warn(&format!("服务重启失败: {}", e));
            ui::info("尝试启动服务...");
            // 如果重启失败，尝试启动
            compose.up_wait(&[]).await?;
        }
    }

    // Step 4: 执行数据库迁移
    ui::step("执行数据库迁移...");

    // 等待服务启动
    tokio::time::sleep(tokio::time::Duration::from_secs(3)).await;

    // 检查 Django 服务是否运行
    let statuses = compose.ps_json().await?;
    let django_running = statuses
        .iter()
        .any(|s| s.service_name() == "django" && s.is_running());

    if !django_running {
        ui::warn("Django 服务未运行，正在启动...");
        compose.up_wait(&["django"]).await?;
        // 等待服务完全启动
        tokio::time::sleep(tokio::time::Duration::from_secs(5)).await;
    }

    // 执行迁移
    let migrate_result = compose
        .exec("django", &["python", "manage.py", "migrate"], false)
        .await;

    match migrate_result {
        Ok(()) => {
            ui::success("数据库迁移完成");
        }
        Err(e) => {
            ui::warn(&format!("数据库迁移失败: {}", e));
            ui::info("可以稍后运行 'devlesser migrate' 重新执行迁移");
        }
    }

    // 完成
    ui::success("🚀 环境更新完成！");
    println!();
    ui::info("运行 'devlesser status' 查看服务状态");
    ui::info("运行 'devlesser test' 测试服务连通性");

    Ok(())
}
