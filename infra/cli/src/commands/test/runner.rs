//! 测试运行器
//!
//! 提供统一的测试执行入口，支持：
//! - 单服务测试 (auth, user, content, etc.)
//! - 数据库分表验证 (db)
//! - 服务联动测试 (integration)
//! - 测试轮次 (round1, round2, round3, full)
//!
//! Requirements: 2.1, 2.2, 2.3, 2.4, 8.1, 8.2, 8.3

use std::time::Instant;

use anyhow::{bail, Result};

use crate::ui;

use super::grpc;
use super::{auth, channel, chat, comment, content, database, gateway, interaction, notification, search, superuser, timeline, user};

/// 测试目标
#[derive(Clone, Debug, PartialEq)]
pub enum TestTarget {
    /// 运行所有测试
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
    /// Channel 服务测试（广播频道）
    Channel,
    /// Gateway 路由测试
    Gateway,
    /// SuperUser 服务测试
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

impl std::fmt::Display for TestTarget {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TestTarget::All => write!(f, "所有服务"),
            TestTarget::Auth => write!(f, "Auth 服务"),
            TestTarget::User => write!(f, "User 服务"),
            TestTarget::Content => write!(f, "Content 服务"),
            TestTarget::Comment => write!(f, "Comment 服务"),
            TestTarget::Interaction => write!(f, "Interaction 服务"),
            TestTarget::Timeline => write!(f, "Timeline 服务"),
            TestTarget::Search => write!(f, "Search 服务"),
            TestTarget::Notification => write!(f, "Notification 服务"),
            TestTarget::Chat => write!(f, "Chat 服务"),
            TestTarget::Channel => write!(f, "Channel 服务"),
            TestTarget::Gateway => write!(f, "Gateway 服务"),
            TestTarget::Superuser => write!(f, "SuperUser 服务"),
            TestTarget::Db => write!(f, "数据库验证"),
            TestTarget::Integration => write!(f, "联动测试"),
            TestTarget::Round1 => write!(f, "第一轮测试"),
            TestTarget::Round2 => write!(f, "第二轮测试"),
            TestTarget::Round3 => write!(f, "第三轮测试"),
            TestTarget::Full => write!(f, "完整三轮测试"),
        }
    }
}

impl std::str::FromStr for TestTarget {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_lowercase().as_str() {
            "all" => Ok(TestTarget::All),
            "auth" => Ok(TestTarget::Auth),
            "user" => Ok(TestTarget::User),
            "content" => Ok(TestTarget::Content),
            "comment" => Ok(TestTarget::Comment),
            "interaction" => Ok(TestTarget::Interaction),
            "timeline" => Ok(TestTarget::Timeline),
            "search" => Ok(TestTarget::Search),
            "notification" => Ok(TestTarget::Notification),
            "chat" => Ok(TestTarget::Chat),
            "channel" => Ok(TestTarget::Channel),
            "gateway" => Ok(TestTarget::Gateway),
            "superuser" | "su" => Ok(TestTarget::Superuser),
            "db" => Ok(TestTarget::Db),
            "integration" => Ok(TestTarget::Integration),
            "round1" => Ok(TestTarget::Round1),
            "round2" => Ok(TestTarget::Round2),
            "round3" => Ok(TestTarget::Round3),
            "full" => Ok(TestTarget::Full),
            _ => Err(format!("无效的测试目标: {}", s)),
        }
    }
}

/// 测试结果统计
/// 
/// 用于跟踪测试执行的统计信息，包括总数、通过数和失败数。
/// Requirements: 8.1, 8.2, 8.3
#[derive(Default, Debug, Clone)]
pub struct TestStats {
    /// 总测试数
    pub total: u32,
    /// 通过测试数
    pub passed: u32,
    /// 失败测试数
    pub failed: u32,
}

impl TestStats {
    /// 创建新的测试统计
    #[allow(dead_code)]
    pub fn new() -> Self {
        Self::default()
    }

    /// 记录测试结果
    /// 
    /// # Arguments
    /// * `success` - 测试是否成功
    /// * `name` - 测试名称
    pub fn record(&mut self, success: bool, name: &str) {
        self.total += 1;
        if success {
            self.passed += 1;
            ui::step_done(name);
        } else {
            self.failed += 1;
            ui::step_fail(name);
        }
    }

    /// 记录测试结果（带函数名）
    /// 
    /// # Arguments
    /// * `success` - 测试是否成功
    /// * `name` - 测试名称
    /// * `func_name` - 调用的函数名（如 gRPC 方法名）
    /// * `file_path` - 测试文件路径（简写形式）
    pub fn record_with_func(&mut self, success: bool, name: &str, func_name: &str, file_path: &str) {
        self.total += 1;
        if success {
            self.passed += 1;
            ui::step_done_with_func(name, func_name, file_path);
        } else {
            self.failed += 1;
            ui::step_fail_with_func(name, func_name, file_path);
        }
    }

