use anyhow::Result;
use dialoguer::{theme::ColorfulTheme, Confirm, Input, Select};

/// 确认提示
pub fn confirm(message: &str, default: bool) -> Result<bool> {
    let result = Confirm::with_theme(&ColorfulTheme::default())
        .with_prompt(message)
        .default(default)
        .interact()?;
    Ok(result)
}

/// 选择提示
#[allow(dead_code)]
pub fn select<T: ToString + std::fmt::Display>(message: &str, items: &[T]) -> Result<usize> {
    let result = Select::with_theme(&ColorfulTheme::default())
        .with_prompt(message)
        .items(items)
        .default(0)
        .interact()?;
    Ok(result)
}

/// 输入提示
#[allow(dead_code)]
pub fn input(message: &str, default: Option<&str>) -> Result<String> {
    let theme = ColorfulTheme::default();
    let mut input = Input::with_theme(&theme).with_prompt(message);
    if let Some(d) = default {
        input = input.default(d.to_string());
    }
    let result = input.interact_text()?;
    Ok(result)
}
