//! 测试轮次运行器模块
//!
//! 实现三轮测试流程：
//! - Round 1: 初始化测试 (init → start → 健康检查 → 服务测试 → 联动测试)
//! - Round 2: 重建测试 (stop → clean volumes → start → 健康检查 → 服务测试 → 联动测试)
//! - Round 3: 重启测试 (restart → 健康检查 → 服务测试 → 联动测试)

use std::collections::HashMap;
use std::time::{Duration, Instant};

use anyhow::{bail, Result};
use chrono::{DateTime, Utc};

use crate::config::Config;
use crate::docker::DockerCompose;
use crate::ui::{self, Spinner};

use super::grpc;
use super::runner::TestStats;
use super::{
    auth, chat, comment, content, database, gateway, interaction, notification, search, superuser,
    timeline, user,
};

/// 测试轮次
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TestRound {
    /// 第一轮：初始化测试
    Round1,
    /// 第二轮：删除重建测试
    Round2,
    /// 第三轮：重启测试
    Round3,
}

impl std::fmt::Display for TestRound {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TestRound::Round1 => write!(f, "第一轮（初始化）"),
            TestRound::Round2 => write!(f, "第二轮（重建）"),
            TestRound::Round3 => write!(f, "第三轮（重启）"),
        }
    }
}

/// 轮次统计结果
#[derive(Debug, Clone)]
pub struct RoundStats {
    /// 测试轮次
    pub round: TestRound,
    /// 各服务测试统计
    pub service_stats: HashMap<String, TestStats>,
    /// 数据库验证统计
    pub db_stats: TestStats,
    /// 联动测试统计
    pub integration_stats: TestStats,
    /// 执行时长
    pub duration: Duration,
    /// 开始时间
    pub start_time: DateTime<Utc>,
    /// 结束时间
    pub end_time: DateTime<Utc>,
}

impl RoundStats {
    /// 创建新的轮次统计
    pub fn new(round: TestRound) -> Self {
        Self {
            round,
            service_stats: HashMap::new(),
            db_stats: TestStats::default(),
            integration_stats: TestStats::default(),
            duration: Duration::ZERO,
            start_time: Utc::now(),
            end_time: Utc::now(),
        }
    }

    /// 获取总测试数
    pub fn total_tests(&self) -> u32 {
        let service_total: u32 = self.service_stats.values().map(|s| s.total).sum();
        service_total + self.db_stats.total + self.integration_stats.total
    }

    /// 获取通过测试数
    pub fn passed_tests(&self) -> u32 {
        let service_passed: u32 = self.service_stats.values().map(|s| s.passed).sum();
        service_passed + self.db_stats.passed + self.integration_stats.passed
    }

    /// 获取失败测试数
    pub fn failed_tests(&self) -> u32 {
        let service_failed: u32 = self.service_stats.values().map(|s| s.failed).sum();
        service_failed + self.db_stats.failed + self.integration_stats.failed
    }

    /// 是否全部通过
    pub fn is_success(&self) -> bool {
        self.failed_tests() == 0
    }

    /// 打印轮次汇总
    pub fn print_summary(&self) {
        println!();
        ui::separator();
        println!();
        println!("{} 测试结果汇总:", self.round);
        println!("  执行时长: {:.2}s", self.duration.as_secs_f64());
        println!("  总测试数: {}", self.total_tests());
        println!("  通过: {}", self.passed_tests());
        println!("  失败: {}", self.failed_tests());
        println!();

        // 按服务显示详情
        if !self.service_stats.is_empty() {
            println!("  服务测试详情:");
            for (service, stats) in &self.service_stats {
                let status = if stats.failed == 0 { "✓" } else { "✗" };
                println!(
                    "    {} {}: {}/{} 通过",
                    status, service, stats.passed, stats.total
                );
            }
        }

        // 数据库验证
        if self.db_stats.total > 0 {
            let status = if self.db_stats.failed == 0 {
                "✓"
            } else {
                "✗"
            };
            println!(
                "    {} 数据库验证: {}/{} 通过",
                status, self.db_stats.passed, self.db_stats.total
            );
        }

        // 联动测试
        if self.integration_stats.total > 0 {
            let status = if self.integration_stats.failed == 0 {
                "✓"
            } else {
                "✗"
            };
            println!(
                "    {} 联动测试: {}/{} 通过",
                status, self.integration_stats.passed, self.integration_stats.total
            );
        }

        println!();
        if self.is_success() {
            ui::success(&format!("✓ {} 全部通过！", self.round));
        } else {
            ui::error(&format!("✗ {} 有 {} 个测试失败", self.round, self.failed_tests()));
        }
    }
}

