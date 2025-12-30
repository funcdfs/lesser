use indicatif::{MultiProgress, ProgressBar, ProgressStyle};

/// 多进度条管理
#[allow(dead_code)]
pub struct MultiProgressBar {
    mp: MultiProgress,
}

#[allow(dead_code)]
impl MultiProgressBar {
    /// 创建新的多进度条
    pub fn new() -> Self {
        Self {
            mp: MultiProgress::new(),
        }
    }

    /// 添加一个进度条
    pub fn add(&self, total: u64, message: &str) -> ProgressBar {
        let pb = self.mp.add(ProgressBar::new(total));
        pb.set_style(
            ProgressStyle::default_bar()
                .template("{spinner:.green} [{bar:40.cyan/blue}] {pos}/{len} {msg}")
                .expect("invalid progress bar template")
                .progress_chars("#>-"),
        );
        pb.set_message(message.to_string());
        pb
    }

    /// 添加一个 Spinner
    pub fn add_spinner(&self, message: &str) -> ProgressBar {
        let pb = self.mp.add(ProgressBar::new_spinner());
        pb.set_style(
            ProgressStyle::default_spinner()
                .tick_chars("⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏")
                .template("{spinner:.cyan} {msg}")
                .expect("invalid spinner template"),
        );
        pb.set_message(message.to_string());
        pb
    }
}

impl Default for MultiProgressBar {
    fn default() -> Self {
        Self::new()
    }
}
