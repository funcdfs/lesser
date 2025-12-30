use std::time::Duration;

use indicatif::{ProgressBar, ProgressStyle};

/// Spinner 封装
pub struct Spinner {
    pb: ProgressBar,
}

impl Spinner {
    /// 创建新的 Spinner
    pub fn new(message: &str) -> Self {
        let pb = ProgressBar::new_spinner();
        pb.set_style(
            ProgressStyle::default_spinner()
                .tick_chars("⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏")
                .template("{spinner:.cyan} {msg}")
                .expect("invalid spinner template"),
        );
        pb.set_message(message.to_string());
        pb.enable_steady_tick(Duration::from_millis(100));
        Self { pb }
    }

    /// 设置消息
    #[allow(dead_code)]
    pub fn set_message(&self, msg: &str) {
        self.pb.set_message(msg.to_string());
    }

    /// 完成并显示消息
    #[allow(dead_code)]
    pub fn finish_with_message(&self, msg: &str) {
        self.pb.finish_with_message(msg.to_string());
    }

    /// 完成并清除
    pub fn finish_and_clear(&self) {
        self.pb.finish_and_clear();
    }
}