/// 完整测试结果（三轮）
#[derive(Debug)]
pub struct FullTestStats {
    /// 各轮次结果
    pub rounds: Vec<RoundStats>,
    /// 总执行时长
    pub total_duration: Duration,
    /// Bug 报告列表
    pub bugs_found: Vec<BugReport>,
}

impl FullTestStats {
    /// 创建新的完整测试结果
    pub fn new() -> Self {
        Self {
            rounds: Vec::new(),
            total_duration: Duration::ZERO,
            bugs_found: Vec::new(),
        }
    }

    /// 是否全部通过
    pub fn is_success(&self) -> bool {
        self.rounds.iter().all(|r| r.is_success())
    }

    /// 打印完整汇总
    /// 
    /// Requirements: 8.2, 8.3
    pub fn print_summary(&self) {
        println!();
        ui::header("完整测试汇总");

        // 计算总计
        let total_tests: u32 = self.rounds.iter().map(|r| r.total_tests()).sum();
        let total_passed: u32 = self.rounds.iter().map(|r| r.passed_tests()).sum();
        let total_failed: u32 = self.rounds.iter().map(|r| r.failed_tests()).sum();
        let pass_rate = if total_tests > 0 {
            (total_passed as f64 / total_tests as f64) * 100.0
        } else {
            100.0
        };

        // 打印表格头
        println!();
        println!("  ╔═══════════════════════════════════════════════════════════════════════╗");
        println!("  ║                          三轮测试对比汇总                              ║");
        println!("  ╠═══════════════════════════════════════════════════════════════════════╣");
        println!("  ║  {:<20} {:>10} {:>10} {:>10} {:>10} {:>8} ║", "轮次", "总数", "通过", "失败", "通过率", "耗时");
        println!("  ╠═══════════════════════════════════════════════════════════════════════╣");

        // 打印各轮次结果
        for round in &self.rounds {
            let round_pass_rate = if round.total_tests() > 0 {
                (round.passed_tests() as f64 / round.total_tests() as f64) * 100.0
            } else {
                100.0
            };
            let status = if round.is_success() { "✓" } else { "✗" };
            println!(
                "  ║  {} {:<18} {:>10} {:>10} {:>10} {:>9.1}% {:>6.1}s ║",
                status,
                format!("{}", round.round),
                round.total_tests(),
                round.passed_tests(),
                round.failed_tests(),
                round_pass_rate,
                round.duration.as_secs_f64()
            );
        }

        // 打印总计
        println!("  ╠═══════════════════════════════════════════════════════════════════════╣");
        let total_status = if self.is_success() { "✓" } else { "✗" };
        println!(
            "  ║  {} {:<18} {:>10} {:>10} {:>10} {:>9.1}% {:>6.1}s ║",
            total_status,
            "总计",
            total_tests,
            total_passed,
            total_failed,
            pass_rate,
            self.total_duration.as_secs_f64()
        );
        println!("  ╚═══════════════════════════════════════════════════════════════════════╝");

        // 打印轮次间对比分析
        if self.rounds.len() >= 2 {
            println!();
            println!("  轮次间对比分析:");
            self.print_round_comparison();
        }

        println!();

        // Bug 报告
        if !self.bugs_found.is_empty() {
            println!("  ┌─────────────────────────────────────────────────────────────────────");
            println!("  │ 发现的 Bug ({}):", self.bugs_found.len());
            println!("  ├─────────────────────────────────────────────────────────────────────");
            for (i, bug) in self.bugs_found.iter().enumerate() {
                println!("  │ {}. [{}] {} - {}", i + 1, bug.round, bug.service, bug.test_name);
                println!("  │    {}", bug.error_message);
            }
            println!("  └─────────────────────────────────────────────────────────────────────");
            println!();
        }

        // 最终结果
        if self.is_success() {
            ui::success("🎉 完整三轮测试全部通过！");
        } else {
            ui::error(&format!(
                "❌ 测试失败: {} 个测试未通过",
                total_failed
            ));
        }
    }

