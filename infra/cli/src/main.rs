mod cli;
mod commands;
mod config;
mod docker;
mod error;
mod ui;

use anyhow::Result;
use clap::Parser;
use cli::{Cli, Commands, ProdCommands, TestTarget};
use std::sync::atomic::{AtomicBool, Ordering};

/// 全局调试模式标志
pub static DEBUG_MODE: AtomicBool = AtomicBool::new(false);

/// 检查是否启用调试模式
pub fn is_debug() -> bool {
    DEBUG_MODE.load(Ordering::Relaxed)
}

#[tokio::main]
async fn main() -> Result<()> {
    // 设置 Ctrl+C 处理
    ctrlc::set_handler(move || {
        eprintln!("\n中断操作");
        std::process::exit(130);
    })?;

    let cli = Cli::parse();

    // 设置调试模式
    if cli.debug {
        DEBUG_MODE.store(true, Ordering::Relaxed);
    }

    // 执行命令
    match cli.command {
        Commands::Start { target } => commands::start::execute(target).await,
        Commands::Stop { target } => commands::stop::execute(target).await,
        Commands::Restart { service } => commands::restart::execute(service).await,
        Commands::Clean { command, force } => commands::clean::execute(command, force).await,
        Commands::Init { force, skip_hosts } => commands::init::execute(force, skip_hosts).await,
        Commands::Status => commands::status::execute().await,
        Commands::Proto { target } => commands::proto::execute(target).await,
        Commands::Test { target } => {
            // 转换 clap 的 TestTarget 到 commands::test::TestTarget
            let test_target = match target {
                TestTarget::All => commands::test::TestTarget::All,
                TestTarget::Auth => commands::test::TestTarget::Auth,
                TestTarget::User => commands::test::TestTarget::User,
                TestTarget::Content => commands::test::TestTarget::Content,
                TestTarget::Comment => commands::test::TestTarget::Comment,
                TestTarget::Interaction => commands::test::TestTarget::Interaction,
                TestTarget::Timeline => commands::test::TestTarget::Timeline,
                TestTarget::Search => commands::test::TestTarget::Search,
                TestTarget::Notification => commands::test::TestTarget::Notification,
                TestTarget::Chat => commands::test::TestTarget::Chat,
                TestTarget::Channel => commands::test::TestTarget::Channel,
                TestTarget::Gateway => commands::test::TestTarget::Gateway,
                TestTarget::Superuser => commands::test::TestTarget::Superuser,
                TestTarget::Db => commands::test::TestTarget::Db,
                TestTarget::Integration => commands::test::TestTarget::Integration,
                TestTarget::Round1 => commands::test::TestTarget::Round1,
                TestTarget::Round2 => commands::test::TestTarget::Round2,
                TestTarget::Round3 => commands::test::TestTarget::Round3,
                TestTarget::Full => commands::test::TestTarget::Full,
            };
            commands::test::execute(test_target).await
        }
        Commands::Hosts => commands::hosts::execute().await,
        Commands::Prod { command, force } => {
            let prod_cmd = match command {
                ProdCommands::Start => commands::prod::ProdCommand::Start,
                ProdCommands::Stop => commands::prod::ProdCommand::Stop,
                ProdCommands::Restart => commands::prod::ProdCommand::Restart,
                ProdCommands::Status => commands::prod::ProdCommand::Status,
                ProdCommands::Logs { service, lines } => {
                    commands::prod::ProdCommand::Logs { service, lines }
                }
                ProdCommands::Deploy => commands::prod::ProdCommand::Deploy,
                ProdCommands::Backup => commands::prod::ProdCommand::Backup,
                ProdCommands::Validate => commands::prod::ProdCommand::Validate,
            };
            commands::prod::execute(prod_cmd, force).await
        }
    }
}
