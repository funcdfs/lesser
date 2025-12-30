use thiserror::Error;

/// CLI 错误类型
#[derive(Error, Debug)]
pub enum DevError {
    /// Docker 未安装或未运行
    #[error("Docker 未安装或未运行")]
    #[allow(dead_code)]
    DockerNotAvailable,

    /// Docker Compose 未安装
    #[error("Docker Compose 未安装")]
    #[allow(dead_code)]
    DockerComposeNotAvailable,

    /// 环境变量文件不存在
    #[error("环境变量文件不存在: {0}")]
    #[allow(dead_code)]
    EnvFileNotFound(String),

    /// 缺少必要的环境变量
    #[error("缺少必要的环境变量: {0:?}")]
    #[allow(dead_code)]
    MissingEnvVars(Vec<String>),

    /// 服务未运行
    #[error("服务 {0} 未运行")]
    #[allow(dead_code)]
    ServiceNotRunning(String),

    /// 健康检查失败
    #[error("健康检查失败: {0}")]
    #[allow(dead_code)]
    HealthCheckFailed(String),

    /// 命令执行失败
    #[error("命令执行失败: {0}")]
    #[allow(dead_code)]
    CommandFailed(String),

    /// 用户取消操作
    #[error("用户取消操作")]
    #[allow(dead_code)]
    UserCancelled,

    /// 项目根目录未找到
    #[error("无法找到项目根目录")]
    ProjectRootNotFound,

    /// 依赖缺失
    #[error("依赖 {name} 未安装")]
    #[allow(dead_code)]
    DependencyMissing {
        name: String,
        install_url: Option<String>,
    },

    /// 配置错误
    #[error("配置错误: {0}")]
    #[allow(dead_code)]
    ConfigError(String),
}

impl DevError {
    /// 获取退出码
    #[allow(dead_code)]
    pub fn exit_code(&self) -> i32 {
        match self {
            DevError::DockerNotAvailable | DevError::DockerComposeNotAvailable => 3,
            DevError::DependencyMissing { .. } => 3,
            DevError::EnvFileNotFound(_) | DevError::MissingEnvVars(_) => 2,
            DevError::ConfigError(_) | DevError::ProjectRootNotFound => 2,
            DevError::UserCancelled => 130,
            _ => 1,
        }
    }

    /// 获取安装说明
    #[allow(dead_code)]
    pub fn install_instructions(&self) -> Option<String> {
        match self {
            DevError::DockerNotAvailable => Some(
                "请安装 Docker Desktop: https://docs.docker.com/get-docker/\n\
                 或启动 Docker 服务: sudo systemctl start docker"
                    .to_string(),
            ),
            DevError::DockerComposeNotAvailable => Some(
                "Docker Compose 通常随 Docker Desktop 一起安装。\n\
                 如果使用 Linux，请参考: https://docs.docker.com/compose/install/"
                    .to_string(),
            ),
            DevError::DependencyMissing { install_url, .. } => install_url.clone(),
            _ => None,
        }
    }

    /// 获取建议操作
    #[allow(dead_code)]
    pub fn suggested_action(&self) -> Option<String> {
        match self {
            DevError::ServiceNotRunning(service) => {
                Some(format!("尝试运行: devlesser start {}", service))
            }
            DevError::HealthCheckFailed(_) => Some("运行 devlesser logs 查看服务日志".to_string()),
            DevError::CommandFailed(_) => Some("运行 devlesser logs 查看详细错误信息".to_string()),
            DevError::EnvFileNotFound(_) => Some("运行 devlesser init 初始化环境".to_string()),
            DevError::MissingEnvVars(_) => {
                Some("检查 infra/env/dev.env 文件是否包含所有必需变量".to_string())
            }
            _ => None,
        }
    }
}

/// 打印错误信息
#[allow(dead_code)]
pub fn print_error(err: &DevError) {
    use crate::ui;

    ui::error(&err.to_string());

    if let Some(instructions) = err.install_instructions() {
        println!();
        println!("  {}", instructions.replace('\n', "\n  "));
    }

    if let Some(action) = err.suggested_action() {
        println!();
        ui::info(&format!("建议: {}", action));
    }
}