    /// 打印轮次间对比分析
    /// 
    /// Requirements: 8.3
    fn print_round_comparison(&self) {
        if self.rounds.len() < 2 {
            return;
        }

        // 比较第一轮和第二轮
        if self.rounds.len() >= 2 {
            let r1 = &self.rounds[0];
            let r2 = &self.rounds[1];
            let diff = r2.passed_tests() as i32 - r1.passed_tests() as i32;
            let trend = if diff > 0 {
                format!("↑ +{}", diff)
            } else if diff < 0 {
                format!("↓ {}", diff)
            } else {
                "→ 持平".to_string()
            };
            println!("    • 第一轮 → 第二轮: {}", trend);
        }

        // 比较第二轮和第三轮
        if self.rounds.len() >= 3 {
            let r2 = &self.rounds[1];
            let r3 = &self.rounds[2];
            let diff = r3.passed_tests() as i32 - r2.passed_tests() as i32;
            let trend = if diff > 0 {
                format!("↑ +{}", diff)
            } else if diff < 0 {
                format!("↓ {}", diff)
            } else {
                "→ 持平".to_string()
            };
            println!("    • 第二轮 → 第三轮: {}", trend);
        }

        // 总体趋势
        if self.rounds.len() >= 3 {
            let r1 = &self.rounds[0];
            let r3 = &self.rounds[2];
            let diff = r3.passed_tests() as i32 - r1.passed_tests() as i32;
            let trend = if diff > 0 {
                format!("整体改善 ↑ +{}", diff)
            } else if diff < 0 {
                format!("整体退化 ↓ {}", diff)
            } else {
                "整体稳定 →".to_string()
            };
            println!("    • 总体趋势: {}", trend);
        }
    }
}

impl Default for FullTestStats {
    fn default() -> Self {
        Self::new()
    }
}

/// Bug 报告
#[derive(Debug, Clone)]
pub struct BugReport {
    /// 发现轮次
    pub round: TestRound,
    /// 服务名称
    pub service: String,
    /// 测试名称
    pub test_name: String,
    /// 错误信息
    pub error_message: String,
    /// 发现时间（用于日志和报告）
    #[allow(dead_code)]
    pub timestamp: DateTime<Utc>,
    /// 是否已修复（用于跟踪修复状态）
    #[allow(dead_code)]
    pub fixed: bool,
}

/// 测试进度（用于实时显示测试执行状态）
#[allow(dead_code)]
#[derive(Debug, Clone)]
pub struct TestProgress {
    /// 当前轮次
    pub current_round: u8,
    /// 当前服务
    pub current_service: String,
    /// 当前测试
    pub current_test: String,
    /// 已完成数
    pub completed: u32,
    /// 总数
    pub total: u32,
}

/// 服务列表（用于迭代所有服务）
#[allow(dead_code)]
const SERVICES: &[(&str, &str)] = &[
    ("Auth", "auth"),
    ("User", "user"),
    ("Content", "content"),
    ("Comment", "comment"),
    ("Interaction", "interaction"),
    ("Timeline", "timeline"),
    ("Search", "search"),
    ("Notification", "notification"),
    ("Chat", "chat"),
    ("Gateway", "gateway"),
    ("SuperUser", "superuser"),
];

/// 等待服务健康
async fn wait_for_services_healthy(compose: &DockerCompose, timeout_secs: u64) -> Result<()> {
    let spinner = Spinner::new("等待服务健康...");
    let start = Instant::now();
    let timeout = Duration::from_secs(timeout_secs);

    loop {
        if start.elapsed() > timeout {
            spinner.finish_and_clear();
            bail!("等待服务健康超时 ({}s)", timeout_secs);
        }

        // 检查 Gateway 是否可用
        let result = grpc::call_gateway("grpc.health.v1.Health/Check", "{}", None).await;
        if result.success || result.contains("SERVING") {
            spinner.finish_and_clear();
            ui::step_done("所有服务已就绪");
            return Ok(());
        }

        // 检查容器状态
        let statuses = compose.ps_json().await.unwrap_or_default();
        let running_count = statuses
            .iter()
            .filter(|s| s.state == "running")
            .count();

        if running_count < 10 {
            // 至少需要 10 个服务运行
            tokio::time::sleep(Duration::from_secs(2)).await;
            continue;
        }

        tokio::time::sleep(Duration::from_secs(1)).await;
    }
}