    /// 合并另一个统计结果
    pub fn merge(&mut self, other: &TestStats) {
        self.total += other.total;
        self.passed += other.passed;
        self.failed += other.failed;
    }

    /// 打印测试结果汇总
    /// 
    /// Requirements: 8.2
    #[allow(dead_code)]
    pub fn print_summary(&self) {
        println!();
        ui::separator();
        println!();
        println!("测试结果汇总:");
        println!("  总测试数: {}", self.total);
        println!("  通过: {}", self.passed);
        println!("  失败: {}", self.failed);
        println!("  通过率: {:.1}%", self.pass_rate());
        println!();

        if self.failed == 0 {
            ui::success("所有测试通过！");
        } else {
            ui::error(&format!("{} 个测试失败", self.failed));
        }
    }

    /// 打印带时长的测试结果汇总
    /// 
    /// Requirements: 8.2
    pub fn print_summary_with_duration(&self, duration_secs: f64) {
        println!();
        ui::separator();
        println!();
        
        // 根据结果选择边框颜色
        let (border_color, icon) = if self.failed == 0 {
            ("\x1b[32m", "✓")  // 绿色
        } else {
            ("\x1b[31m", "✗")  // 红色
        };
        let reset = "\x1b[0m";
        
        // 格式化数值为字符串
        let duration_str = format!("{:.2}s", duration_secs);
        let pass_rate_str = format!("{:.1}%", self.pass_rate());
        
        println!("  {}┌───────────────────────────────────────┐{}", border_color, reset);
        println!("  {}│{}  {} 测试结果汇总                      {}│{}", border_color, reset, icon, border_color, reset);
        println!("  {}├───────────────────────────────────────┤{}", border_color, reset);
        println!("  {}│{}  ⏱  执行时长  {:<22} {}│{}", border_color, reset, duration_str, border_color, reset);
        println!("  {}│{}  📊 总测试数  {:<22} {}│{}", border_color, reset, self.total, border_color, reset);
        println!("  {}│{}  ✓  通过      {:<22} {}│{}", border_color, reset, self.passed, border_color, reset);
        println!("  {}│{}  ✗  失败      {:<22} {}│{}", border_color, reset, self.failed, border_color, reset);
        println!("  {}│{}  📈 通过率    {:<22} {}│{}", border_color, reset, pass_rate_str, border_color, reset);
        println!("  {}└───────────────────────────────────────┘{}", border_color, reset);
        println!();

        if self.failed == 0 {
            ui::success("所有测试通过！");
        } else {
            ui::error(&format!("{} 个测试失败", self.failed));
        }
    }

    /// 打印详细的服务测试汇总
    /// 
    /// Requirements: 8.2
    #[allow(dead_code)]
    pub fn print_detailed_summary(&self, service_results: &[(String, TestStats)], duration_secs: f64) {
        println!();
        ui::separator();
        println!();
        println!("  ╔═══════════════════════════════════════════════════════════╗");
        println!("  ║                    测试结果详细汇总                        ║");
        println!("  ╠═══════════════════════════════════════════════════════════╣");
        println!("  ║  执行时长: {:<46.2}s ║", duration_secs);
        println!("  ╠═══════════════════════════════════════════════════════════╣");
        println!("  ║  {:<15} {:>8} {:>8} {:>8} {:>10} ║", "服务", "总数", "通过", "失败", "通过率");
        println!("  ╠═══════════════════════════════════════════════════════════╣");

        for (service, stats) in service_results {
            let status = if stats.failed == 0 { "✓" } else { "✗" };
            println!(
                "  ║  {} {:<13} {:>8} {:>8} {:>8} {:>9.1}% ║",
                status,
                service,
                stats.total,
                stats.passed,
                stats.failed,
                stats.pass_rate()
            );
        }

        println!("  ╠═══════════════════════════════════════════════════════════╣");
        println!(
            "  ║  {:<15} {:>8} {:>8} {:>8} {:>9.1}% ║",
            "总计",
            self.total,
            self.passed,
            self.failed,
            self.pass_rate()
        );
        println!("  ╚═══════════════════════════════════════════════════════════╝");
        println!();

        if self.failed == 0 {
            ui::success("🎉 所有测试通过！");
        } else {
            ui::error(&format!("❌ {} 个测试失败", self.failed));
        }
    }

    /// 检查是否全部通过
    pub fn is_success(&self) -> bool {
        self.failed == 0
    }

