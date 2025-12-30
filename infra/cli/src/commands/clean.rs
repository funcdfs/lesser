use anyhow::Result;

use crate::cli::CleanCommands;
use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 clean 命令
///
/// # Arguments
/// * `command` - 可选的子命令: containers, volumes
/// * `force` - 是否跳过确认提示
pub async fn execute(command: Option<CleanCommands>, force: bool) -> Result<()> {
    let config = Config::load()?;

    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    match command {
        Some(CleanCommands::Containers) => clean_containers(&compose).await,
        Some(CleanCommands::Volumes) => clean_volumes(&compose, force).await,
        None => clean_all(&compose, force).await,
    }
}

/// 清理所有容器、卷和孤立容器
async fn clean_all(compose: &DockerCompose, force: bool) -> Result<()> {
    ui::header("清理开发环境");

    ui::warn("此操作将删除:");
    println!("  • 所有容器");
    println!("  • 所有数据卷 (包括数据库数据)");
    println!("  • 所有孤立容器");
    println!();

    // 确认操作
    if !force {
        let confirmed = crate::ui::confirm("确定要清理所有内容吗?", false)?;
        if !confirmed {
            ui::info("操作已取消");
            return Ok(());
        }
    }

    let spinner = Spinner::new("正在清理...");

    // 停止并删除所有容器、卷和孤立容器
    let result = compose.down(true, true).await;

    spinner.finish_and_clear();

    match result {
        Ok(()) => {
            ui::success("🧹 清理完成");
            ui::info("提示: 运行 'devlesser init' 重新初始化开发环境");
            Ok(())
        }
        Err(e) => {
            ui::error(&format!("清理失败: {}", e));
            Err(e)
        }
    }
}

/// 仅清理容器（不需要确认）
async fn clean_containers(compose: &DockerCompose) -> Result<()> {
    ui::header("清理容器");

    let spinner = Spinner::new("正在停止并删除容器...");

    // 停止并删除容器，但保留卷
    let result = compose.down(false, true).await;

    spinner.finish_and_clear();

    match result {
        Ok(()) => {
            ui::success("🧹 容器已清理");
            ui::info("提示: 数据卷已保留，运行 'devlesser start' 重新启动服务");
            Ok(())
        }
        Err(e) => {
            ui::error(&format!("清理容器失败: {}", e));
            Err(e)
        }
    }
}

/// 清理数据卷（需要确认）
async fn clean_volumes(compose: &DockerCompose, force: bool) -> Result<()> {
    ui::header("清理数据卷");

    ui::warn("此操作将删除所有数据卷，包括:");
    println!("  • PostgreSQL 数据库数据");
    println!("  • Redis 缓存数据");
    println!("  • 其他持久化数据");
    println!();

    // 确认操作
    if !force {
        let confirmed = crate::ui::confirm("确定要删除所有数据卷吗?", false)?;
        if !confirmed {
            ui::info("操作已取消");
            return Ok(());
        }
    }

    let spinner = Spinner::new("正在删除数据卷...");

    // 停止容器并删除卷
    let result = compose.down(true, false).await;

    spinner.finish_and_clear();

    match result {
        Ok(()) => {
            ui::success("🧹 数据卷已清理");
            ui::info("提示: 运行 'devlesser start' 重新启动服务，数据库将重新初始化");
            Ok(())
        }
        Err(e) => {
            ui::error(&format!("清理数据卷失败: {}", e));
            Err(e)
        }
    }
}