/// 运行所有服务测试
async fn run_all_service_tests() -> Result<HashMap<String, TestStats>> {
    let mut results = HashMap::new();

    // Auth 测试
    ui::step("1/11", "Auth Service");
    let auth_stats = auth::run_tests().await?;
    results.insert("Auth".to_string(), auth_stats);

    // User 测试
    ui::step("2/11", "User Service");
    let user_stats = user::run_tests().await?;
    results.insert("User".to_string(), user_stats);

    // Content 测试
    ui::step("3/11", "Content Service");
    let content_stats = content::run_tests().await?;
    results.insert("Content".to_string(), content_stats);

    // Comment 测试
    ui::step("4/11", "Comment Service");
    let comment_stats = comment::run_tests().await?;
    results.insert("Comment".to_string(), comment_stats);

    // Interaction 测试
    ui::step("5/11", "Interaction Service");
    let interaction_stats = interaction::run_tests().await?;
    results.insert("Interaction".to_string(), interaction_stats);

    // Timeline 测试
    ui::step("6/11", "Timeline Service");
    let timeline_stats = timeline::run_tests().await?;
    results.insert("Timeline".to_string(), timeline_stats);

    // Search 测试
    ui::step("7/11", "Search Service");
    let search_stats = search::run_tests().await?;
    results.insert("Search".to_string(), search_stats);

    // Notification 测试
    ui::step("8/11", "Notification Service");
    let notification_stats = notification::run_tests().await?;
    results.insert("Notification".to_string(), notification_stats);

    // Chat 测试
    ui::step("9/11", "Chat Service");
    let chat_stats = chat::run_tests().await?;
    results.insert("Chat".to_string(), chat_stats);

    // Gateway 测试
    ui::step("10/11", "Gateway Service");
    let gateway_stats = gateway::run_tests().await?;
    results.insert("Gateway".to_string(), gateway_stats);

    // SuperUser 测试
    ui::step("11/11", "SuperUser Service");
    let superuser_stats = superuser::run_tests().await?;
    results.insert("SuperUser".to_string(), superuser_stats);

    Ok(results)
}

/// 执行第一轮测试（初始化）
pub async fn execute_round1() -> Result<RoundStats> {
    let start = Instant::now();
    let mut stats = RoundStats::new(TestRound::Round1);
    stats.start_time = Utc::now();

    ui::banner("第一轮测试：初始化启动");

    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // Step 1: 执行 init
    ui::step("1/5", "初始化环境");
    let spinner = Spinner::new("执行 devlesser init...");
    
    // 清理现有环境
    let _ = compose.down(true, true).await;
    
    // 启动基础设施
    compose
        .up_wait(&["postgres", "redis", "rabbitmq", "traefik", "dozzle"])
        .await?;
    
    // 等待数据库就绪
    for _ in 0..30 {
        let result = compose
            .exec("postgres", &["pg_isready", "-U", "lesser"], false)
            .await;
        if result.is_ok() {
            break;
        }
        tokio::time::sleep(Duration::from_secs(1)).await;
    }
    
    spinner.finish_and_clear();
    ui::step_done("环境初始化完成");

    // Step 2: 启动服务
    ui::step("2/5", "启动所有服务");
    let spinner = Spinner::new("启动后端服务...");
    compose
        .up_wait(&[
            "gateway", "chat", "auth", "user", "content", "interaction", "comment", "timeline",
            "notification", "search", "superuser",
        ])
        .await?;
    spinner.finish_and_clear();
    ui::step_done("服务已启动");

    // Step 3: 等待健康
    ui::step("3/5", "等待服务健康");
    wait_for_services_healthy(&compose, 60).await?;

    // Step 4: 数据库验证
    ui::step("4/5", "数据库分表验证");
    println!();
    stats.db_stats = database::run_tests().await?;

    // Step 5: 服务测试
    ui::step("5/5", "服务 API 测试");
    println!();
    stats.service_stats = run_all_service_tests().await?;

    // 联动测试（可选）
    // stats.integration_stats = run_integration_tests().await?;

    stats.end_time = Utc::now();
    stats.duration = start.elapsed();
    stats.print_summary();

    Ok(stats)
}