    /// 获取通过率（百分比）
    pub fn pass_rate(&self) -> f64 {
        if self.total == 0 {
            100.0
        } else {
            (self.passed as f64 / self.total as f64) * 100.0
        }
    }
}

/// 测试进度追踪器
/// 
/// 用于实时显示测试进度，包括当前轮次、服务、测试名称等信息。
/// Requirements: 8.1
#[derive(Debug, Clone)]
pub struct TestProgressTracker {
    /// 当前轮次（1-3，0 表示非轮次测试）
    pub current_round: u8,
    /// 当前服务名称
    pub current_service: String,
    /// 当前测试名称
    pub current_test: String,
    /// 已完成测试数
    pub completed: u32,
    /// 总测试数
    pub total: u32,
    /// 开始时间
    start_time: Instant,
}

impl TestProgressTracker {
    /// 创建新的进度追踪器
    pub fn new(total: u32) -> Self {
        Self {
            current_round: 0,
            current_service: String::new(),
            current_test: String::new(),
            completed: 0,
            total,
            start_time: Instant::now(),
        }
    }

    /// 设置当前轮次
    pub fn set_round(&mut self, round: u8) {
        self.current_round = round;
    }

    /// 设置当前服务
    pub fn set_service(&mut self, service: &str) {
        self.current_service = service.to_string();
    }

    /// 设置当前测试
    pub fn set_test(&mut self, test: &str) {
        self.current_test = test.to_string();
    }

    /// 增加完成计数
    pub fn increment(&mut self) {
        self.completed += 1;
    }

    /// 获取已用时间（秒）
    pub fn elapsed_secs(&self) -> f64 {
        self.start_time.elapsed().as_secs_f64()
    }

    /// 打印当前进度
    /// 
    /// Requirements: 8.1
    #[allow(dead_code)]
    pub fn print_progress(&self) {
        let round_info = if self.current_round > 0 {
            format!("[轮次 {}] ", self.current_round)
        } else {
            String::new()
        };

        let service_info = if !self.current_service.is_empty() {
            format!("[{}] ", self.current_service)
        } else {
            String::new()
        };

        let progress = if self.total > 0 {
            format!(" ({}/{})", self.completed, self.total)
        } else {
            String::new()
        };

        println!(
            "  {}{}{}{}",
            round_info, service_info, self.current_test, progress
        );
    }

    /// 打印进度条
    /// 
    /// Requirements: 8.1
    #[allow(dead_code)]
    pub fn print_progress_bar(&self) {
        if self.total == 0 {
            return;
        }

        let percentage = (self.completed as f64 / self.total as f64 * 100.0) as u32;
        let bar_width = 30;
        let filled = (self.completed as usize * bar_width / self.total as usize).min(bar_width);
        let empty = bar_width - filled;

        let bar = format!(
            "[{}{}] {}% ({}/{})",
            "█".repeat(filled),
            "░".repeat(empty),
            percentage,
            self.completed,
            self.total
        );

        // 使用回车符覆盖当前行
        print!("\r  {}", bar);
        use std::io::Write;
        std::io::stdout().flush().ok();
    }

    /// 完成进度条并换行
    #[allow(dead_code)]
    pub fn finish_progress_bar(&self) {
        println!();
    }

    /// 打印带上下文的进度信息
    /// 
    /// Requirements: 8.1
    #[allow(dead_code)]
    pub fn print_context(&self) {
        let round_str = if self.current_round > 0 {
            format!("轮次 {}", self.current_round)
        } else {
            "单次测试".to_string()
        };

        let elapsed = self.elapsed_secs();
        
        println!("  ┌─────────────────────────────────────────────────────────");
        println!("  │ {} | 服务: {} | 测试: {}", 
            round_str,
            if self.current_service.is_empty() { "-" } else { &self.current_service },
            if self.current_test.is_empty() { "-" } else { &self.current_test }
        );
        println!("  │ 进度: {}/{} | 耗时: {:.1}s", self.completed, self.total, elapsed);
        println!("  └─────────────────────────────────────────────────────────");
    }
}

/// 全局进度追踪器（用于跨函数共享状态）
/// 
/// Requirements: 8.1
pub static PROGRESS_TRACKER: std::sync::OnceLock<std::sync::Mutex<TestProgressTracker>> = std::sync::OnceLock::new();

/// 初始化全局进度追踪器
pub fn init_progress_tracker(total: u32) {
    let _ = PROGRESS_TRACKER.set(std::sync::Mutex::new(TestProgressTracker::new(total)));
}

