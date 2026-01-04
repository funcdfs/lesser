use console::{style, StyledObject, Emoji};

// Emoji 图标
pub static ROCKET: Emoji<'_, '_> = Emoji("🚀", "");

/// 返回 dim 样式的字符串
pub fn style_dim(s: &str) -> StyledObject<&str> {
    if no_color() {
        style(s)
    } else {
        style(s).dim()
    }
}

/// 返回命令样式的字符串
pub fn style_cmd(s: &str) -> StyledObject<&str> {
    if no_color() {
        style(s)
    } else {
        style(s).cyan().bold()
    }
}

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

/// 打印步骤消息 (带编号)
pub fn step(num: &str, msg: &str) {
    if no_color() {
        println!("[{}] {}", num, msg);
    } else {
        println!("{} {}", style(format!("[{}]", num)).blue().bold(), msg);
    }
}

/// 打印步骤完成消息
pub fn step_done(msg: &str) {
    if no_color() {
        println!("  [OK] {}", msg);
    } else {
        println!("  {} {}", style("✓").green(), msg);
    }
}

/// 打印步骤完成消息（带函数名和文件路径）
/// 
/// 输出格式：
/// ```
///   ✓ 测试名称
///       → Method()  file.rs
/// ```
pub fn step_done_with_func(msg: &str, func_name: &str, file_path: &str) {
    if no_color() {
        println!("  [OK] {}", msg);
        println!("        -> {}  {}", func_name, file_path);
    } else {
        println!("  {} {}", style("✓").green(), msg);
        println!("        {} {}  {}", style("→").dim(), style(func_name).cyan(), style(file_path).dim());
    }
}

/// 打印步骤失败消息
pub fn step_fail(msg: &str) {
    if no_color() {
        println!("  [FAIL] {}", msg);
    } else {
        println!("  {} {}", style("✗").red(), msg);
    }
}

/// 打印步骤失败消息（带函数名和文件路径）
/// 
/// 输出格式：
/// ```
///   ✗ 测试名称
///       → Method()  file.rs
/// ```
pub fn step_fail_with_func(msg: &str, func_name: &str, file_path: &str) {
    if no_color() {
        println!("  [FAIL] {}", msg);
        println!("        -> {}  {}", func_name, file_path);
    } else {
        println!("  {} {}", style("✗").red(), msg);
        println!("        {} {}  {}", style("→").dim(), style(func_name).cyan(), style(file_path).dim());
    }
}

/// 打印键值对
pub fn kv(key: &str, value: &str) {
    if no_color() {
        println!("  {}: {}", key, value);
    } else {
        println!("  {}: {}", style(key).dim(), value);
    }
}

/// 打印提示信息
pub fn hint(msg: &str) {
    if no_color() {
        println!("  TIP: {}", msg);
    } else {
        println!("  {} {}", style("💡").dim(), style(msg).dim());
    }
}

/// 打印 Banner 标题
pub fn banner(title: &str) {
    println!();
    if no_color() {
        println!("=== {} {} ===", ROCKET, title);
    } else {
        println!(
            "{} {} {}",
            style("━━━").cyan(),
            style(format!("{} {}", ROCKET, title)).bold(),
            style("━━━").cyan()
        );
    }
    println!();
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

/// 打印 URL（用于显示服务访问地址）
#[allow(dead_code)]
pub fn url(name: &str, url: &str) {
    if no_color() {
        println!("  {}  ->  {}", name, url);
    } else {
        println!("  {}  →  {}", style(name).cyan(), url);
    }
}