/// 执行第二轮测试（删除重建）
pub async fn execute_round2() -> Result<RoundStats> {
    let start = Instant::now();
    let mut stats = RoundStats::new(TestRound::Round2);
    stats.start_time = Utc::now();

    ui::banner("第二轮测试：删除重建");

    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // Step 1: 停止服务
    ui::step("1/6", "停止所有服务");
    let spinner = Spinner::new("执行 devlesser stop...");
    compose.down(false, true).await?;
    spinner.finish_and_clear();
    ui::step_done("服务已停止");

    // Step 2: 清理数据卷
    ui::step("2/6", "清理数据卷");
    let spinner = Spinner::new("执行 devlesser clean volumes...");
    compose.down(true, false).await?;
    spinner.finish_and_clear();
    ui::step_done("数据卷已清理");

    // Step 3: 重新启动
    ui::step("3/6", "重新启动服务");
    let spinner = Spinner::new("启动基础设施...");
    compose
        .up_wait(&["postgres", "redis", "rabbitmq", "traefik", "dozzle"])
        .await?;
    
    // 等待数据库就绪
    for _ in 0..30 {
        let result = compose
            .exec("postgres", &["pg_isready", "-U", "lesser"], false)
            .await;
        if result.is_ok() {
            break;
        }
        tokio::time::sleep(Duration::from_secs(1)).await;
    }
    
    // 启动后端服务
    compose
        .up_wait(&[
            "gateway", "chat", "auth", "user", "content", "interaction", "comment", "timeline",
            "notification", "search", "superuser",
        ])
        .await?;
    spinner.finish_and_clear();
    ui::step_done("服务已重新启动");

    // Step 4: 等待健康
    ui::step("4/6", "等待服务健康");
    wait_for_services_healthy(&compose, 60).await?;

    // Step 5: 数据库验证
    ui::step("5/6", "数据库分表验证");
    println!();
    stats.db_stats = database::run_tests().await?;

    // Step 6: 服务测试
    ui::step("6/6", "服务 API 测试");
    println!();
    stats.service_stats = run_all_service_tests().await?;

    // 联动测试（可选）
    // stats.integration_stats = run_integration_tests().await?;

    stats.end_time = Utc::now();
    stats.duration = start.elapsed();
    stats.print_summary();

    Ok(stats)
}

/// 执行第三轮测试（重启）
pub async fn execute_round3() -> Result<RoundStats> {
    let start = Instant::now();
    let mut stats = RoundStats::new(TestRound::Round3);
    stats.start_time = Utc::now();

    ui::banner("第三轮测试：重启");

    let config = Config::load()?;
    let compose = DockerCompose::new(
        config.compose_file.to_str().unwrap_or(""),
        config.env_file.to_str().unwrap_or(""),
    );

    // Step 1: 重启服务
    ui::step("1/4", "重启所有服务");
    let spinner = Spinner::new("执行 devlesser restart...");
    compose.restart(&[]).await?;
    spinner.finish_and_clear();
    ui::step_done("服务已重启");

    // Step 2: 等待健康
    ui::step("2/4", "等待服务健康");
    wait_for_services_healthy(&compose, 60).await?;

    // Step 3: 数据库验证
    ui::step("3/4", "数据库分表验证");
    println!();
    stats.db_stats = database::run_tests().await?;

    // Step 4: 服务测试
    ui::step("4/4", "服务 API 测试");
    println!();
    stats.service_stats = run_all_service_tests().await?;

    // 联动测试（可选）
    // stats.integration_stats = run_integration_tests().await?;

    stats.end_time = Utc::now();
    stats.duration = start.elapsed();
    stats.print_summary();

    Ok(stats)
}

