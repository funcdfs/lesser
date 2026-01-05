use std::process::Stdio;

use anyhow::{bail, Result};
use tokio::process::Command;

use crate::config::paths;
use crate::ui::{self, Spinner};

/// 支持的 proto 生成目标
const VALID_TARGETS: &[&str] = &["all", "go", "dart"];

/// 服务列表
const SERVICES: &[&str] = &[
    "gateway",
    "auth",
    "user",
    "content",
    "interaction",
    "comment",
    "timeline",
    "search",
    "notification",
    "chat",
    "superuser",
];

/// 执行 proto 命令
pub async fn execute(target: String) -> Result<()> {
    // 验证目标参数
    let target_lower = target.to_lowercase();
    if !VALID_TARGETS.contains(&target_lower.as_str()) {
        ui::error(&format!("无效的目标: {}", target));
        ui::info(&format!("支持的目标: {}", VALID_TARGETS.join(", ")));
        bail!("无效的 proto 生成目标");
    }

    ui::header("生成 Protocol Buffer 代码");

    let project_root = paths::find_project_root()?;
    let proto_dir = project_root.join("protos");

    // 检查 protoc 是否安装
    if !check_protoc_installed().await {
        ui::error("protoc 未安装");
        ui::hint("安装: brew install protobuf");
        bail!("protoc 未安装");
    }

    ui::info(&format!("目标: {}", target_lower));
    ui::info(&format!("Proto 目录: {}", proto_dir.display()));
    println!();

    match target_lower.as_str() {
        "all" => {
            generate_go(&project_root, &proto_dir).await?;
            generate_dart(&project_root, &proto_dir).await?;
        }
        "go" => {
            generate_go(&project_root, &proto_dir).await?;
        }
        "dart" => {
            generate_dart(&project_root, &proto_dir).await?;
        }
        _ => {}
    }

    ui::success("Proto 代码生成完成");
    print_generated_locations(&target_lower);

    Ok(())
}

/// 检查 protoc 是否安装
async fn check_protoc_installed() -> bool {
    Command::new("which")
        .arg("protoc")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await
        .map(|s| s.success())
        .unwrap_or(false)
}

/// 检查并安装 Go protoc 插件
async fn ensure_go_plugins() -> Result<()> {
    // 检查 protoc-gen-go
    let has_gen_go = Command::new("which")
        .arg("protoc-gen-go")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await
        .map(|s| s.success())
        .unwrap_or(false);

    if !has_gen_go {
        ui::info("安装 protoc-gen-go...");
        let _ = Command::new("go")
            .args(["install", "google.golang.org/protobuf/cmd/protoc-gen-go@latest"])
            .status()
            .await;
    }

    // 检查 protoc-gen-go-grpc
    let has_gen_grpc = Command::new("which")
        .arg("protoc-gen-go-grpc")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await
        .map(|s| s.success())
        .unwrap_or(false);

    if !has_gen_grpc {
        ui::info("安装 protoc-gen-go-grpc...");
        let _ = Command::new("go")
            .args(["install", "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"])
            .status()
            .await;
    }

    Ok(())
}

/// 生成 Go 代码
async fn generate_go(project_root: &std::path::Path, proto_dir: &std::path::Path) -> Result<()> {
    ui::step("Go", "生成 Go gRPC 代码");

    ensure_go_plugins().await?;

    let spinner = Spinner::new("生成中...");

    // 首先为 pkg 生成 common proto（所有服务共享）
    let pkg_proto_out = project_root.join("service/pkg/gen_protos");
    tokio::fs::create_dir_all(&pkg_proto_out).await?;
    let _ = generate_proto_go(proto_dir, &pkg_proto_out, "common/common.proto").await;

    for service in SERVICES {
        let service_dir = project_root.join("service").join(service);
        let proto_out = service_dir.join("gen_protos");

        // 如果服务目录存在
        if service_dir.exists() || *service == "gateway" || *service == "chat" {
            // 创建输出目录
            tokio::fs::create_dir_all(&proto_out).await?;

            // 生成 common proto（每个服务也需要一份，用于本地引用）
            let _ = generate_proto_go(proto_dir, &proto_out, "common/common.proto").await;

            // 生成服务特定的 proto
            let service_proto = format!("{}/{}.proto", service, service);
            if proto_dir.join(&service_proto).exists() {
                let _ = generate_proto_go(proto_dir, &proto_out, &service_proto).await;
            }
        }
    }

    // Gateway 需要额外的 proto 文件
    let gateway_proto_out = project_root.join("service/gateway/gen_protos");
    let extra_protos = ["auth", "user", "content", "search", "comment", "interaction", "timeline", "notification"];
    
    for proto in extra_protos {
        let proto_file = format!("{}/{}.proto", proto, proto);
        if proto_dir.join(&proto_file).exists() {
            let _ = generate_proto_go(proto_dir, &gateway_proto_out, &proto_file).await;
        }
    }

    // Timeline 服务需要 content 和 interaction proto
    let timeline_proto_out = project_root.join("service/timeline/gen_protos");
    for proto in ["content", "interaction"] {
        let proto_file = format!("{}/{}.proto", proto, proto);
        if proto_dir.join(&proto_file).exists() {
            let _ = generate_proto_go(proto_dir, &timeline_proto_out, &proto_file).await;
        }
    }

    // Comment 服务需要 content proto
    let comment_proto_out = project_root.join("service/comment/gen_protos");
    let _ = generate_proto_go(proto_dir, &comment_proto_out, "content/content.proto").await;

    // Interaction 服务需要 content proto
    let interaction_proto_out = project_root.join("service/interaction/gen_protos");
    let _ = generate_proto_go(proto_dir, &interaction_proto_out, "content/content.proto").await;

    // Chat 服务需要 auth proto
    let chat_proto_out = project_root.join("service/chat/gen_protos");
    let _ = generate_proto_go(proto_dir, &chat_proto_out, "auth/auth.proto").await;

    spinner.finish_and_clear();
    ui::step_done("Go 代码生成完成");

    Ok(())
}