/// 更新进度追踪器
pub fn update_progress(round: Option<u8>, service: Option<&str>, test: Option<&str>) {
    if let Some(tracker) = PROGRESS_TRACKER.get() {
        if let Ok(mut t) = tracker.lock() {
            if let Some(r) = round {
                t.set_round(r);
            }
            if let Some(s) = service {
                t.set_service(s);
            }
            if let Some(test_name) = test {
                t.set_test(test_name);
            }
        }
    }
}

/// 增加进度计数
pub fn increment_progress() {
    if let Some(tracker) = PROGRESS_TRACKER.get() {
        if let Ok(mut t) = tracker.lock() {
            t.increment();
        }
    }
}

/// 打印当前进度
#[allow(dead_code)]
pub fn print_current_progress() {
    if let Some(tracker) = PROGRESS_TRACKER.get() {
        if let Ok(t) = tracker.lock() {
            t.print_progress();
        }
    }
}

/// 执行测试
/// 
/// 根据指定的测试目标执行相应的测试，并显示进度和结果汇总。
/// 
/// # Arguments
/// * `target` - 测试目标
/// 
/// # Returns
/// * `Ok(())` - 测试全部通过
/// * `Err` - 测试失败或执行错误
/// 
/// Requirements: 2.1, 2.2, 2.3, 2.4, 8.1, 8.2, 8.3
pub async fn execute(target: TestTarget) -> Result<()> {
    let start_time = Instant::now();
    
    ui::header("运行测试");
    ui::info(&format!("测试目标: {}", target));
    println!();

    // 检查 grpcurl 是否安装
    if !grpc::check_grpcurl_installed().await {
        ui::error("grpcurl 未安装");
        ui::hint("安装: brew install grpcurl");
        bail!("grpcurl 未安装");
    }

    // 初始化进度追踪器（估算测试数量）
    let estimated_tests = estimate_test_count(&target);
    init_progress_tracker(estimated_tests);

    let mut stats = TestStats::default();

    match target {
        TestTarget::All => {
            ui::info("运行所有服务测试");
            println!();
            print_test_header("所有服务测试");
            stats = run_all_service_tests().await?;
        }
        TestTarget::Auth => {
            ui::info("运行 Auth 服务测试");
            println!();
            update_progress(None, Some("Auth"), None);
            stats = auth::run_tests().await?;
        }
        TestTarget::User => {
            ui::info("运行 User 服务测试");
            println!();
            update_progress(None, Some("User"), None);
            stats = user::run_tests().await?;
        }
        TestTarget::Content => {
            ui::info("运行 Content 服务测试");
            println!();
            update_progress(None, Some("Content"), None);
            stats = content::run_tests().await?;
        }
        TestTarget::Comment => {
            ui::info("运行 Comment 服务测试");
            println!();
            update_progress(None, Some("Comment"), None);
            stats = comment::run_tests().await?;
        }
        TestTarget::Interaction => {
            ui::info("运行 Interaction 服务测试");
            println!();
            update_progress(None, Some("Interaction"), None);
            stats = interaction::run_tests().await?;
        }
        TestTarget::Timeline => {
            ui::info("运行 Timeline 服务测试");
            println!();
            update_progress(None, Some("Timeline"), None);
            stats = timeline::run_tests().await?;
        }
        TestTarget::Search => {
            ui::info("运行 Search 服务测试");
            println!();
            update_progress(None, Some("Search"), None);
            stats = search::run_tests().await?;
        }
        TestTarget::Notification => {
            ui::info("运行 Notification 服务测试");
            println!();
            update_progress(None, Some("Notification"), None);
            stats = notification::run_tests().await?;
        }
        TestTarget::Chat => {
            ui::info("运行 Chat 服务测试");
            println!();
            update_progress(None, Some("Chat"), None);
            stats = chat::run_tests().await?;
        }
        TestTarget::Channel => {
            ui::info("运行 Channel 服务测试");
            println!();
            update_progress(None, Some("Channel"), None);
            stats = channel::run_tests().await?;
        }
        TestTarget::Gateway => {
            ui::info("运行 Gateway 路由测试");
            println!();
            update_progress(None, Some("Gateway"), None);
            stats = gateway::run_tests().await?;
        }
        TestTarget::Superuser => {
            ui::info("运行 SuperUser 服务测试");
            println!();
            update_progress(None, Some("SuperUser"), None);
            stats = superuser::run_tests().await?;
        }
        TestTarget::Db => {
            ui::info("运行数据库分表验证");
            println!();
            update_progress(None, Some("Database"), Some("表结构验证"));
            stats = database::run_tests().await?;
        }
        TestTarget::Integration => {
            ui::info("运行服务联动测试");
            println!();
            update_progress(None, Some("Integration"), None);
            stats = super::integration::run_integration_tests().await?;
        }
        TestTarget::Round1 => {
            ui::info("运行第一轮测试（初始化）");
            println!();
            update_progress(Some(1), None, None);
            let round_stats = super::rounds::execute_round(super::rounds::TestRound::Round1).await?;
            stats.total = round_stats.total_tests();
            stats.passed = round_stats.passed_tests();
            stats.failed = round_stats.failed_tests();
        }
        TestTarget::Round2 => {
            ui::info("运行第二轮测试（重建）");
            println!();
            update_progress(Some(2), None, None);
            let round_stats = super::rounds::execute_round(super::rounds::TestRound::Round2).await?;
            stats.total = round_stats.total_tests();
            stats.passed = round_stats.passed_tests();
            stats.failed = round_stats.failed_tests();
        }
        TestTarget::Round3 => {
            ui::info("运行第三轮测试（重启）");
            println!();
            update_progress(Some(3), None, None);
            let round_stats = super::rounds::execute_round(super::rounds::TestRound::Round3).await?;
            stats.total = round_stats.total_tests();
            stats.passed = round_stats.passed_tests();
            stats.failed = round_stats.failed_tests();
        }
        TestTarget::Full => {
            ui::info("运行完整三轮测试");
            println!();
            let full_stats = super::rounds::execute_full_test().await?;
            // full_stats 已经打印了汇总，这里只需要检查结果
            if !full_stats.is_success() {
                bail!("测试失败");
            }
            return Ok(());
        }
    }

    let duration = start_time.elapsed().as_secs_f64();
    stats.print_summary_with_duration(duration);

    if !stats.is_success() {
        bail!("测试失败");
    }

    Ok(())
}