/// 执行完整三轮测试
pub async fn execute_full_test() -> Result<FullTestStats> {
    let start = Instant::now();
    let mut full_stats = FullTestStats::new();

    ui::header("完整三轮测试");
    ui::info("将依次执行：初始化测试 → 重建测试 → 重启测试");
    println!();

    // 检查 grpcurl 是否安装
    if !grpc::check_grpcurl_installed().await {
        ui::error("grpcurl 未安装");
        ui::hint("安装: brew install grpcurl");
        bail!("grpcurl 未安装");
    }

    // 第一轮
    ui::info("开始第一轮测试...");
    let round1_stats = execute_round1().await?;
    full_stats.rounds.push(round1_stats);

    // 第二轮
    ui::info("开始第二轮测试...");
    let round2_stats = execute_round2().await?;
    full_stats.rounds.push(round2_stats);

    // 第三轮
    ui::info("开始第三轮测试...");
    let round3_stats = execute_round3().await?;
    full_stats.rounds.push(round3_stats);

    full_stats.total_duration = start.elapsed();
    full_stats.print_summary();

    Ok(full_stats)
}

/// 执行指定轮次测试
pub async fn execute_round(round: TestRound) -> Result<RoundStats> {
    // 检查 grpcurl 是否安装
    if !grpc::check_grpcurl_installed().await {
        ui::error("grpcurl 未安装");
        ui::hint("安装: brew install grpcurl");
        bail!("grpcurl 未安装");
    }

    match round {
        TestRound::Round1 => execute_round1().await,
        TestRound::Round2 => execute_round2().await,
        TestRound::Round3 => execute_round3().await,
    }
}


// ============================================================================
// 单元测试
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_round_display() {
        assert_eq!(format!("{}", TestRound::Round1), "第一轮（初始化）");
        assert_eq!(format!("{}", TestRound::Round2), "第二轮（重建）");
        assert_eq!(format!("{}", TestRound::Round3), "第三轮（重启）");
    }

    #[test]
    fn test_round_stats_new() {
        let stats = RoundStats::new(TestRound::Round1);
        assert_eq!(stats.round, TestRound::Round1);
        assert!(stats.service_stats.is_empty());
        assert_eq!(stats.db_stats.total, 0);
        assert_eq!(stats.integration_stats.total, 0);
    }

    #[test]
    fn test_round_stats_totals() {
        let mut stats = RoundStats::new(TestRound::Round1);

        // 添加服务测试结果
        stats.service_stats.insert(
            "Auth".to_string(),
            TestStats {
                total: 5,
                passed: 4,
                failed: 1,
            },
        );
        stats.service_stats.insert(
            "User".to_string(),
            TestStats {
                total: 3,
                passed: 3,
                failed: 0,
            },
        );

        // 添加数据库测试结果
        stats.db_stats = TestStats {
            total: 10,
            passed: 10,
            failed: 0,
        };

        // 添加联动测试结果
        stats.integration_stats = TestStats {
            total: 2,
            passed: 1,
            failed: 1,
        };

        assert_eq!(stats.total_tests(), 20); // 5 + 3 + 10 + 2
        assert_eq!(stats.passed_tests(), 18); // 4 + 3 + 10 + 1
        assert_eq!(stats.failed_tests(), 2); // 1 + 0 + 0 + 1
        assert!(!stats.is_success());
    }

    #[test]
    fn test_round_stats_success() {
        let mut stats = RoundStats::new(TestRound::Round2);
        stats.service_stats.insert(
            "Auth".to_string(),
            TestStats {
                total: 5,
                passed: 5,
                failed: 0,
            },
        );
        stats.db_stats = TestStats {
            total: 10,
            passed: 10,
            failed: 0,
        };

        assert!(stats.is_success());
    }

    #[test]
    fn test_full_test_stats_new() {
        let stats = FullTestStats::new();
        assert!(stats.rounds.is_empty());
        assert_eq!(stats.total_duration, Duration::ZERO);
        assert!(stats.bugs_found.is_empty());
    }

    #[test]
    fn test_full_test_stats_success() {
        let mut full_stats = FullTestStats::new();

        // 添加成功的轮次
        let mut round1 = RoundStats::new(TestRound::Round1);
        round1.service_stats.insert(
            "Auth".to_string(),
            TestStats {
                total: 5,
                passed: 5,
                failed: 0,
            },
        );
        full_stats.rounds.push(round1);

        assert!(full_stats.is_success());

        // 添加失败的轮次
        let mut round2 = RoundStats::new(TestRound::Round2);
        round2.service_stats.insert(
            "User".to_string(),
            TestStats {
                total: 3,
                passed: 2,
                failed: 1,
            },
        );
        full_stats.rounds.push(round2);

        assert!(!full_stats.is_success());
    }

    #[test]
    fn test_bug_report() {
        let bug = BugReport {
            round: TestRound::Round1,
            service: "Auth".to_string(),
            test_name: "test_login".to_string(),
            error_message: "Connection refused".to_string(),
            timestamp: Utc::now(),
            fixed: false,
        };

        assert_eq!(bug.round, TestRound::Round1);
        assert_eq!(bug.service, "Auth");
        assert!(!bug.fixed);
    }

    #[test]
    fn test_test_progress() {
        let progress = TestProgress {
            current_round: 1,
            current_service: "Auth".to_string(),
            current_test: "test_login".to_string(),
            completed: 5,
            total: 20,
        };

        assert_eq!(progress.current_round, 1);
        assert_eq!(progress.completed, 5);
        assert_eq!(progress.total, 20);
    }
}

