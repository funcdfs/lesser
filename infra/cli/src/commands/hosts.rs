use std::process::Stdio;

use anyhow::{bail, Result};
use tokio::process::Command;

use crate::ui::{self, Spinner};

/// 本地域名配置
const LOCAL_DOMAINS: &[(&str, &str)] = &[
    ("traefik.local", "Traefik Dashboard"),
    ("rabbitmq.local", "RabbitMQ Management"),
    ("redis.local", "RedisInsight"),
    ("pghero.local", "PgHero (PostgreSQL 监控)"),
    ("jaeger.local", "Jaeger UI (链路追踪)"),
    ("dozzle.local", "Dozzle (容器日志)"),
];

const MARKER_START: &str = "# === Lesser Dev Domains Start ===";
const MARKER_END: &str = "# === Lesser Dev Domains End ===";

/// 执行 hosts 命令
///
/// 配置本地 hosts 文件，支持通过域名访问各服务控制面板
pub async fn execute() -> Result<()> {
    ui::header("配置本地 hosts");

    // 检查是否有 sudo 权限
    ui::warn("此操作需要 sudo 权限来修改 /etc/hosts 文件");
    println!();

    // 显示将要添加的域名
    ui::info("将添加以下本地域名:");
    for (domain, desc) in LOCAL_DOMAINS {
        println!("  127.0.0.1 {:<20} → {}", domain, desc);
    }
    println!();

    // 确认操作
    let confirmed = ui::confirm("是否继续?", true)?;
    if !confirmed {
        ui::info("操作已取消");
        return Ok(());
    }

    let spinner = Spinner::new("配置 hosts 文件...");

    match setup_hosts_internal().await {
        Ok(_) => {
            spinner.finish_and_clear();
            ui::success("hosts 配置完成!");
            println!();
            ui::info("现在可以通过以下域名访问服务控制面板:");
            println!();
            for (domain, desc) in LOCAL_DOMAINS {
                println!("  http://{:<20} → {}", domain, desc);
            }
            println!();
            Ok(())
        }
        Err(e) => {
            spinner.finish_and_clear();
            ui::error(&format!("配置失败: {}", e));
            bail!("hosts 配置失败");
        }
    }
}

/// 在 init 命令中调用的简化版本（不需要确认）
pub async fn setup_hosts_silent() -> Result<()> {
    setup_hosts_internal().await
}

/// 内部实现：配置 hosts 文件
async fn setup_hosts_internal() -> Result<()> {
    // 构建 hosts 内容
    let mut hosts_content = String::new();
    hosts_content.push('\n');
    hosts_content.push_str(MARKER_START);
    hosts_content.push('\n');
    for (domain, _) in LOCAL_DOMAINS {
        hosts_content.push_str(&format!("127.0.0.1 {}\n", domain));
    }
    hosts_content.push_str(MARKER_END);
    hosts_content.push('\n');

    // 使用 sudo 执行脚本
    // 先移除旧配置，再添加新配置
    let script = format!(
        r#"
        # 移除旧配置
        if grep -q "{marker_start}" /etc/hosts; then
            sed -i.bak "/{marker_start_escaped}/,/{marker_end_escaped}/d" /etc/hosts
        fi
        # 添加新配置
        echo '{hosts_content}' >> /etc/hosts
        "#,
        marker_start = MARKER_START,
        marker_start_escaped = MARKER_START.replace("/", "\\/").replace(" ", "\\ "),
        marker_end_escaped = MARKER_END.replace("/", "\\/").replace(" ", "\\ "),
        hosts_content = hosts_content.trim(),
    );

    let result = Command::new("sudo")
        .args(["bash", "-c", &script])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .status()
        .await;

    match result {
        Ok(status) if status.success() => Ok(()),
        Ok(status) => {
            let code = status.code().unwrap_or(1);
            bail!("退出码: {}", code);
        }
        Err(e) => bail!("{}", e),
    }
}

/// 检查 hosts 是否已配置
#[allow(dead_code)]
pub async fn is_hosts_configured() -> bool {
    let output = Command::new("grep")
        .args(["-q", MARKER_START, "/etc/hosts"])
        .status()
        .await;

    output.map(|s| s.success()).unwrap_or(false)
}

/// 获取配置的域名列表
#[allow(dead_code)]
pub fn get_local_domains() -> &'static [(&'static str, &'static str)] {
    LOCAL_DOMAINS
}