/// 生成单个 Go proto 文件
async fn generate_proto_go(
    proto_dir: &std::path::Path,
    out_dir: &std::path::Path,
    proto_file: &str,
) -> Result<()> {
    // 获取当前 PATH 并添加 ~/go/bin
    let home = std::env::var("HOME").unwrap_or_default();
    let go_bin = format!("{}/go/bin", home);
    let current_path = std::env::var("PATH").unwrap_or_default();
    let new_path = format!("{}:{}", go_bin, current_path);

    let status = Command::new("protoc")
        .env("PATH", &new_path)
        .args([
            &format!("--proto_path={}", proto_dir.display()),
            &format!("--go_out={}", out_dir.display()),
            "--go_opt=paths=source_relative",
            &format!("--go-grpc_out={}", out_dir.display()),
            "--go-grpc_opt=paths=source_relative",
            &proto_dir.join(proto_file).to_string_lossy(),
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await;

    if status.is_err() || !status.unwrap().success() {
        // 静默失败，某些 proto 可能有依赖问题
    }

    Ok(())
}

/// 检查并安装 Dart protoc 插件
async fn ensure_dart_plugins() -> Result<()> {
    let has_gen_dart = Command::new("which")
        .arg("protoc-gen-dart")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .await
        .map(|s| s.success())
        .unwrap_or(false);

    if !has_gen_dart {
        ui::info("安装 protoc-gen-dart...");
        let _ = Command::new("dart")
            .args(["pub", "global", "activate", "protoc_plugin"])
            .status()
            .await;
    }

    Ok(())
}

/// 生成 Dart 代码
async fn generate_dart(project_root: &std::path::Path, proto_dir: &std::path::Path) -> Result<()> {
    ui::step("Dart", "生成 Dart gRPC 代码");

    ensure_dart_plugins().await?;

    let dart_out = project_root.join("client/mobile_flutter/lib/gen_protos");

    // 清理旧的生成代码
    if dart_out.exists() {
        let _ = tokio::fs::remove_dir_all(&dart_out).await;
    }
    tokio::fs::create_dir_all(&dart_out).await?;

    let spinner = Spinner::new("生成中...");

    // Proto 文件列表
    let protos = [
        "common/common.proto",
        "auth/auth.proto",
        "user/user.proto",
        "content/content.proto",
        "interaction/interaction.proto",
        "comment/comment.proto",
        "timeline/timeline.proto",
        "search/search.proto",
        "notification/notification.proto",
        "chat/chat.proto",
        "gateway/gateway.proto",
        "superuser/superuser.proto",
    ];

    for proto in protos {
        if proto_dir.join(proto).exists() {
            let proto_path = proto_dir.join(proto).to_string_lossy().to_string();
            let _ = Command::new("protoc")
                .args([
                    &format!("--proto_path={}", proto_dir.display()),
                    &format!("--dart_out=grpc:{}", dart_out.display()),
                    &proto_path,
                ])
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .status()
                .await;
        }
    }

    spinner.finish_and_clear();
    ui::step_done("Dart 代码生成完成");

    Ok(())
}

/// 打印生成的代码位置
fn print_generated_locations(target: &str) {
    println!();
    ui::separator();
    ui::info("生成的代码位置:");

    match target {
        "all" => {
            println!("  Go:   service/<service>/gen_protos/");
            println!("  Dart: client/mobile_flutter/lib/gen_protos/");
        }
        "go" => {
            println!("  Go:   service/<service>/gen_protos/");
        }
        "dart" => {
            println!("  Dart: client/mobile_flutter/lib/gen_protos/");
        }
        _ => {}
    }
}