/// 估算测试数量
/// 
/// 根据测试目标估算大致的测试数量，用于进度显示
fn estimate_test_count(target: &TestTarget) -> u32 {
    match target {
        TestTarget::All => 100,  // 所有服务约 100 个测试
        TestTarget::Auth => 10,
        TestTarget::User => 15,
        TestTarget::Content => 10,
        TestTarget::Comment => 8,
        TestTarget::Interaction => 8,
        TestTarget::Timeline => 8,
        TestTarget::Search => 5,
        TestTarget::Notification => 5,
        TestTarget::Chat => 12,
        TestTarget::Channel => 11,  // Channel 服务测试
        TestTarget::Gateway => 10,
        TestTarget::Superuser => 10,
        TestTarget::Db => 25,  // 数据库表验证
        TestTarget::Integration => 5,  // 5 个联动测试场景
        TestTarget::Round1 => 140,  // 一轮测试（含 Channel）
        TestTarget::Round2 => 140,
        TestTarget::Round3 => 140,
        TestTarget::Full => 420,  // 三轮测试
    }
}

/// 打印测试头部信息
/// 
/// Requirements: 8.1
fn print_test_header(title: &str) {
    println!("  ╔═══════════════════════════════════════════════════════════╗");
    println!("  ║  {}  ║", format!("{:^55}", title));
    println!("  ╚═══════════════════════════════════════════════════════════╝");
    println!();
}

/// 运行所有服务测试
/// 
/// 按顺序执行所有 12 个服务的测试，并显示实时进度
/// Requirements: 2.1, 8.1
async fn run_all_service_tests() -> Result<TestStats> {
    let mut stats = TestStats::default();
    let services = [
        ("Auth", "auth"),
        ("User", "user"),
        ("Content", "content"),
        ("Comment", "comment"),
        ("Interaction", "interaction"),
        ("Timeline", "timeline"),
        ("Search", "search"),
        ("Notification", "notification"),
        ("Chat", "chat"),
        ("Channel", "channel"),
        ("Gateway", "gateway"),
        ("SuperUser", "superuser"),
    ];

    for (i, (name, _)) in services.iter().enumerate() {
        let step = format!("{}/{}", i + 1, services.len());
        ui::step(&step, &format!("{} Service", name));
        update_progress(None, Some(name), Some("运行测试"));

        let service_stats = match *name {
            "Auth" => auth::run_tests().await?,
            "User" => user::run_tests().await?,
            "Content" => content::run_tests().await?,
            "Comment" => comment::run_tests().await?,
            "Interaction" => interaction::run_tests().await?,
            "Timeline" => timeline::run_tests().await?,
            "Search" => search::run_tests().await?,
            "Notification" => notification::run_tests().await?,
            "Chat" => chat::run_tests().await?,
            "Channel" => channel::run_tests().await?,
            "Gateway" => gateway::run_tests().await?,
            "SuperUser" => superuser::run_tests().await?,
            _ => TestStats::default(),
        };

        // 打印服务测试结果
        print_service_result(name, &service_stats);
        stats.merge(&service_stats);
        increment_progress();
    }

    Ok(stats)
}

