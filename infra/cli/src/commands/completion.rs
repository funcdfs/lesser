use std::io;

use anyhow::Result;
use clap::CommandFactory;
use clap_complete::{generate, Shell};

use crate::cli::Cli;

pub fn execute(shell: Shell) -> Result<()> {
    let mut cmd = Cli::command();
    generate(shell, &mut cmd, "devlesser", &mut io::stdout());
    Ok(())
}
