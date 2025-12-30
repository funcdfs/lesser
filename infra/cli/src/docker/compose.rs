use std::process::Stdio;

use anyhow::{bail, Context, Result};
use serde::Deserialize;
use tokio::io::{AsyncBufReadExt, BufReader};
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
    #[serde(rename = "TargetPort")]
    #[allow(dead_code)]
    target_port: Option<u16>,
    #[serde(rename = "Protocol")]
    #[allow(dead_code)]
    protocol: Option<String>,
}

/// 容器资源使用统计
#[derive(Debug, Clone)]
pub struct ContainerStats {
    pub name: String,
    pub cpu_percent: f64,
    #[allow(dead_code)]
    memory_usage: String,
    pub memory_percent: f64,
}

impl ServiceStatus {
    /// 获取发布的端口列表
    pub fn ports(&self) -> Vec<u16> {
        self.publishers
            .as_ref()
            .map(|pubs| pubs.iter().filter_map(|p| p.published_port).collect())
            .unwrap_or_default()
    }

    /// 获取端口映射字符串 (如 "8000->8000/tcp")
    #[allow(dead_code)]
    pub fn port_mappings(&self) -> Vec<String> {
        self.publishers
            .as_ref()
            .map(|pubs| {
                pubs.iter()
                    .filter_map(|p| {
                        match (p.published_port, p.target_port) {
                            (Some(pub_port), Some(target_port)) => {
                                let proto = p.protocol.as_deref().unwrap_or("tcp");
                                Some(format!("{}->{}:{}", pub_port, target_port, proto))
                            }
                            _ => None,
                        }
                    })
                    .collect()
            })
            .unwrap_or_default()
    }

    /// 检查服务是否运行中
    pub fn is_running(&self) -> bool {
        self.state == "running"
    }

    /// 检查服务是否健康
    #[allow(dead_code)]
    pub fn is_healthy(&self) -> bool {
        self.health.as_deref() == Some("healthy")
    }

    /// 获取服务名称（优先使用 service 字段）
    pub fn service_name(&self) -> &str {
        self.service.as_deref().unwrap_or(&self.name)
    }
}

impl DockerCompose {
    /// 创建新的 DockerCompose 实例
    pub fn new(compose_file: &str, env_file: &str) -> Self {
        Self {
            compose_file: compose_file.to_string(),
            env_file: env_file.to_string(),
        }
    }

    /// 启动服务
    #[allow(dead_code)]
    pub async fn up(&self, services: &[&str], detach: bool) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("up");
        if detach {
            cmd.arg("-d");
        }
        if !services.is_empty() {
            cmd.args(services);
        }
        self.run_command_stream(cmd).await
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

        // docker compose ps --format json 输出每行一个 JSON 对象
        let stdout = String::from_utf8_lossy(&output.stdout);
        let mut statuses = Vec::new();

        for line in stdout.lines() {
            let line = line.trim();
            if !line.is_empty() {
                match serde_json::from_str::<ServiceStatus>(line) {
                    Ok(status) => statuses.push(status),
                    Err(e) => {
                        // 调试模式下输出解析错误
                        if crate::is_debug() {
                            eprintln!("[DEBUG] 解析服务状态失败: {} - {}", e, line);
                        }
                    }
                }
            }
        }

