use std::process::Stdio;

use anyhow::Result;
use tokio::process::Command;

use crate::docker::DockerCompose;
use crate::ui::{self, CHECK, CROSS};

/// 依赖信息
struct DependencyInfo {
    name: &'static str,
    version: Option<String>,
    installed: bool,
    required: bool,
    install_url: &'static str,
}

/// 执行 check 命令 - 检查所有依赖
pub async fn execute() -> Result<()> {
    ui::header("依赖检查");

    let mut all_required_ok = true;

    // 核心依赖
    println!("核心依赖:");
    ui::separator();

    // Docker
    let docker_info = check_docker().await;
    print_dependency(&docker_info);
    if docker_info.required && !docker_info.installed {
        all_required_ok = false;
    }

    // Docker Compose
    let compose_info = check_docker_compose().await;
    print_dependency(&compose_info);
    if compose_info.required && !compose_info.installed {
        all_required_ok = false;
    }

    println!();
    println!("开发依赖 (可选):");
    ui::separator();

    // Go
    let go_info = check_go().await;
    print_dependency(&go_info);

    // Flutter
    let flutter_info = check_flutter().await;
    print_dependency(&flutter_info);

    // Node.js
    let node_info = check_node().await;
    print_dependency(&node_info);

    // npm
    let npm_info = check_npm().await;
    print_dependency(&npm_info);

    println!();

    if all_required_ok {
        ui::success("所有核心依赖已安装");
        Ok(())
    } else {
        ui::error("缺少必要依赖，请先安装");
        std::process::exit(3);
    }
}

/// 打印依赖信息
fn print_dependency(info: &DependencyInfo) {
    let status_icon = if info.installed { CHECK } else { CROSS };
    let version_str = info
        .version
        .as_ref()
        .map(|v| format!(" {}", v))
        .unwrap_or_default();

    if info.installed {
        println!("  {} {}{}", status_icon, info.name, version_str);
    } else if info.required {
        println!("  {} {} (未安装)", status_icon, info.name);
        println!("     安装: {}", info.install_url);
    } else {
        println!("  ⚠ {} (未安装)", info.name);
    }
}

/// 检查 Docker
async fn check_docker() -> DependencyInfo {
    let mut info = DependencyInfo {
        name: "Docker",
        version: None,
        installed: false,
        required: true,
        install_url: "https://docs.docker.com/get-docker/",
    };

    // 检查 docker 命令是否存在
    if !DockerCompose::check_docker_available().await.unwrap_or(false) {
        return info;
    }

    // 获取版本
    if let Ok(output) = Command::new("docker")
        .args(["--version"])
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .output()
        .await
    {
        if output.status.success() {
            let version_str = String::from_utf8_lossy(&output.stdout);
            // Docker version 24.0.7, build afdd53b
            if let Some(version) = version_str
                .split_whitespace()
                .nth(2)
                .map(|s| s.trim_end_matches(',').to_string())
            {
                info.version = Some(version);
            }
            info.installed = true;
        }
    }

    info
}

/// 检查 Docker Compose
async fn check_docker_compose() -> DependencyInfo {
    let mut info = DependencyInfo {
        name: "Docker Compose",
        version: None,
        installed: false,
        required: true,
        install_url: "https://docs.docker.com/compose/install/",
    };

    if !DockerCompose::check_compose_available()
        .await
        .unwrap_or(false)
    {
        return info;
    }

    // 获取版本
    if let Ok(version) = DockerCompose::get_compose_version().await {
        info.version = Some(version);
        info.installed = true;
    }

    info
}

/// 检查 Go
async fn check_go() -> DependencyInfo {
    let mut info = DependencyInfo {
        name: "Go",
        version: None,
        installed: false,
        required: false, // Docker 环境下不是必需的
        install_url: "https://go.dev/doc/install",
    };

    if let Ok(output) = Command::new("go")
        .args(["version"])
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .output()
        .await
    {
        if output.status.success() {
            let version_str = String::from_utf8_lossy(&output.stdout);
            // go version go1.23.0 darwin/arm64
            if let Some(version) = version_str.split_whitespace().nth(2) {
                info.version = Some(version.trim_start_matches("go").to_string());
            }
            info.installed = true;
        }
    }

    info
}

/// 检查 Flutter
async fn check_flutter() -> DependencyInfo {
    let mut info = DependencyInfo {
        name: "Flutter",
        version: None,
        installed: false,
        required: false,
        install_url: "https://docs.flutter.dev/get-started/install",
    };

    if let Ok(output) = Command::new("flutter")
        .args(["--version"])
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .output()
        .await
    {
        if output.status.success() {
            let version_str = String::from_utf8_lossy(&output.stdout);
            // Flutter 3.16.0 • channel stable ...
            if let Some(version) = version_str.lines().next().and_then(|line| {
                line.split_whitespace()
                    .nth(1)
                    .map(|s| s.to_string())
            }) {
                info.version = Some(version);
            }
            info.installed = true;
        }
    }

    info
}

/// 检查 Node.js
async fn check_node() -> DependencyInfo {
    let mut info = DependencyInfo {
        name: "Node.js",
        version: None,
        installed: false,
        required: false,
        install_url: "https://nodejs.org/",
    };

    if let Ok(output) = Command::new("node")
        .args(["--version"])
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .output()
        .await
    {
        if output.status.success() {
            let version_str = String::from_utf8_lossy(&output.stdout);
            // v20.10.0
            info.version = Some(version_str.trim().to_string());
            info.installed = true;
        }
    }

    info
}

/// 检查 npm
async fn check_npm() -> DependencyInfo {
    let mut info = DependencyInfo {
        name: "npm",
        version: None,
        installed: false,
        required: false,
        install_url: "https://nodejs.org/",
    };

    if let Ok(output) = Command::new("npm")
        .args(["--version"])
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .output()
        .await
    {
        if output.status.success() {
            let version_str = String::from_utf8_lossy(&output.stdout);
            info.version = Some(version_str.trim().to_string());
            info.installed = true;
        }
    }

    info
}