/// 打印服务测试结果
/// 
/// Requirements: 8.1
fn print_service_result(service: &str, stats: &TestStats) {
    let status = if stats.failed == 0 { "✓" } else { "✗" };
    let color_status = if stats.failed == 0 {
        format!("\x1b[32m{}\x1b[0m", status)  // 绿色
    } else {
        format!("\x1b[31m{}\x1b[0m", status)  // 红色
    };
    
    println!(
        "    {} {} - {}/{} 通过",
        color_status, service, stats.passed, stats.total
    );
}

// ============================================================================
// 单元测试
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_test_target_from_str() {
        assert_eq!("all".parse::<TestTarget>().unwrap(), TestTarget::All);
        assert_eq!("auth".parse::<TestTarget>().unwrap(), TestTarget::Auth);
        assert_eq!("channel".parse::<TestTarget>().unwrap(), TestTarget::Channel);
        assert_eq!("db".parse::<TestTarget>().unwrap(), TestTarget::Db);
        assert_eq!("integration".parse::<TestTarget>().unwrap(), TestTarget::Integration);
        assert_eq!("round1".parse::<TestTarget>().unwrap(), TestTarget::Round1);
        assert_eq!("round2".parse::<TestTarget>().unwrap(), TestTarget::Round2);
        assert_eq!("round3".parse::<TestTarget>().unwrap(), TestTarget::Round3);
        assert_eq!("full".parse::<TestTarget>().unwrap(), TestTarget::Full);
        assert_eq!("superuser".parse::<TestTarget>().unwrap(), TestTarget::Superuser);
        assert_eq!("su".parse::<TestTarget>().unwrap(), TestTarget::Superuser);
        assert!("invalid".parse::<TestTarget>().is_err());
    }

    #[test]
    fn test_test_target_display() {
        assert_eq!(format!("{}", TestTarget::All), "所有服务");
        assert_eq!(format!("{}", TestTarget::Channel), "Channel 服务");
        assert_eq!(format!("{}", TestTarget::Db), "数据库验证");
        assert_eq!(format!("{}", TestTarget::Integration), "联动测试");
        assert_eq!(format!("{}", TestTarget::Round1), "第一轮测试");
        assert_eq!(format!("{}", TestTarget::Full), "完整三轮测试");
    }

    #[test]
    fn test_test_stats_new() {
        let stats = TestStats::new();
        assert_eq!(stats.total, 0);
        assert_eq!(stats.passed, 0);
        assert_eq!(stats.failed, 0);
        assert!(stats.is_success());
    }

    #[test]
    fn test_test_stats_merge() {
        let mut stats1 = TestStats {
            total: 5,
            passed: 4,
            failed: 1,
        };
        let stats2 = TestStats {
            total: 3,
            passed: 2,
            failed: 1,
        };

        stats1.merge(&stats2);

        assert_eq!(stats1.total, 8);
        assert_eq!(stats1.passed, 6);
        assert_eq!(stats1.failed, 2);
    }

    #[test]
    fn test_test_stats_is_success() {
        let success_stats = TestStats {
            total: 10,
            passed: 10,
            failed: 0,
        };
        assert!(success_stats.is_success());

        let failed_stats = TestStats {
            total: 10,
            passed: 9,
            failed: 1,
        };
        assert!(!failed_stats.is_success());
    }

    #[test]
    fn test_test_stats_pass_rate() {
        let stats = TestStats {
            total: 10,
            passed: 8,
            failed: 2,
        };
        assert!((stats.pass_rate() - 80.0).abs() < 0.001);

        let empty_stats = TestStats::default();
        assert!((empty_stats.pass_rate() - 100.0).abs() < 0.001);
    }

    #[test]
    fn test_progress_tracker_new() {
        let tracker = TestProgressTracker::new(100);
        assert_eq!(tracker.current_round, 0);
        assert!(tracker.current_service.is_empty());
        assert!(tracker.current_test.is_empty());
        assert_eq!(tracker.completed, 0);
        assert_eq!(tracker.total, 100);
    }

    #[test]
    fn test_progress_tracker_set_round() {
        let mut tracker = TestProgressTracker::new(100);
        tracker.set_round(1);
        assert_eq!(tracker.current_round, 1);
    }

    #[test]
    fn test_progress_tracker_set_service() {
        let mut tracker = TestProgressTracker::new(100);
        tracker.set_service("Auth");
        assert_eq!(tracker.current_service, "Auth");
    }

    #[test]
    fn test_progress_tracker_increment() {
        let mut tracker = TestProgressTracker::new(100);
        tracker.increment();
        assert_eq!(tracker.completed, 1);
        tracker.increment();
        assert_eq!(tracker.completed, 2);
    }
}


