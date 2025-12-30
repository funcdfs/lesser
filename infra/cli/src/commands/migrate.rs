use anyhow::Result;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 Django 数据库迁移
pub async fn execute() -> Result<()> {
    ui::header("执行数据库迁移");

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
    }

    // 执行迁移
    let spinner = Spinner::new("正在执行数据库迁移...");
    spinner.finish_and_clear();

    ui::step("执行 python manage.py migrate");
    compose
        .exec("django", &["python", "manage.py", "migrate"], false)
        .await?;

    ui::success("🗄 数据库迁移完成");
    Ok(())
}

/// 生成 Django 迁移文件
pub async fn makemigrations(app: Option<String>) -> Result<()> {
    ui::header("生成迁移文件");

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
    }

    // 构建命令
    let mut cmd = vec!["python", "manage.py", "makemigrations"];
    if let Some(ref app_name) = app {
        cmd.push(app_name);
    }

    ui::step(&format!(
        "执行 {}",
        cmd.join(" ")
    ));

    compose.exec("django", &cmd, false).await?;

    ui::success("📝 迁移文件生成完成");
    Ok(())
}

/// 创建 Django 超级用户
pub async fn createsuperuser() -> Result<()> {
    ui::header("创建超级用户");

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
    }

    ui::step("执行 python manage.py createsuperuser");
    ui::info("请按提示输入超级用户信息:");

    // 交互式创建超级用户
    compose
        .exec("django", &["python", "manage.py", "createsuperuser"], true)
        .await?;

    ui::success("👤 超级用户创建完成");
    Ok(())
}
