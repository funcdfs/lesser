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
        /// 跳过 hosts 配置
        #[arg(long)]
        skip_hosts: bool,
    },

    /// 📊 查看服务状态
    #[command(alias = "ps")]
    Status,

    /// 🔧 生成 Proto 代码
    #[command(alias = "gen")]
    Proto {
        /// 目标: all, go, dart
        #[arg(default_value = "all")]
        target: String,
    },

    /// 🧪 运行测试
    Test {
        /// 测试目标: all, services, search
        #[arg(default_value = "all")]
        target: TestTarget,
    },

    /// 🌐 配置本地 hosts
    Hosts,

    /// 🏭 生产环境管理
    Prod {
        /// 生产环境子命令
        #[command(subcommand)]
        command: ProdCommands,
        /// 跳过确认
        #[arg(short, long, global = true)]
        force: bool,
    },
}

/// 测试目标
#[derive(ValueEnum, Clone, Debug, PartialEq)]
pub enum TestTarget {
    /// 运行所有服务测试
    All,
    /// Auth 服务测试
    Auth,
    /// User 服务测试
    User,
    /// Content 服务测试
    Content,
    /// Comment 服务测试
    Comment,
    /// Interaction 服务测试
    Interaction,
    /// Timeline 服务测试
    Timeline,
    /// Search 服务测试
    Search,
    /// Notification 服务测试
    Notification,
    /// Chat 服务测试
    Chat,
    /// Gateway 路由测试
    Gateway,
    /// SuperUser 服务测试
    #[value(alias = "su")]
    Superuser,
    /// 数据库分表验证
    Db,
    /// 服务联动测试
    Integration,
    /// 第一轮测试（初始化）
    Round1,
    /// 第二轮测试（重建）
    Round2,
    /// 第三轮测试（重启）
    Round3,
    /// 完整三轮测试
    Full,
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
    /// Flutter 交互式选择平台
    Flutter,
    /// Flutter Web 开发服务器
    #[value(alias = "fw")]
    FlutterWeb,
    /// Flutter Android 开发
    #[value(alias = "fa")]
    FlutterAndroid,
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

/// 生产环境子命令
#[derive(Subcommand, Clone, Debug)]
pub enum ProdCommands {
    /// 启动生产环境
    Start,
    /// 停止生产环境
    Stop,
    /// 重启服务
    Restart,
    /// 查看服务状态
    Status,
    /// 查看日志
    Logs {
        /// 服务名称 (可选)
        service: Option<String>,
        /// 显示行数
        #[arg(short = 'n', long, default_value = "100")]
        lines: u32,
    },
    /// 部署更新
    Deploy,
    /// 备份数据库
    Backup,
    /// 验证环境变量
    Validate,
}