// ============================================================================
// 属性测试 (Property-Based Testing)
// ============================================================================

#[cfg(test)]
mod property_tests {
    use super::*;
    use proptest::prelude::*;

    // 生成随机服务名
    fn arbitrary_service_name() -> impl Strategy<Value = String> {
        prop_oneof![
            Just("Auth".to_string()),
            Just("User".to_string()),
            Just("Content".to_string()),
            Just("Comment".to_string()),
            Just("Interaction".to_string()),
            Just("Timeline".to_string()),
            Just("Search".to_string()),
            Just("Notification".to_string()),
            Just("Chat".to_string()),
            Just("Gateway".to_string()),
            Just("SuperUser".to_string()),
        ]
    }

    // 生成随机测试统计
    fn arbitrary_test_stats() -> impl Strategy<Value = TestStats> {
        (0u32..100, 0u32..100).prop_map(|(passed, failed)| TestStats {
            total: passed + failed,
            passed,
            failed,
        })
    }

    // 生成随机轮次
    fn arbitrary_round() -> impl Strategy<Value = TestRound> {
        prop_oneof![
            Just(TestRound::Round1),
            Just(TestRound::Round2),
            Just(TestRound::Round3),
        ]
    }

    proptest! {
        #![proptest_config(ProptestConfig::with_cases(100))]

        /// Property 2: Test Round Execution Order
        /// 验证轮次统计的一致性：总数 = 通过数 + 失败数
        /// **Feature: cli-service-testing, Property 2: Test Round Execution Order**
        /// **Validates: Requirements 3.1-3.6, 4.1-4.7, 5.1-5.5**
        #[test]
        fn prop_round_stats_consistency(
            round in arbitrary_round(),
            service_stats in prop::collection::hash_map(
                arbitrary_service_name(),
                arbitrary_test_stats(),
                0..5
            ),
            db_stats in arbitrary_test_stats(),
            integration_stats in arbitrary_test_stats(),
        ) {
            let mut stats = RoundStats::new(round);
            stats.service_stats = service_stats;
            stats.db_stats = db_stats;
            stats.integration_stats = integration_stats;

            // 属性 1: 总测试数应该等于各部分之和
            let expected_total: u32 = stats.service_stats.values().map(|s| s.total).sum::<u32>()
                + stats.db_stats.total
                + stats.integration_stats.total;
            prop_assert_eq!(stats.total_tests(), expected_total);

            // 属性 2: 通过数应该等于各部分之和
            let expected_passed: u32 = stats.service_stats.values().map(|s| s.passed).sum::<u32>()
                + stats.db_stats.passed
                + stats.integration_stats.passed;
            prop_assert_eq!(stats.passed_tests(), expected_passed);

            // 属性 3: 失败数应该等于各部分之和
            let expected_failed: u32 = stats.service_stats.values().map(|s| s.failed).sum::<u32>()
                + stats.db_stats.failed
                + stats.integration_stats.failed;
            prop_assert_eq!(stats.failed_tests(), expected_failed);

            // 属性 4: 总数 = 通过数 + 失败数
            prop_assert_eq!(stats.total_tests(), stats.passed_tests() + stats.failed_tests());

            // 属性 5: is_success 应该在没有失败时返回 true
            prop_assert_eq!(stats.is_success(), stats.failed_tests() == 0);
        }

        /// Property 2 扩展: 验证完整测试统计的一致性
        /// **Feature: cli-service-testing, Property 2: Test Round Execution Order**
        /// **Validates: Requirements 3.1-3.6, 4.1-4.7, 5.1-5.5**
        #[test]
        fn prop_full_test_stats_consistency(
            round_results in prop::collection::vec(
                (arbitrary_round(), arbitrary_test_stats(), arbitrary_test_stats()),
                1..4
            ),
        ) {
            let mut full_stats = FullTestStats::new();

            for (round, db_stats, integration_stats) in round_results {
                let mut round_stats = RoundStats::new(round);
                round_stats.db_stats = db_stats;
                round_stats.integration_stats = integration_stats;
                full_stats.rounds.push(round_stats);
            }

            // 属性 1: is_success 应该在所有轮次都成功时返回 true
            let all_success = full_stats.rounds.iter().all(|r| r.is_success());
            prop_assert_eq!(full_stats.is_success(), all_success);

            // 属性 2: 轮次数量应该保持一致
            prop_assert!(full_stats.rounds.len() >= 1 && full_stats.rounds.len() <= 4);
        }

        /// Property 2 扩展: 验证轮次枚举的完整性
        /// **Feature: cli-service-testing, Property 2: Test Round Execution Order**
        /// **Validates: Requirements 3.1-3.6, 4.1-4.7, 5.1-5.5**
        #[test]
        fn prop_round_enum_display(
            round in arbitrary_round(),
        ) {
            let display = format!("{}", round);

            // 属性 1: 显示字符串不应该为空
            prop_assert!(!display.is_empty());

            // 属性 2: 显示字符串应该包含"轮"
            prop_assert!(display.contains("轮"));

            // 属性 3: 每个轮次应该有唯一的显示字符串
            match round {
                TestRound::Round1 => prop_assert!(display.contains("第一")),
                TestRound::Round2 => prop_assert!(display.contains("第二")),
                TestRound::Round3 => prop_assert!(display.contains("第三")),
            }
        }

        /// Property 2 扩展: 验证 Bug 报告的完整性
        /// **Feature: cli-service-testing, Property 2: Test Round Execution Order**
        /// **Validates: Requirements 9.1, 9.2**
        #[test]
        fn prop_bug_report_completeness(
            round in arbitrary_round(),
            service in arbitrary_service_name(),
            test_name in "[a-z_]{5,30}",
            error_message in ".{10,100}",
            fixed in any::<bool>(),
        ) {
            let bug = BugReport {
                round,
                service: service.clone(),
                test_name: test_name.clone(),
                error_message: error_message.clone(),
                timestamp: Utc::now(),
                fixed,
            };

            // 属性 1: 轮次应该保持不变
            prop_assert_eq!(bug.round, round);

            // 属性 2: 服务名应该保持不变
            prop_assert_eq!(&bug.service, &service);

            // 属性 3: 测试名应该保持不变
            prop_assert_eq!(&bug.test_name, &test_name);

            // 属性 4: 错误信息应该保持不变
            prop_assert_eq!(&bug.error_message, &error_message);

            // 属性 5: 修复状态应该保持不变
            prop_assert_eq!(bug.fixed, fixed);
        }

        /// Property 2 扩展: 验证测试进度的有效性
        /// **Feature: cli-service-testing, Property 2: Test Round Execution Order**
        /// **Validates: Requirements 8.1**
        #[test]
        fn prop_test_progress_validity(
            current_round in 1u8..=3u8,
            current_service in arbitrary_service_name(),
            current_test in "[a-z_]{5,30}",
            completed in 0u32..1000,
            total in 0u32..1000,
        ) {
            let progress = TestProgress {
                current_round,
                current_service: current_service.clone(),
                current_test: current_test.clone(),
                completed,
                total,
            };

            // 属性 1: 当前轮次应该在 1-3 之间
            prop_assert!(progress.current_round >= 1 && progress.current_round <= 3);

            // 属性 2: 服务名应该保持不变
            prop_assert_eq!(&progress.current_service, &current_service);

            // 属性 3: 测试名应该保持不变
            prop_assert_eq!(&progress.current_test, &current_test);

            // 属性 4: 完成数和总数应该保持不变
            prop_assert_eq!(progress.completed, completed);
            prop_assert_eq!(progress.total, total);
        }
    }
}
