use anyhow::Result;

use crate::cli::CleanCommands;
use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 clean 命令
pub async fn execute(command: Option<CleanCommands>, force: bool) -> Result<()> {
    let config = Config::load()?;

    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    match command {
        Some(CleanCommands::Containers) => clean_containers(&compose).await,
        Some(CleanCommands::Volumes) => clean_volumes(&compose, force).await,
        Some(CleanCommands::Chat) => clean_chat_data(&compose).await,
        Some(CleanCommands::Users) => clean_user_data(&compose).await,
        None => clean_all(&compose, force).await,
    }
}

/// 清理所有
async fn clean_all(compose: &DockerCompose, force: bool) -> Result<()> {
    ui::banner("清理开发环境");

    println!("  将删除:");
    println!("    • 所有容器");
    println!("    • 所有数据卷 (包括数据库)");
    println!("    • 所有网络");
    println!();

    if !force {
        let confirmed = ui::confirm("确定要清理所有内容吗?", false)?;
        if !confirmed {
            ui::info("已取消");
            return Ok(());
        }
    }

    let spinner = Spinner::new("清理中...");
    compose.down(true, true).await?;
    spinner.finish_and_clear();

    ui::success("🧹 清理完成");
    ui::hint("运行 'devlesser init' 重新初始化环境");
    Ok(())
}

/// 仅清理容器
async fn clean_containers(compose: &DockerCompose) -> Result<()> {
    ui::banner("清理容器");

    let spinner = Spinner::new("停止并删除容器...");
    compose.down(false, true).await?;
    spinner.finish_and_clear();

    ui::success("🧹 容器已清理 (数据已保留)");
    ui::hint("运行 'devlesser start' 重新启动");
    Ok(())
}

/// 清理数据卷
async fn clean_volumes(compose: &DockerCompose, force: bool) -> Result<()> {
    ui::banner("清理数据卷");

    println!("  将删除:");
    println!("    • PostgreSQL 数据");
    println!("    • Redis 缓存");
    println!("    • RabbitMQ 数据");
    println!();

    if !force {
        let confirmed = ui::confirm("确定要删除所有数据吗?", false)?;
        if !confirmed {
            ui::info("已取消");
            return Ok(());
        }
    }

    let spinner = Spinner::new("删除数据卷...");
    compose.down(true, false).await?;
    spinner.finish_and_clear();

    ui::success("🧹 数据卷已清理");
    Ok(())
}

/// 清理聊天数据
async fn clean_chat_data(compose: &DockerCompose) -> Result<()> {
    ui::banner("清理聊天数据");

    let spinner = Spinner::new("清空聊天表...");

    let sql = "TRUNCATE TABLE messages, conversation_members, conversations CASCADE;";
    let result = compose
        .exec(
            "postgres",
            &["psql", "-U", "lesser", "-d", "lesser_chat_db", "-c", sql],
            false,
        )
        .await;

    spinner.finish_and_clear();

    match result {
        Ok(_) => ui::success("🧹 聊天数据已清空"),
        Err(_) => ui::warn("清空失败，可能表不存在或服务未运行"),
    }

    Ok(())
}

/// 清理用户数据
async fn clean_user_data(compose: &DockerCompose) -> Result<()> {
    ui::banner("清理用户数据");

    let spinner = Spinner::new("清空用户表...");

    let sql = "TRUNCATE TABLE users, follows CASCADE;";
    let result = compose
        .exec(
            "postgres",
            &["psql", "-U", "lesser", "-d", "lesser_db", "-c", sql],
            false,
        )
        .await;

    spinner.finish_and_clear();

    match result {
        Ok(_) => ui::success("🧹 用户数据已清空"),
        Err(_) => ui::warn("清空失败，可能表不存在或服务未运行"),
    }

    Ok(())
}
