use anyhow::Result;

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

/// Execute mock data generation (setup_test_users)
pub async fn execute() -> Result<()> {
    ui::header("Mock Data Generation");

    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // Check if Django service is running
    let statuses = compose.ps_json().await?;
    let django_running = statuses
        .iter()
        .any(|s| s.service_name() == "django" && s.is_running());

    if !django_running {
        ui::warn("Django service is not running, starting it...");
        let spinner = Spinner::new("Starting Django service...");
        compose.up_wait(&["django"]).await?;
        spinner.finish_and_clear();
        ui::success("Django service started");
    }

    // Execute the mock command
    let spinner = Spinner::new("Generating mock data...");
    spinner.finish_and_clear();

    ui::step("Running python manage.py setup_mock");
    compose
        .exec("django", &["python", "manage.py", "setup_mock"], false)
        .await?;

    ui::success("✨ Mock data generation completed");
    Ok(())
}
