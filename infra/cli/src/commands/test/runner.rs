//! 测试运行器

use anyhow::{bail, Result};

use crate::ui;

use super::grpc;
use super::{auth, chat, comment, content, gateway, interaction, notification, search, superuser, timeline, user};

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
    /// Gateway 路由测试
    Gateway,
    /// SuperUser 服务测试
    Superuser,
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
            "gateway" => Ok(TestTarget::Gateway),
            "superuser" | "su" => Ok(TestTarget::Superuser),
            _ => Err(format!("无效的测试目标: {}", s)),
        }
    }
}

/// 测试结果统计
#[derive(Default)]
pub struct TestStats {
    pub total: u32,
    pub passed: u32,
    pub failed: u32,
}

impl TestStats {
    pub fn record(&mut self, success: bool, name: &str) {
        self.total += 1;
        if success {
            self.passed += 1;
            ui::step_done(&format!("✓ {}", name));
        } else {
            self.failed += 1;
            ui::warn(&format!("✗ {}", name));
        }
    }

    pub fn merge(&mut self, other: &TestStats) {
        self.total += other.total;
        self.passed += other.passed;
        self.failed += other.failed;
    }

    pub fn print_summary(&self) {
        println!();
        ui::separator();
        println!();
        println!("测试结果汇总:");
        println!("  总测试数: {}", self.total);
        println!("  通过: {}", self.passed);
        println!("  失败: {}", self.failed);
        println!();

        if self.failed == 0 {
            ui::success("✓ 所有测试通过！");
        } else {
            ui::error(&format!("✗ {} 个测试失败", self.failed));
        }
    }

    pub fn is_success(&self) -> bool {
        self.failed == 0
    }
}

/// 执行测试
pub async fn execute(target: TestTarget) -> Result<()> {
    ui::header("运行测试");

    // 检查 grpcurl 是否安装
    if !grpc::check_grpcurl_installed().await {
        ui::error("grpcurl 未安装");
        ui::hint("安装: brew install grpcurl");
        bail!("grpcurl 未安装");
    }

    let mut stats = TestStats::default();

    match target {
        TestTarget::All => {
            ui::info("运行所有服务测试");
            println!();

            // Auth 测试
            ui::step("1/11", "Auth Service");
            let auth_stats = auth::run_tests().await?;
            stats.merge(&auth_stats);

            // User 测试
            ui::step("2/11", "User Service");
            let user_stats = user::run_tests().await?;
            stats.merge(&user_stats);

            // Content 测试
            ui::step("3/11", "Content Service");
            let content_stats = content::run_tests().await?;
            stats.merge(&content_stats);

            // Comment 测试
            ui::step("4/11", "Comment Service");
            let comment_stats = comment::run_tests().await?;
            stats.merge(&comment_stats);

            // Interaction 测试
            ui::step("5/11", "Interaction Service");
            let interaction_stats = interaction::run_tests().await?;
            stats.merge(&interaction_stats);

            // Timeline 测试
            ui::step("6/11", "Timeline Service");
            let timeline_stats = timeline::run_tests().await?;
            stats.merge(&timeline_stats);

            // Search 测试
            ui::step("7/11", "Search Service");
            let search_stats = search::run_tests().await?;
            stats.merge(&search_stats);

            // Notification 测试
            ui::step("8/11", "Notification Service");
            let notification_stats = notification::run_tests().await?;
            stats.merge(&notification_stats);

            // Chat 测试
            ui::step("9/11", "Chat Service");
            let chat_stats = chat::run_tests().await?;
            stats.merge(&chat_stats);

            // Gateway 测试
            ui::step("10/11", "Gateway Service");
            let gateway_stats = gateway::run_tests().await?;
            stats.merge(&gateway_stats);

            // SuperUser 测试
            ui::step("11/11", "SuperUser Service");
            let superuser_stats = superuser::run_tests().await?;
            stats.merge(&superuser_stats);
        }
        TestTarget::Auth => {
            ui::info("运行 Auth 服务测试");
            println!();
            stats = auth::run_tests().await?;
        }
        TestTarget::User => {
            ui::info("运行 User 服务测试");
            println!();
            stats = user::run_tests().await?;
        }
        TestTarget::Content => {
            ui::info("运行 Content 服务测试");
            println!();
            stats = content::run_tests().await?;
        }
        TestTarget::Comment => {
            ui::info("运行 Comment 服务测试");
            println!();
            stats = comment::run_tests().await?;
        }
        TestTarget::Interaction => {
            ui::info("运行 Interaction 服务测试");
            println!();
            stats = interaction::run_tests().await?;
        }
        TestTarget::Timeline => {
            ui::info("运行 Timeline 服务测试");
            println!();
            stats = timeline::run_tests().await?;
        }
        TestTarget::Search => {
            ui::info("运行 Search 服务测试");
            println!();
            stats = search::run_tests().await?;
        }
        TestTarget::Notification => {
            ui::info("运行 Notification 服务测试");
            println!();
            stats = notification::run_tests().await?;
        }
        TestTarget::Chat => {
            ui::info("运行 Chat 服务测试");
            println!();
            stats = chat::run_tests().await?;
        }
        TestTarget::Gateway => {
            ui::info("运行 Gateway 路由测试");
            println!();
            stats = gateway::run_tests().await?;
        }
        TestTarget::Superuser => {
            ui::info("运行 SuperUser 服务测试");
            println!();
            stats = superuser::run_tests().await?;
        }
    }

    stats.print_summary();

    if !stats.is_success() {
        bail!("测试失败");
    }

    Ok(())
}
