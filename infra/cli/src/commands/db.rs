use anyhow::Result;

use crate::cli::DbCommands;
use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 db 命令
pub async fn execute(command: DbCommands) -> Result<()> {
    match command {
        DbCommands::Shell => shell().await,
        DbCommands::Reset => reset().await,
    }
}

/// 进入 PostgreSQL shell (psql)
async fn shell() -> Result<()> {
    ui::header("进入数据库 Shell");

    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // 检查 postgres 服务是否运行
    let statuses = compose.ps_json().await?;
    let postgres_running = statuses
        .iter()
        .any(|s| s.service_name() == "postgres" && s.is_running());

    if !postgres_running {
        ui::warn("PostgreSQL 服务未运行，正在启动...");
        let spinner = Spinner::new("正在启动 PostgreSQL 服务...");
        compose.up_wait(&["postgres"]).await?;
        spinner.finish_and_clear();
        ui::success("PostgreSQL 服务已启动");
    }

    // 获取数据库连接信息
    let db_user = std::env::var("POSTGRES_USER").unwrap_or_else(|_| "lesser".to_string());
    let db_name = std::env::var("POSTGRES_DB").unwrap_or_else(|_| "lesser_db".to_string());

    ui::info(&format!("连接到数据库: {} (用户: {})", db_name, db_user));
    ui::info("输入 \\q 退出");
    ui::separator();

    // 进入 psql
    compose
        .exec(
            "postgres",
            &["psql", "-U", &db_user, "-d", &db_name],
            true,
        )
        .await?;

    Ok(())
}

/// 重置数据库
async fn reset() -> Result<()> {
    ui::header("重置数据库");

    ui::warn("⚠️  警告: 此操作将删除所有数据库数据!");
    ui::warn("这包括所有表和数据。");
    ui::separator();

    // 确认操作
    let confirmed = crate::ui::confirm("确定要重置数据库吗?", false)?;
    if !confirmed {
        ui::info("操作已取消");
        return Ok(());
    }

    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // 获取数据库连接信息
    let db_user = std::env::var("POSTGRES_USER").unwrap_or_else(|_| "lesser".to_string());
    let db_name = std::env::var("POSTGRES_DB").unwrap_or_else(|_| "lesser_db".to_string());

    // 步骤 1: 停止依赖服务
    ui::step("停止依赖服务...");
    let spinner = Spinner::new("正在停止服务...");
    compose.stop(&["gateway", "chat", "auth-worker", "post-worker", "feed-worker", "user-worker", "notification-worker", "search-worker", "chat-worker"]).await.ok(); // 忽略错误，服务可能未运行
    spinner.finish_and_clear();
    ui::success("依赖服务已停止");

    // 步骤 2: 确保 postgres 运行
    let statuses = compose.ps_json().await?;
    let postgres_running = statuses
        .iter()
        .any(|s| s.service_name() == "postgres" && s.is_running());

    if !postgres_running {
        ui::step("启动 PostgreSQL 服务...");
        let spinner = Spinner::new("正在启动 PostgreSQL...");
        compose.up_wait(&["postgres"]).await?;
        spinner.finish_and_clear();
        ui::success("PostgreSQL 服务已启动");
    }

    // 步骤 3: 删除并重建数据库
    ui::step("删除并重建数据库...");
    let spinner = Spinner::new("正在重置数据库...");

    // 断开所有连接并删除数据库
    // 注意：这里使用参数化方式构建 SQL，db_name 来自环境变量，应该是可信的
    // 但为了安全起见，验证数据库名称只包含合法字符
    if !db_name.chars().all(|c| c.is_alphanumeric() || c == '_') {
        anyhow::bail!("数据库名称包含非法字符: {}", db_name);
    }
    
    let drop_connections_sql = format!(
        "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '{}' AND pid <> pg_backend_pid();",
        db_name
    );
    compose
        .exec(
            "postgres",
            &["psql", "-U", &db_user, "-d", "postgres", "-c", &drop_connections_sql],
            false,
        )
        .await
        .ok(); // 忽略错误

    // 删除数据库
    let drop_db_sql = format!("DROP DATABASE IF EXISTS \"{}\";", db_name);
    compose
        .exec(
            "postgres",
            &["psql", "-U", &db_user, "-d", "postgres", "-c", &drop_db_sql],
            false,
        )
        .await?;

    // 创建数据库
    let create_db_sql = format!("CREATE DATABASE \"{}\";", db_name);
    compose
        .exec(
            "postgres",
            &["psql", "-U", &db_user, "-d", "postgres", "-c", &create_db_sql],
            false,
        )
        .await?;

    spinner.finish_and_clear();
    ui::success("数据库已重建");

    // 步骤 4: 重启服务
    ui::step("重启服务...");
    let spinner = Spinner::new("正在启动服务...");
    compose.up_wait(&[]).await?;
    spinner.finish_and_clear();
    ui::success("服务已启动");

    ui::separator();
    ui::success("🗄 数据库重置完成!");

    Ok(())
}
