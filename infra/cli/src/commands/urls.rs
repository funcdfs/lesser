use anyhow::Result;

use crate::config::{get_env_or_default, Config};
use crate::ui;

/// 执行 urls 命令 - 显示服务访问地址
pub async fn execute() -> Result<()> {
    let config = Config::load()?;

    ui::header("服务访问地址");

    // 后端服务
    println!("后端服务:");
    ui::separator();
    ui::url("Gateway (统一入口)", "http://localhost");
    ui::url("Django API", "http://localhost:8000");
    ui::url("Chat API", "http://localhost:8081");
    ui::url("Traefik Dashboard", "http://localhost:8088");

    // Dozzle 日志查看器
    let dozzle_port = get_env_or_default("DOZZLE_PORT", "9999");
    ui::url("Dozzle (日志)", &format!("http://localhost:{}", dozzle_port));

    println!();

    // 客户端
    println!("客户端:");
    ui::separator();
    ui::url(
        "Flutter Web",
        &format!("http://localhost:{}", config.flutter_port),
    );
    ui::url(
        "React Web",
        &format!("http://localhost:{}", config.react_port),
    );

    println!();

    // API 测试端点
    println!("API 测试端点:");
    ui::separator();
    println!("  curl http://localhost/api/v1/hello/");
    println!("  curl http://localhost/api/v1/chat/hello");
    println!("  curl http://localhost/api/v1/health/");

    println!();

    // gRPC 端点
    println!("gRPC 端点:");
    ui::separator();
    ui::url("Django gRPC", "localhost:50051");
    ui::url("Chat gRPC", "localhost:50052");

    println!();

    Ok(())
}
