use std::path::Path;
use std::process::Stdio;

use anyhow::{bail, Result};
use tokio::process::Command;

use crate::config::paths;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 init 命令 - 初始化开发环境
pub async fn execute() -> Result<()> {
    ui::header("初始化开发环境");

    // Step 1: 检查依赖
    ui::step("检查依赖...");
    check_dependencies().await?;
    ui::success("依赖检查通过");

    // Step 2: 配置环境变量
    ui::step("配置环境变量...");
    setup_env_file().await?;

    // Step 3: 生成 Proto 代码
    ui::step("生成 Proto 代码...");
    generate_proto().await?;

    // Step 4: 构建 Docker 镜像
    ui::step("构建 Docker 镜像...");
    build_images().await?;

    // 完成
    ui::success("⚙ 初始化完成！");
    println!();
    print_next_steps();

    Ok(())
}

/// 检查必要依赖
async fn check_dependencies() -> Result<()> {
    // 检查 Docker
    if !DockerCompose::check_docker_available().await.unwrap_or(false) {
        ui::error("Docker 未安装或未运行");
        ui::info("请安装 Docker Desktop: https://docs.docker.com/get-docker/");
        bail!("Docker 未安装或未运行");
    }

    // 检查 Docker Compose
    if !DockerCompose::check_compose_available().await.unwrap_or(false) {
        ui::error("Docker Compose 未安装");
        ui::info("Docker Compose 通常随 Docker Desktop 一起安装");
        bail!("Docker Compose 未安装");
    }

    // 检查 Go (可选，用于本地开发)
    let go_check = Command::new("go")
        .args(["version"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    if !go_check.map(|s| s.success()).unwrap_or(false) {
        ui::warn("Go 未安装 (可选，用于本地开发)");
    }

    Ok(())
}

/// 设置环境变量文件
async fn setup_env_file() -> Result<()> {
    let project_root = paths::find_project_root()?;
    let env_dir = project_root.join("infra/env");
    let env_file = project_root.join("infra/env/dev.env");
    let env_example = project_root.join("infra/env/dev.env.example");
    let legacy_env = project_root.join("infra/.env.dev");
    let legacy_example = project_root.join("infra/.env.dev.example");

    // 确保 env 目录存在
    if !env_dir.exists() {
        tokio::fs::create_dir_all(&env_dir).await?;
        ui::info(&format!("创建目录: {}", env_dir.display()));
    }

    // 如果环境变量文件已存在
    if env_file.exists() {
        ui::info("环境变量文件已存在");
        return Ok(());
    }

    // 尝试从模板创建
    if env_example.exists() {
        tokio::fs::copy(&env_example, &env_file).await?;
        ui::info(&format!("已创建 {}", env_file.display()));
        return Ok(());
    }

    // 尝试从旧位置的模板创建
    if legacy_example.exists() {
        tokio::fs::copy(&legacy_example, &env_file).await?;
        ui::info(&format!("已从旧模板创建 {}", env_file.display()));
        return Ok(());
    }

    // 尝试迁移旧的环境变量文件
    if legacy_env.exists() {
        tokio::fs::copy(&legacy_env, &env_file).await?;
        ui::info(&format!("已迁移旧的 .env.dev 到 {}", env_file.display()));
        return Ok(());
    }

    // 创建默认环境变量文件
    create_default_env_file(&env_file).await?;
    ui::info(&format!("已创建默认环境变量文件: {}", env_file.display()));
    ui::warn("请检查并修改环境变量配置");

    Ok(())
}

/// 创建默认环境变量文件
async fn create_default_env_file(path: &Path) -> Result<()> {
    let default_content = r#"# 开发环境配置
# Development Environment Configuration

# PostgreSQL
POSTGRES_USER=lesser
POSTGRES_PASSWORD=lesser_dev_password
POSTGRES_DB=lesser_db
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Redis
REDIS_URL=redis://redis:6379/0

# RabbitMQ
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest

# Gateway Service
GATEWAY_GRPC_PORT=50053

# Chat Service
CHAT_GRPC_PORT=50052
CHAT_HTTP_PORT=8080

# JWT
JWT_SECRET_KEY=jwt-secret-key-change-in-production
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# External Services (optional)
# EXTERNAL_API_KEY=your-api-key

# Client Ports
FLUTTER_WEB_PORT=3000
REACT_PORT=3001

# Dozzle (Log Viewer)
DOZZLE_PORT=9999
"#;

    tokio::fs::write(path, default_content).await?;
    Ok(())
}

/// 生成 Proto 代码
async fn generate_proto() -> Result<()> {
    let proto_script = paths::get_proto_script()?;

    if !proto_script.exists() {
        ui::warn("Proto 生成脚本不存在，跳过");
        return Ok(());
    }

    let project_root = paths::find_project_root()?;
    let spinner = Spinner::new("正在生成 Proto 代码...");

    let status = Command::new("bash")
        .arg(&proto_script)
        .arg("all")
        .current_dir(&project_root)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    spinner.finish_and_clear();

    match status {
        Ok(s) if s.success() => {
            ui::success("Proto 代码生成完成");
            Ok(())
        }
        Ok(s) => {
            let code = s.code().unwrap_or(1);
            ui::warn(&format!("Proto 代码生成失败 (退出码: {})", code));
            ui::info("可以稍后运行 'devlesser proto' 重新生成");
            Ok(())
        }
        Err(e) => {
            ui::warn(&format!("Proto 代码生成失败: {}", e));
            ui::info("可以稍后运行 'devlesser proto' 重新生成");
            Ok(())
        }
    }
}

/// 构建 Docker 镜像
async fn build_images() -> Result<()> {
    let compose_file = paths::get_compose_file()?;
    let env_file = paths::get_env_file()?;

    if !compose_file.exists() {
        ui::warn("Docker Compose 文件不存在，跳过构建");
        return Ok(());
    }

    let compose = DockerCompose::new(
        compose_file.to_str().unwrap_or(""),
        env_file.to_str().unwrap_or(""),
    );

    let spinner = Spinner::new("正在构建 Docker 镜像 (这可能需要几分钟)...");

    let result = compose.build(None, false).await;

    spinner.finish_and_clear();

    match result {
        Ok(()) => {
            ui::success("Docker 镜像构建完成");
            Ok(())
        }
        Err(e) => {
            ui::error(&format!("Docker 镜像构建失败: {}", e));
            ui::info("可以稍后运行 'devlesser build' 重新构建");
            Err(e)
        }
    }
}

/// 打印下一步操作
fn print_next_steps() {
    println!("下一步:");
    ui::separator();
    println!("  1. 运行 devlesser start 启动所有服务");
    println!("  2. 运行 devlesser migrate 执行数据库迁移");
    println!("  3. 运行 devlesser test 测试服务连通性");
    println!();
}