        Ok(statuses)
    }

    /// 查看日志
    pub async fn logs(&self, service: Option<&str>, lines: u32, follow: bool) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("logs");
        cmd.arg(format!("--tail={}", lines));
        if follow {
            cmd.arg("-f");
        }
        if let Some(svc) = service {
            cmd.arg(svc);
        }
        self.run_command_stream(cmd).await
    }

    /// 查看日志并捕获输出
    #[allow(dead_code)]
    pub async fn logs_capture(&self, service: &str, lines: u32) -> Result<String> {
        let mut cmd = self.base_command();
        cmd.args(["logs", &format!("--tail={}", lines), service]);
        
        let output = cmd.output().await.context("执行 docker compose logs 失败")?;
        
        let stdout = String::from_utf8_lossy(&output.stdout);
        let stderr = String::from_utf8_lossy(&output.stderr);
        
        // 日志可能在 stdout 或 stderr
        if !stdout.is_empty() {
            Ok(stdout.to_string())
        } else {
            Ok(stderr.to_string())
        }
    }

    /// 执行容器命令（交互式）
    pub async fn exec(&self, service: &str, command: &[&str], interactive: bool) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("exec");
        if interactive {
            // -i: 保持 stdin 打开, -t: 分配伪终端
            cmd.args(["-i", "-t"]);
        }
        cmd.arg(service);
        cmd.args(command);
        self.run_command_interactive(cmd).await
    }

    /// 执行容器命令并捕获输出
    #[allow(dead_code)]
    pub async fn exec_capture(&self, service: &str, command: &[&str]) -> Result<String> {
        let mut cmd = self.base_command();
        cmd.args(["exec", "-T", service]);
        cmd.args(command);
        
        let output = cmd.output().await.context("执行容器命令失败")?;
        
        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            bail!("命令执行失败: {}", stderr.trim());
        }
        
        Ok(String::from_utf8_lossy(&output.stdout).to_string())
    }

    /// 在容器中运行命令（非交互式，流式输出）
    #[allow(dead_code)]
    pub async fn run(&self, service: &str, command: &[&str]) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.args(["run", "--rm", "-T", service]);
        cmd.args(command);
        self.run_command_stream(cmd).await
    }

    /// 构建镜像
    pub async fn build(&self, service: Option<&str>, no_cache: bool) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("build");
        if no_cache {
            cmd.arg("--no-cache");
        }
        if let Some(svc) = service {
            cmd.arg(svc);
        }
        self.run_command_stream(cmd).await
    }

    /// 构建镜像并显示进度
    pub async fn build_with_progress(&self, service: Option<&str>, no_cache: bool) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.args(["build", "--progress=plain"]);
        if no_cache {
            cmd.arg("--no-cache");
        }
        if let Some(svc) = service {
            cmd.arg(svc);
        }
        self.run_command_stream(cmd).await
    }

    /// 拉取镜像
    #[allow(dead_code)]
    pub async fn pull(&self, services: &[&str]) -> Result<()> {
        let mut cmd = self.base_command();
        cmd.arg("pull");
        if !services.is_empty() {
            cmd.args(services);
        }
        self.run_command_stream(cmd).await
    }

    /// 获取容器资源使用统计
    pub async fn stats(&self) -> Result<Vec<ContainerStats>> {
        // 先获取运行中的容器
        let statuses = self.ps_json().await?;
        let running: Vec<_> = statuses.iter().filter(|s| s.is_running()).collect();
        
        if running.is_empty() {
            return Ok(Vec::new());
        }

        // 获取容器名称列表
        let container_names: Vec<&str> = running.iter().map(|s| s.name.as_str()).collect();
        
        // 使用 docker stats 获取资源使用情况
        let mut cmd = Command::new("docker");
        cmd.args(["stats", "--no-stream", "--format", "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"]);
        cmd.args(&container_names);
        
        let output = cmd.output().await.context("执行 docker stats 失败")?;
        
        if !output.status.success() {
            return Ok(Vec::new());
        }

        let stdout = String::from_utf8_lossy(&output.stdout);
        let mut stats = Vec::new();

        for line in stdout.lines() {
            let parts: Vec<&str> = line.split('\t').collect();
            if parts.len() >= 4 {
                let cpu_str = parts[1].trim_end_matches('%');
                let mem_perc_str = parts[3].trim_end_matches('%');
                
                stats.push(ContainerStats {
                    name: parts[0].to_string(),
                    cpu_percent: cpu_str.parse().unwrap_or(0.0),
                    memory_usage: parts[2].to_string(),
                    memory_percent: mem_perc_str.parse().unwrap_or(0.0),
                });
            }
        }

        Ok(stats)
    }

    /// 检查 Docker 是否可用
    pub async fn check_docker_available() -> Result<bool> {
        let output = Command::new("docker")
            .args(["info"])
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
            .await;
        
        Ok(output.map(|s| s.success()).unwrap_or(false))
    }

    /// 检查 Docker Compose 是否可用
    pub async fn check_compose_available() -> Result<bool> {
        let output = Command::new("docker")
            .args(["compose", "version"])
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
            .await;
        
        Ok(output.map(|s| s.success()).unwrap_or(false))
    }

    /// 获取 Docker Compose 版本
    pub async fn get_compose_version() -> Result<String> {
        let output = Command::new("docker")
            .args(["compose", "version", "--short"])
            .output()
            .await
            .context("获取 Docker Compose 版本失败")?;
        
        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
        } else {
            bail!("获取 Docker Compose 版本失败")
        }
    }

    /// 创建基础命令
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

    /// 运行命令并流式输出到终端
    async fn run_command_stream(&self, mut cmd: Command) -> Result<()> {
        cmd.stdout(Stdio::inherit());
        cmd.stderr(Stdio::inherit());
        
        let status = cmd.status().await.context("执行命令失败")?;
        
        if !status.success() {
            let code = status.code().unwrap_or(1);
            bail!("命令执行失败，退出码: {}", code);
        }
        Ok(())
    }

    /// 运行命令，静默模式（只在失败时显示错误）
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

    /// 运行交互式命令（支持 stdin/stdout/stderr）
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

    /// 运行命令并逐行处理输出（用于进度显示等）
    #[allow(dead_code)]
    async fn run_command_with_callback<F>(&self, mut cmd: Command, mut callback: F) -> Result<()>
    where
        F: FnMut(&str),
    {
        cmd.stdout(Stdio::piped());
        cmd.stderr(Stdio::piped());
        
        let mut child = cmd.spawn().context("启动命令失败")?;
        
        // 处理 stdout
        if let Some(stdout) = child.stdout.take() {
            let reader = BufReader::new(stdout);
            let mut lines = reader.lines();
            
            while let Some(line) = lines.next_line().await? {
                callback(&line);
            }
        }
        
        let status = child.wait().await.context("等待命令完成失败")?;
        
        if !status.success() {
            let code = status.code().unwrap_or(1);
            bail!("命令执行失败，退出码: {}", code);
        }
        Ok(())
    }

    /// 检查服务是否存在于 compose 文件中
    #[allow(dead_code)]
    pub async fn service_exists(&self, service: &str) -> Result<bool> {
        let mut cmd = self.base_command();
        cmd.args(["config", "--services"]);
        
        let output = cmd.output().await.context("获取服务列表失败")?;
        
        if !output.status.success() {
            return Ok(false);
        }
        
        let stdout = String::from_utf8_lossy(&output.stdout);
        Ok(stdout.lines().any(|line| line.trim() == service))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_service_status_is_running() {
        let status = ServiceStatus {
            name: "test".to_string(),
            state: "running".to_string(),
            health: None,
            publishers: None,
            service: None,
        };
        assert!(status.is_running());

        let stopped = ServiceStatus {
            name: "test".to_string(),
            state: "exited".to_string(),
            health: None,
            publishers: None,
            service: None,
        };
        assert!(!stopped.is_running());
    }

    #[test]
    fn test_service_status_is_healthy() {
        let healthy = ServiceStatus {
            name: "test".to_string(),
            state: "running".to_string(),
            health: Some("healthy".to_string()),
            publishers: None,
            service: None,
        };
        assert!(healthy.is_healthy());

        let unhealthy = ServiceStatus {
            name: "test".to_string(),
            state: "running".to_string(),
            health: Some("unhealthy".to_string()),
            publishers: None,
            service: None,
        };
        assert!(!unhealthy.is_healthy());

        let no_health = ServiceStatus {
            name: "test".to_string(),
            state: "running".to_string(),
            health: None,
            publishers: None,
            service: None,
        };
        assert!(!no_health.is_healthy());
    }

    #[test]
    fn test_service_status_ports() {
        let status = ServiceStatus {
            name: "test".to_string(),
            state: "running".to_string(),
            health: None,
            publishers: Some(vec![
                Publisher {
                    published_port: Some(8000),
                    target_port: Some(8000),
                    protocol: Some("tcp".to_string()),
                },
                Publisher {
                    published_port: Some(8001),
                    target_port: Some(8001),
                    protocol: Some("tcp".to_string()),
                },
                Publisher {
                    published_port: None,
                    target_port: Some(9000),
                    protocol: None,
                },
            ]),
            service: None,
        };
        
        let ports = status.ports();
        assert_eq!(ports, vec![8000, 8001]);
    }

    #[test]
    fn test_service_status_port_mappings() {
        let status = ServiceStatus {
            name: "test".to_string(),
            state: "running".to_string(),
            health: None,
            publishers: Some(vec![
                Publisher {
                    published_port: Some(8000),
                    target_port: Some(8000),
                    protocol: Some("tcp".to_string()),
                },
            ]),
            service: None,
        };
        
        let mappings = status.port_mappings();
        assert_eq!(mappings, vec!["8000->8000:tcp"]);
    }

    #[test]
    fn test_service_name() {
        let with_service = ServiceStatus {
            name: "container-name".to_string(),
            state: "running".to_string(),
            health: None,
            publishers: None,
            service: Some("django".to_string()),
        };
        assert_eq!(with_service.service_name(), "django");

        let without_service = ServiceStatus {
            name: "container-name".to_string(),
            state: "running".to_string(),
            health: None,
            publishers: None,
            service: None,
        };
        assert_eq!(without_service.service_name(), "container-name");
    }
}