// ============================================================================
// 属性测试 (Property-Based Testing)
// ============================================================================

#[cfg(test)]
mod property_tests {
    use super::*;
    use proptest::prelude::*;

    // 生成随机测试目标
    fn arbitrary_test_target() -> impl Strategy<Value = TestTarget> {
        prop_oneof![
            Just(TestTarget::All),
            Just(TestTarget::Auth),
            Just(TestTarget::User),
            Just(TestTarget::Content),
            Just(TestTarget::Comment),
            Just(TestTarget::Interaction),
            Just(TestTarget::Timeline),
            Just(TestTarget::Search),
            Just(TestTarget::Notification),
            Just(TestTarget::Chat),
            Just(TestTarget::Channel),
            Just(TestTarget::Gateway),
            Just(TestTarget::Superuser),
            Just(TestTarget::Db),
            Just(TestTarget::Integration),
            Just(TestTarget::Round1),
            Just(TestTarget::Round2),
            Just(TestTarget::Round3),
            Just(TestTarget::Full),
        ]
    }

    proptest! {
        #![proptest_config(ProptestConfig::with_cases(100))]

        /// Property 6: Test Result Consistency
        /// 验证测试统计的一致性：总数 = 通过数 + 失败数
        /// **Feature: cli-service-testing, Property 6: Test Result Consistency**
        /// **Validates: Requirements 8.1-8.5**
        #[test]
        fn prop_test_stats_consistency(
            passed in 0u32..1000,
            failed in 0u32..1000,
        ) {
            let stats = TestStats {
                total: passed + failed,
                passed,
                failed,
            };

            // 属性 1: 总数应该等于通过数 + 失败数
            prop_assert_eq!(stats.total, stats.passed + stats.failed);

            // 属性 2: is_success 应该在没有失败时返回 true
            prop_assert_eq!(stats.is_success(), stats.failed == 0);

            // 属性 3: 通过率应该在 0-100 之间
            let pass_rate = stats.pass_rate();
            prop_assert!(pass_rate >= 0.0 && pass_rate <= 100.0);

            // 属性 4: 如果全部通过，通过率应该是 100%
            if stats.total > 0 && stats.failed == 0 {
                prop_assert!((pass_rate - 100.0).abs() < 0.001);
            }

            // 属性 5: 如果全部失败，通过率应该是 0%
            if stats.total > 0 && stats.passed == 0 {
                prop_assert!(pass_rate.abs() < 0.001);
            }
        }

        /// Property 6 扩展: 验证 merge 操作的正确性
        /// **Feature: cli-service-testing, Property 6: Test Result Consistency**
        /// **Validates: Requirements 8.2, 8.3**
        #[test]
        fn prop_test_stats_merge_consistency(
            passed1 in 0u32..500,
            failed1 in 0u32..500,
            passed2 in 0u32..500,
            failed2 in 0u32..500,
        ) {
            let mut stats1 = TestStats {
                total: passed1 + failed1,
                passed: passed1,
                failed: failed1,
            };
            let stats2 = TestStats {
                total: passed2 + failed2,
                passed: passed2,
                failed: failed2,
            };

            let original_total = stats1.total;
            let original_passed = stats1.passed;
            let original_failed = stats1.failed;

            stats1.merge(&stats2);

            // 属性 1: 合并后总数应该是两者之和
            prop_assert_eq!(stats1.total, original_total + stats2.total);

            // 属性 2: 合并后通过数应该是两者之和
            prop_assert_eq!(stats1.passed, original_passed + stats2.passed);

            // 属性 3: 合并后失败数应该是两者之和
            prop_assert_eq!(stats1.failed, original_failed + stats2.failed);

            // 属性 4: 合并后仍然满足 total = passed + failed
            prop_assert_eq!(stats1.total, stats1.passed + stats1.failed);
        }

        /// Property 6 扩展: 验证 TestTarget 的 Display 和 FromStr 一致性
        /// **Feature: cli-service-testing, Property 6: Test Result Consistency**
        /// **Validates: Requirements 2.1-2.4**
        #[test]
        fn prop_test_target_display_not_empty(
            target in arbitrary_test_target(),
        ) {
            let display = format!("{}", target);

            // 属性 1: 显示字符串不应该为空
            prop_assert!(!display.is_empty());

            // 属性 2: 显示字符串应该是中文描述
            // 所有目标都应该有有意义的中文描述
            let has_chinese = display.chars().any(|c| c > '\u{4E00}' && c < '\u{9FFF}');
            let has_alpha = display.chars().any(|c| c.is_alphabetic());
            prop_assert!(has_chinese || has_alpha, "显示字符串应包含中文或字母");
        }

        /// Property 6 扩展: 验证 TestTarget 的 FromStr 解析
        /// **Feature: cli-service-testing, Property 6: Test Result Consistency**
        /// **Validates: Requirements 2.1-2.4**
        #[test]
        fn prop_test_target_from_str_valid(
            target_str in prop_oneof![
                Just("all"),
                Just("auth"),
                Just("user"),
                Just("content"),
                Just("comment"),
                Just("interaction"),
                Just("timeline"),
                Just("search"),
                Just("notification"),
                Just("chat"),
                Just("gateway"),
                Just("superuser"),
                Just("su"),
                Just("db"),
                Just("integration"),
                Just("round1"),
                Just("round2"),
                Just("round3"),
                Just("full"),
            ],
        ) {
            // 属性: 所有有效的目标字符串都应该能成功解析
            let result = target_str.parse::<TestTarget>();
            prop_assert!(result.is_ok(), "解析 '{}' 失败", target_str);
        }

        /// Property 6 扩展: 验证 TestProgressTracker 的状态一致性
        /// **Feature: cli-service-testing, Property 6: Test Result Consistency**
        /// **Validates: Requirements 8.1**
        #[test]
        fn prop_progress_tracker_consistency(
            total in 0u32..1000,
            round in 0u8..4,
            service in "[A-Za-z]{3,20}",
            test_name in "[a-z_]{5,30}",
            increments in 0u32..100,
        ) {
            let mut tracker = TestProgressTracker::new(total);

            // 设置状态
            tracker.set_round(round);
            tracker.set_service(&service);
            tracker.set_test(&test_name);

            // 属性 1: 轮次应该保持设置的值
            prop_assert_eq!(tracker.current_round, round);

            // 属性 2: 服务名应该保持设置的值
            prop_assert_eq!(&tracker.current_service, &service);

            // 属性 3: 测试名应该保持设置的值
            prop_assert_eq!(&tracker.current_test, &test_name);

            // 属性 4: 总数应该保持初始值
            prop_assert_eq!(tracker.total, total);

            // 执行增量操作
            for _ in 0..increments {
                tracker.increment();
            }

            // 属性 5: 完成数应该等于增量次数
            prop_assert_eq!(tracker.completed, increments);

            // 属性 6: 已用时间应该是非负数
            prop_assert!(tracker.elapsed_secs() >= 0.0);
        }

        /// Property 6 扩展: 验证空统计的边界情况
        /// **Feature: cli-service-testing, Property 6: Test Result Consistency**
        /// **Validates: Requirements 8.1-8.5**
        #[test]
        fn prop_empty_stats_behavior(
            _dummy in any::<u8>(),
        ) {
            let stats = TestStats::default();

            // 属性 1: 默认统计应该全为 0
            prop_assert_eq!(stats.total, 0);
            prop_assert_eq!(stats.passed, 0);
            prop_assert_eq!(stats.failed, 0);

            // 属性 2: 空统计应该被认为是成功的
            prop_assert!(stats.is_success());

            // 属性 3: 空统计的通过率应该是 100%
            prop_assert!((stats.pass_rate() - 100.0).abs() < 0.001);
        }

        /// Property 6 扩展: 验证多次 merge 的结合律
        /// **Feature: cli-service-testing, Property 6: Test Result Consistency**
        /// **Validates: Requirements 8.2, 8.3**
        #[test]
        fn prop_merge_associativity(
            p1 in 0u32..100, f1 in 0u32..100,
            p2 in 0u32..100, f2 in 0u32..100,
            p3 in 0u32..100, f3 in 0u32..100,
        ) {
            // 创建三个统计
            let stats1 = TestStats { total: p1 + f1, passed: p1, failed: f1 };
            let stats2 = TestStats { total: p2 + f2, passed: p2, failed: f2 };
            let stats3 = TestStats { total: p3 + f3, passed: p3, failed: f3 };

            // 方式 1: (stats1 + stats2) + stats3
            let mut result1 = stats1.clone();
            result1.merge(&stats2);
            result1.merge(&stats3);

            // 方式 2: stats1 + (stats2 + stats3)
            let mut temp = stats2.clone();
            temp.merge(&stats3);
            let mut result2 = stats1.clone();
            result2.merge(&temp);

            // 属性: 两种合并方式应该得到相同的结果
            prop_assert_eq!(result1.total, result2.total);
            prop_assert_eq!(result1.passed, result2.passed);
            prop_assert_eq!(result1.failed, result2.failed);
        }
    }
}
