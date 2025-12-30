use console::{style, Emoji};

// Emoji 图标
pub static ROCKET: Emoji<'_, '_> = Emoji("🚀", "");
#[allow(dead_code)]
pub static DOCKER: Emoji<'_, '_> = Emoji("🐳", "");
#[allow(dead_code)]
pub static DATABASE: Emoji<'_, '_> = Emoji("🗄", "");
#[allow(dead_code)]
pub static API: Emoji<'_, '_> = Emoji("🔌", "");
#[allow(dead_code)]
pub static WEB: Emoji<'_, '_> = Emoji("🌐", "");
#[allow(dead_code)]
pub static MOBILE: Emoji<'_, '_> = Emoji("📱", "");
#[allow(dead_code)]
pub static GEAR: Emoji<'_, '_> = Emoji("⚙", "");
pub static CHECK: Emoji<'_, '_> = Emoji("✅", "[OK]");
pub static CROSS: Emoji<'_, '_> = Emoji("❌", "[FAIL]");

/// 检查是否禁用颜色
fn no_color() -> bool {
    std::env::var("NO_COLOR").is_ok()
}

/// 打印成功消息
pub fn success(msg: &str) {
    if no_color() {
        println!("[OK] {}", msg);
    } else {
        println!("{} {}", style("✓").green(), msg);
    }
}

/// 打印警告消息
pub fn warn(msg: &str) {
    if no_color() {
        println!("[WARN] {}", msg);
    } else {
        println!("{} {}", style("⚠").yellow(), msg);
    }
}

/// 打印错误消息
pub fn error(msg: &str) {
    if no_color() {
        eprintln!("[ERROR] {}", msg);
    } else {
        eprintln!("{} {}", style("✗").red(), msg);
    }
}

/// 打印信息消息
pub fn info(msg: &str) {
    if no_color() {
        println!("[INFO] {}", msg);
    } else {
        println!("{} {}", style("ℹ").cyan(), msg);
    }
}

/// 打印步骤消息
pub fn step(msg: &str) {
    if no_color() {
        println!(">> {}", msg);
    } else {
        println!("{} {}", style("▶").blue().bold(), msg);
    }
}

/// 打印分隔线
pub fn separator() {
    if no_color() {
        println!("------------------------------------------------------------");
    } else {
        println!(
            "{}",
            style("────────────────────────────────────────────────────────────").dim()
        );
    }
}

/// 打印标题
pub fn header(title: &str) {
    println!();
    if no_color() {
        println!("============================================================");
        println!("  {} {}", ROCKET, title);
        println!("============================================================");
    } else {
        println!(
            "{}",
            style("╔════════════════════════════════════════════════════════════╗")
                .cyan()
                .bold()
        );
        println!(
            "{}  {} {}",
            style("║").cyan().bold(),
            ROCKET,
            style(title).bold()
        );
        println!(
            "{}",
            style("╚════════════════════════════════════════════════════════════╝")
                .cyan()
                .bold()
        );
    }
    println!();
}

/// 打印 URL
pub fn url(name: &str, url: &str) {
    if no_color() {
        println!("  {}  ->  {}", name, url);
    } else {
        println!("  {}  →  {}", style(name).cyan(), url);
    }
}

/// 打印调试信息
#[allow(dead_code)]
pub fn debug(msg: &str) {
    if crate::is_debug() {
        if no_color() {
            println!("[DEBUG] {}", msg);
        } else {
            println!("{} {}", style("[DEBUG]").dim(), style(msg).dim());
        }
    }
}
