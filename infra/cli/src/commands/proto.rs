use std::process::Stdio;

use anyhow::{bail, Context, Result};
use tokio::process::Command;

use crate::config::paths;
use crate::ui::{self, Spinner};

/// 支持的 proto 生成目标
const VALID_TARGETS: &[&str] = &["all", "python", "go", "dart", "typescript"];

/// 执行 proto 命令
///
/// # Arguments
/// * `target` - 生成目标: all, python, go, dart, typescript
pub async fn execute(target: String) -> Result<()> {
    // 验证目标参数
    let target_lower = target.to_lowercase();
    if !VALID_TARGETS.contains(&target_lower.as_str()) {
        ui::error(&format!("无效的目标: {}", target));
        ui::info(&format!("支持的目标: {}", VALID_TARGETS.join(", ")));
        bail!("无效的 proto 生成目标");
    }

    ui::header("生成 Protocol Buffer 代码");

    // 获取脚本路径
    let script_path = paths::get_proto_script()?;

    if !script_path.exists() {
        ui::error(&format!("Proto 生成脚本不存在: {}", script_path.display()));
        ui::info("请确保 scripts/proto/generate.sh 文件存在");
        bail!("Proto 生成脚本不存在");
    }

    // 获取项目根目录
    let project_root = paths::find_project_root()?;

    ui::info(&format!("目标: {}", target_lower));

    let spinner = Spinner::new("正在生成 Proto 代码...");

    // 执行生成脚本
    let mut cmd = Command::new("bash");
    cmd.arg(&script_path);

    // 如果不是 all，传递目标参数
    if target_lower != "all" {
        cmd.arg(&target_lower);
    }

    cmd.current_dir(&project_root);
    cmd.stdout(Stdio::inherit());
    cmd.stderr(Stdio::inherit());

    let status = cmd
        .status()
        .await
        .context("执行 proto 生成脚本失败")?;

    spinner.finish_and_clear();

    if status.success() {
        ui::success("🔌 Proto 代码生成完成");
        print_generated_locations(&target_lower);
        Ok(())
    } else {
        let code = status.code().unwrap_or(1);
        ui::error(&format!("Proto 代码生成失败，退出码: {}", code));
        bail!("Proto 代码生成失败");
    }
}

/// 打印生成的代码位置
fn print_generated_locations(target: &str) {
    ui::separator();
    ui::info("生成的代码位置:");

    match target {
        "all" => {
            ui::url("Python", "service/core_django/generated/protos/");
            ui::url("Go", "service/chat_gin/generated/protos/");
            ui::url("Dart", "client/mobile_flutter/lib/generated/protos/");
            ui::url("TypeScript", "client/web_react/src/generated/protos/");
        }
        "python" => {
            ui::url("Python", "service/core_django/generated/protos/");
        }
        "go" => {
            ui::url("Go", "service/chat_gin/generated/protos/");
        }
        "dart" => {
            ui::url("Dart", "client/mobile_flutter/lib/generated/protos/");
        }
        "typescript" => {
            ui::url("TypeScript", "client/web_react/src/generated/protos/");
        }
        _ => {}
    }
}
