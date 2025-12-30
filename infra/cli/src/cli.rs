use clap::{Parser, Subcommand, ValueEnum};
use clap_complete::Shell;

/// Lesser 项目开发环境管理 CLI 工具
#[derive(Parser)]
#[command(name = "devlesser")]
#[command(author, version, about = "Lesser 项目开发环境管理工具")]
#[command(propagate_version = true)]
#[command(arg_required_else_help = true)]
#[command(subcommand_help_heading = "命令")]
#[command(disable_help_subcommand = true)]
pub struct Cli {
    /// 启用调试输出
    #[arg(short, long, global = true)]
    pub debug: bool,

    #[command(subcommand)]
    pub command: Commands,
}

/// 所有可用命令
#[derive(Subcommand)]
pub enum Commands {
    /// 启动服务
    Start {
        /// 目标: all, service, infra, django, chat, client, flutter, react
        #[arg(default_value = "all")]
        target: StartTarget,
    },

    /// 停止服务
    Stop {
        /// 目标服务
        target: Option<String>,
    },

    /// 重启服务
    Restart {
        /// 服务名称
        service: Option<String>,
    },

    /// 查看日志
    Logs {
        /// 服务名称
        service: Option<String>,
        /// 显示行数
        #[arg(short = 'n', long, default_value = "100")]
        lines: u32,
        /// 实时跟踪
        #[arg(short, long)]
        follow: bool,
    },

    /// 查看服务状态
    #[command(alias = "ps")]
    Status,

    /// 测试服务连通性
    Test,

    /// 初始化开发环境
    Init,

    /// 检查依赖
    Check,

    /// 更新环境
    Update,

    /// 执行数据库迁移
    Migrate,

    /// 生成迁移文件
    Makemigrations {
        /// Django app 名称
        app: Option<String>,
    },

    /// 创建超级用户
    Createsuperuser,

    /// 数据库操作
    Db {
        #[command(subcommand)]
        command: DbCommands,
    },

    /// 构建镜像
    Build {
        /// 服务名称
        service: Option<String>,
    },

    /// 重新构建镜像
    Rebuild {
        /// 服务名称
        service: Option<String>,
    },

    /// 生成 Proto 代码
    Proto {
        /// 目标: all, python, go, dart, typescript
        #[arg(default_value = "all")]
        target: String,
    },

    /// 清理环境
    Clean {
        #[command(subcommand)]
        command: Option<CleanCommands>,
        /// 跳过确认
        #[arg(short, long)]
        force: bool,
    },

    /// 进入容器
    Enter {
        /// 服务名称: django, chat, postgres, redis, traefik
        service: String,
    },

    /// Django Python Shell
    Shell,

    /// 进入容器 Shell
    Bash {
        /// 服务名称
        #[arg(default_value = "django")]
        service: String,
    },

    /// 显示环境变量
    Env,

    /// 显示服务地址
    Urls,

    /// 生成补全脚本
    Completion {
        /// Shell 类型: bash, zsh, fish
        shell: Shell,
    },
}

/// 启动目标
#[derive(ValueEnum, Clone, Debug)]
pub enum StartTarget {
    /// 启动所有服务
    All,
    /// 启动后端服务 (Django + Chat)
    Service,
    /// 启动基础设施 (PostgreSQL + Redis + Traefik)
    Infra,
    /// 启动 Django 服务
    Django,
    /// 启动 Chat 服务
    Chat,
    /// 启动所有客户端
    Client,
    /// 启动 Flutter Web
    Flutter,
    /// 启动 React Web
    React,
}

/// 数据库子命令
#[derive(Subcommand, Clone, Debug)]
pub enum DbCommands {
    /// 进入数据库 shell (psql)
    Shell,
    /// 重置数据库 (需要确认)
    Reset,
}

/// 清理子命令
#[derive(Subcommand, Clone, Debug)]
pub enum CleanCommands {
    /// 清理容器
    Containers,
    /// 清理数据卷 (需要确认)
    Volumes,
}
