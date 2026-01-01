mod cli;
mod commands;
mod config;
mod docker;
mod error;
mod ui;

use anyhow::Result;
use clap::Parser;
use cli::{Cli, Commands};
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
        Commands::Init { force } => commands::init::execute(force).await,
        Commands::Status => commands::status::execute().await,
        Commands::Proto { target } => commands::proto::execute(target).await,
    }
}
