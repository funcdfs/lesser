use anyhow::Result;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// 执行 build 命令
///
/// # Arguments
/// * `service` - 可选的服务名称，如果为 None 则构建所有服务
/// * `no_cache` - 是否使用 --no-cache 选项（rebuild 命令使用）
pub async fn execute(service: Option<String>, no_cache: bool) -> Result<()> {
    let config = Config::load()?;

    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    let action = if no_cache { "重新构建" } else { "构建" };
    let target = service.as_deref().unwrap_or("所有服务");

    ui::header(&format!("{} Docker 镜像", action));

    if no_cache {
        ui::warn("使用 --no-cache 选项，构建时间可能较长");
    }

    let spinner_msg = format!("正在{}{}...", action, target);
    let spinner = Spinner::new(&spinner_msg);

    // 使用带进度显示的构建
    let result = compose
        .build_with_progress(service.as_deref(), no_cache)
        .await;

    spinner.finish_and_clear();

    match result {
        Ok(()) => {
            ui::success(&format!("🐳 {} {} 完成", action, target));

            // 如果是 rebuild，提示用户可能需要重启服务
            if no_cache {
                ui::info("提示: 运行 'devlesser restart' 以使用新镜像重启服务");
            }

            Ok(())
        }
        Err(e) => {
            ui::error(&format!("{} {} 失败: {}", action, target, e));
            ui::info("提示: 运行 'devlesser logs <service>' 查看详细日志");
            Err(e)
        }
    }
}
