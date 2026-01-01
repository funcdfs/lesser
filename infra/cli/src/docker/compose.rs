use std::process::Stdio;

use anyhow::{bail, Context, Result};
use serde::Deserialize;
use tokio::process::Command;

/// Docker Compose 操作封装
pub struct DockerCompose {
    compose_file: String,
    env_file: String,
}

/// 服务状态
#[derive(Debug, Deserialize, Clone)]
pub struct ServiceStatus {
    #[serde(rename = "Name")]
    pub name: String,
    #[serde(rename = "State")]
    pub state: String,
    #[serde(rename = "Health")]
    pub health: Option<String>,
    #[serde(rename = "Publishers")]
    pub publishers: Option<Vec<Publisher>>,
    #[serde(rename = "Service")]
    pub service: Option<String>,
}

/// 端口发布信息
#[derive(Debug, Deserialize, Clone)]
pub struct Publisher {
    #[serde(rename = "PublishedPort")]
    pub published_port: Option<u16>,
}

/// 容器资源使用统计
#[derive(Debug, Clone)]
pub struct ContainerStats {
    pub name: String,
    pub cpu_percent: f64,
    pub memory_percent: f64,
}

impl ServiceStatus {
    pub fn ports(&self) -> Vec<u16> {
        self.publishers
            .as_ref()
            .map(|pubs| pubs.iter().filter_map(|p| p.published_port).collect())
            .unwrap_or_default()
    }

    pub fn is_running(&self) -> bool {
        self.state == "running"
    }

    pub fn service_name(&self) -> &str {
        self.service.as_deref().unwrap_or(&self.name)
    }
}

impl DockerCompose {
    pub fn new(compose_file: &str, env_file: &str) -> Self {
        Self {
            compose_file: compose_file.to_string(),
            env_file: env_file.to_string(),
        }
    }

    /// 启动服务并等待健康检查
    pub async fn up_wait(&self, services: &[&str]) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.args(["up", "-d", "--wait"]);
        if !services.is_empty() {
            cmd.args(services);
        }
        self.run_command_quiet(cmd).await
    }

    /// 停止并移除服务
    pub async fn down(&self, volumes: bool, orphans: bool) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("down");
        if volumes {
            cmd.arg("-v");
        }
        if orphans {
            cmd.arg("--remove-orphans");
        }
        self.run_command_quiet(cmd).await
    }

    /// 停止指定服务（不移除）
    pub async fn stop(&self, services: &[&str]) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("stop");
        if !services.is_empty() {
            cmd.args(services);
        }
        self.run_command_quiet(cmd).await
    }

    /// 重启服务
    pub async fn restart(&self, services: &[&str]) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("restart");
        if !services.is_empty() {
            cmd.args(services);
        }
        self.run_command_quiet(cmd).await
    }

    /// 获取服务状态 (JSON 格式)
    pub async fn ps_json(&self) -> Result<Vec<ServiceStatus>> {
        let mut cmd = self.base_command();
        cmd.args(["ps", "-a", "--format", "json"]);
        let output = cmd.output().await.context("执行 docker compose ps 失败")?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            bail!("获取服务状态失败: {}", stderr.trim());
        }

        let stdout = String::from_utf8_lossy(&output.stdout);
        let mut statuses = Vec::new();

        for line in stdout.lines() {
            let line = line.trim();
            if !line.is_empty() {
                if let Ok(status) = serde_json::from_str::<ServiceStatus>(line) {
                    statuses.push(status);
                }
            }
        }

        Ok(statuses)
    }

    /// 执行容器命令
    pub async fn exec(&self, service: &str, command: &[&str], interactive: bool) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("exec");
        if interactive {
            cmd.args(["-i", "-t"]);
        }
        cmd.arg(service);
        cmd.args(command);
        self.run_command_interactive(cmd).await
    }

    /// 获取容器资源使用统计
    pub async fn stats(&self) -> Result<Vec<ContainerStats>> {
        let statuses = self.ps_json().await?;
        let running: Vec<_> = statuses.iter().filter(|s| s.is_running()).collect();
        
        if running.is_empty() {
            return Ok(Vec::new());
        }

        let container_names: Vec<&str> = running.iter().map(|s| s.name.as_str()).collect();
        
        let mut cmd = Command::new("docker");
        cmd.args(["stats", "--no-stream", "--format", "{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}"]);
        cmd.args(&container_names);
        
        let output = cmd.output().await.context("执行 docker stats 失败")?;
        
        if !output.status.success() {
            return Ok(Vec::new());
        }

        let stdout = String::from_utf8_lossy(&output.stdout);
        let mut stats = Vec::new();

        for line in stdout.lines() {
            let parts: Vec<&str> = line.split('\t').collect();
            if parts.len() >= 3 {
                let cpu_str = parts[1].trim_end_matches('%');
                let mem_str = parts[2].trim_end_matches('%');
                
                stats.push(ContainerStats {
                    name: parts[0].to_string(),
                    cpu_percent: cpu_str.parse().unwrap_or(0.0),
                    memory_percent: mem_str.parse().unwrap_or(0.0),
                });
            }
        }

        Ok(stats)
    }

    fn base_command(&self) -> Command {
        let mut cmd = Command::new("docker");
        cmd.args([
            "compose",
            "-f",
            &self.compose_file,
            "--env-file",
            &self.env_file,
        ]);
        cmd
    }

    async fn run_command_quiet(&self, mut cmd: Command) -> Result<()> {
        cmd.stdout(Stdio::null());
        cmd.stderr(Stdio::piped());
        
        let output = cmd.output().await.context("执行命令失败")?;
        
        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            let code = output.status.code().unwrap_or(1);
            if !stderr.trim().is_empty() {
                bail!("{}", stderr.trim());
            }
            bail!("命令执行失败，退出码: {}", code);
        }
        Ok(())
    }

    async fn run_command_interactive(&self, mut cmd: Command) -> Result<()> {
        cmd.stdin(Stdio::inherit());
        cmd.stdout(Stdio::inherit());
        cmd.stderr(Stdio::inherit());
        
        let status = cmd.status().await.context("执行交互式命令失败")?;
        
        if !status.success() {
            let code = status.code().unwrap_or(1);
            bail!("命令执行失败，退出码: {}", code);
        }
        Ok(())
    }
}
