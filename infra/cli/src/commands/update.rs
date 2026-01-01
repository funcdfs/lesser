use anyhow::Result;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 update 命令 - 更新环境 (重新生成 proto、重建服务)
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

    // 完成
    ui::success("🚀 环境更新完成！");
    println!();
    ui::info("运行 'devlesser status' 查看服务状态");
    ui::info("运行 'devlesser test' 测试服务连通性");

    Ok(())
}
