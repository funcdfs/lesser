use clap::{Parser, Subcommand, ValueEnum};

/// Lesser 项目开发环境管理 CLI 工具
#[derive(Parser)]
#[command(name = "devlesser")]
#[command(author, version, about = "Lesser 开发环境管理工具 🚀")]
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
    /// 🚀 启动服务
    #[command(alias = "up")]
    Start {
        /// 目标: all, infra, service, flutter
        #[arg(default_value = "all")]
        target: StartTarget,
    },

    /// 🛑 停止服务
    #[command(alias = "down")]
    Stop {
        /// 目标服务 (可选，默认停止全部)
        target: Option<String>,
    },

    /// 🔄 重启服务
    Restart {
        /// 服务名称 (可选，默认重启全部)
        service: Option<String>,
    },

    /// 🗑️  清理环境
    #[command(alias = "rm")]
    Clean {
        /// 清理目标
        #[command(subcommand)]
        command: Option<CleanCommands>,
        /// 跳过确认
        #[arg(short, long)]
        force: bool,
    },

    /// ⚡ 初始化开发环境
    Init {
        /// 跳过确认
        #[arg(short, long)]
        force: bool,
    },

    /// 📊 查看服务状态
    #[command(alias = "ps")]
    Status,

    /// 🔧 生成 Proto 代码
    Proto {
        /// 目标: all, go, dart
        #[arg(default_value = "all")]
        target: String,
    },
}

/// 启动目标
#[derive(ValueEnum, Clone, Debug, PartialEq)]
pub enum StartTarget {
    /// 启动所有服务
    All,
    /// 仅启动基础设施 (PostgreSQL + Redis + RabbitMQ + Traefik)
    Infra,
    /// 仅启动后端服务 (Gateway + Workers + Chat)
    Service,
    /// 启动 Flutter Web 开发服务器
    Flutter,
}

/// 清理子命令
#[derive(Subcommand, Clone, Debug)]
pub enum CleanCommands {
    /// 仅清理容器 (保留数据)
    Containers,
    /// 清理数据卷 (删除所有数据)
    Volumes,
    /// 清理聊天数据
    Chat,
    /// 清理用户数据
    Users,
}
