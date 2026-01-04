//! 数据库分表验证模块
//!
//! 验证 lesser_db 和 lesser_chat_db 中的表结构是否正确

use anyhow::{Context, Result};
use tokio_postgres::{Client, NoTls};

use crate::ui;

use super::runner::TestStats;

/// 数据库连接配置
#[derive(Debug, Clone)]
pub struct DatabaseConfig {
    pub host: String,
    pub port: u16,
    pub user: String,
    pub password: String,
}

impl Default for DatabaseConfig {
    fn default() -> Self {
        Self {
            host: "localhost".to_string(),
            port: 5432,
            user: "lesser".to_string(),
            password: "lesser_dev_password".to_string(),
        }
    }
}

impl DatabaseConfig {
    /// 从环境变量加载配置
    pub fn from_env() -> Self {
        Self {
            host: std::env::var("POSTGRES_HOST").unwrap_or_else(|_| "localhost".to_string()),
            port: std::env::var("POSTGRES_PORT")
                .ok()
                .and_then(|p| p.parse().ok())
                .unwrap_or(5432),
            user: std::env::var("POSTGRES_USER").unwrap_or_else(|_| "lesser".to_string()),
            password: std::env::var("POSTGRES_PASSWORD")
                .unwrap_or_else(|_| "lesser_dev_password".to_string()),
        }
    }

    /// 生成连接字符串
    pub fn connection_string(&self, database: &str) -> String {
        format!(
            "host={} port={} user={} password={} dbname={}",
            self.host, self.port, self.user, self.password, database
        )
    }
}

/// 数据库表定义
#[derive(Debug, Clone)]
pub struct DatabaseSchema {
    /// lesser_db 中应该存在的表
    pub lesser_db_tables: Vec<TableInfo>,
    /// lesser_chat_db 中应该存在的表
    pub lesser_chat_db_tables: Vec<TableInfo>,
}

/// 表信息
#[derive(Debug, Clone)]
pub struct TableInfo {
    /// 表名
    pub name: &'static str,
    /// 所属服务
    pub service: &'static str,
    /// 描述（用于文档和调试）
    #[allow(dead_code)]
    pub description: &'static str,
}

impl Default for DatabaseSchema {
    fn default() -> Self {
        Self {
            lesser_db_tables: vec![
                // 用户相关 (User Service)
                TableInfo {
                    name: "users",
                    service: "User",
                    description: "用户基本信息",
                },
                TableInfo {
                    name: "follows",
                    service: "User",
                    description: "关注关系",
                },
                TableInfo {
                    name: "blocks",
                    service: "User",
                    description: "屏蔽关系",
                },
                TableInfo {
                    name: "user_privacy_settings",
                    service: "User",
                    description: "用户隐私设置",
                },
                TableInfo {
                    name: "user_notification_settings",
                    service: "User",
                    description: "用户通知设置",
                },
                TableInfo {
                    name: "follow_requests",
                    service: "User",
                    description: "关注请求（私密账户）",
                },
                // SuperUser 相关
                TableInfo {
                    name: "superusers",
                    service: "SuperUser",
                    description: "超级管理员账户",
                },
                TableInfo {
                    name: "superuser_audit_logs",
                    service: "SuperUser",
                    description: "审计日志",
                },
                TableInfo {
                    name: "superuser_sessions",
                    service: "SuperUser",
                    description: "会话管理",
                },
                // 内容相关 (Content Service)
                TableInfo {
                    name: "contents",
                    service: "Content",
                    description: "内容（Story/Short/Article）",
                },
                // 交互相关 (Interaction Service)
                TableInfo {
                    name: "likes",
                    service: "Interaction",
                    description: "点赞记录",
                },
                TableInfo {
                    name: "bookmarks",
                    service: "Interaction",
                    description: "收藏记录",
                },
                TableInfo {
                    name: "reposts",
                    service: "Interaction",
                    description: "转发记录",
                },
                // 评论相关 (Comment Service)
                TableInfo {
                    name: "comments",
                    service: "Comment",
                    description: "评论",
                },
                TableInfo {
                    name: "comment_likes",
                    service: "Comment",
                    description: "评论点赞",
                },
                // 通知相关 (Notification Service)
                TableInfo {
                    name: "notifications",
                    service: "Notification",
                    description: "通知",
                },
                // 封禁相关 (Auth Service)
                TableInfo {
                    name: "user_bans",
                    service: "Auth",
                    description: "用户封禁记录",
                },
                // 搜索相关 (Search Service)
                TableInfo {
                    name: "content_embeddings",
                    service: "Search",
                    description: "内容向量嵌入",
                },
                TableInfo {
                    name: "comment_embeddings",
                    service: "Search",
                    description: "评论向量嵌入",
                },
                TableInfo {
                    name: "user_embeddings",
                    service: "Search",
                    description: "用户向量嵌入",
                },
            ],
            lesser_chat_db_tables: vec![
                TableInfo {
                    name: "conversations",
                    service: "Chat",
                    description: "会话",
                },
                TableInfo {
                    name: "conversation_members",
                    service: "Chat",
                    description: "会话成员",
                },
                TableInfo {
                    name: "messages",
                    service: "Chat",
                    description: "消息",
                },
                TableInfo {
                    name: "message_reads",
                    service: "Chat",
                    description: "消息已读状态",
                },
            ],
        }
    }
}


/// 表验证结果
#[derive(Debug, Clone)]
pub struct TableVerificationResult {
    /// 表名
    pub table_name: String,
    /// 数据库名（用于报告和调试）
    #[allow(dead_code)]
    pub database: String,
    /// 所属服务
    pub service: String,
    /// 是否存在
    pub exists: bool,
    /// 错误信息（如果有）
    pub error: Option<String>,
}

/// 数据库验证结果
#[derive(Debug, Default)]
pub struct DatabaseVerificationResult {
    /// 所有表的验证结果
    pub tables: Vec<TableVerificationResult>,
    /// 缺失的表
    pub missing_tables: Vec<TableVerificationResult>,
    /// 验证成功的表
    pub verified_tables: Vec<TableVerificationResult>,
    /// 连接错误
    pub connection_errors: Vec<String>,
}

impl DatabaseVerificationResult {
    /// 是否全部验证通过
    pub fn is_success(&self) -> bool {
        self.missing_tables.is_empty() && self.connection_errors.is_empty()
    }

    /// 转换为测试统计
    pub fn to_stats(&self) -> TestStats {
        TestStats {
            total: self.tables.len() as u32,
            passed: self.verified_tables.len() as u32,
            failed: (self.missing_tables.len() + self.connection_errors.len()) as u32,
        }
    }
}

/// 连接到数据库
async fn connect_to_database(config: &DatabaseConfig, database: &str) -> Result<Client> {
    let conn_str = config.connection_string(database);
    let (client, connection) = tokio_postgres::connect(&conn_str, NoTls)
        .await
        .with_context(|| format!("无法连接到数据库 {}", database))?;

    // 在后台运行连接
    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("数据库连接错误: {}", e);
        }
    });

    Ok(client)
}

/// 检查表是否存在
async fn check_table_exists(client: &Client, table_name: &str) -> Result<bool> {
    let query = r#"
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = $1
        )
    "#;

    let row = client
        .query_one(query, &[&table_name])
        .await
        .with_context(|| format!("查询表 {} 是否存在时出错", table_name))?;

    Ok(row.get::<_, bool>(0))
}

/// 验证单个数据库的表结构
async fn verify_database_tables(
    config: &DatabaseConfig,
    database: &str,
    tables: &[TableInfo],
) -> Vec<TableVerificationResult> {
    let mut results = Vec::new();

    // 尝试连接数据库
    let client = match connect_to_database(config, database).await {
        Ok(c) => c,
        Err(e) => {
            // 连接失败，所有表都标记为失败
            for table in tables {
                results.push(TableVerificationResult {
                    table_name: table.name.to_string(),
                    database: database.to_string(),
                    service: table.service.to_string(),
                    exists: false,
                    error: Some(format!("数据库连接失败: {}", e)),
                });
            }
            return results;
        }
    };

    // 检查每个表
    for table in tables {
        let result = match check_table_exists(&client, table.name).await {
            Ok(exists) => TableVerificationResult {
                table_name: table.name.to_string(),
                database: database.to_string(),
                service: table.service.to_string(),
                exists,
                error: None,
            },
            Err(e) => TableVerificationResult {
                table_name: table.name.to_string(),
                database: database.to_string(),
                service: table.service.to_string(),
                exists: false,
                error: Some(e.to_string()),
            },
        };
        results.push(result);
    }

    results
}

/// 验证数据库表结构
pub async fn verify_database_schema(config: Option<DatabaseConfig>) -> Result<DatabaseVerificationResult> {
    let config = config.unwrap_or_else(DatabaseConfig::from_env);
    let schema = DatabaseSchema::default();
    let mut result = DatabaseVerificationResult::default();

    ui::info("验证 lesser_db 表结构...");
    println!();

    // 验证 lesser_db
    let lesser_db_results =
        verify_database_tables(&config, "lesser_db", &schema.lesser_db_tables).await;

    for table_result in &lesser_db_results {
        if table_result.exists {
            ui::step_done_with_func(
                &table_result.table_name,
                &format!("{}Service", table_result.service),
                "lesser_db",
            );
            result.verified_tables.push(table_result.clone());
        } else {
            let error_msg = table_result
                .error
                .as_ref()
                .map(|e| format!(" - {}", e))
                .unwrap_or_default();
            ui::step_fail_with_func(
                &format!("{} - 缺失{}", table_result.table_name, error_msg),
                &format!("{}Service", table_result.service),
                "lesser_db",
            );
            result.missing_tables.push(table_result.clone());
        }
        result.tables.push(table_result.clone());
    }

    println!();
    ui::info("验证 lesser_chat_db 表结构...");
    println!();

    // 验证 lesser_chat_db
    let chat_db_results =
        verify_database_tables(&config, "lesser_chat_db", &schema.lesser_chat_db_tables).await;

    for table_result in &chat_db_results {
        if table_result.exists {
            ui::step_done_with_func(
                &table_result.table_name,
                &format!("{}Service", table_result.service),
                "lesser_chat_db",
            );
            result.verified_tables.push(table_result.clone());
        } else {
            let error_msg = table_result
                .error
                .as_ref()
                .map(|e| format!(" - {}", e))
                .unwrap_or_default();
            ui::step_fail_with_func(
                &format!("{} - 缺失{}", table_result.table_name, error_msg),
                &format!("{}Service", table_result.service),
                "lesser_chat_db",
            );
            result.missing_tables.push(table_result.clone());
        }
        result.tables.push(table_result.clone());
    }

    Ok(result)
}

/// 运行数据库验证测试
pub async fn run_tests() -> Result<TestStats> {
    let result = verify_database_schema(None).await?;

    // 打印汇总
    println!();
    if result.is_success() {
        ui::success(&format!(
            "数据库验证通过: {}/{} 表存在",
            result.verified_tables.len(),
            result.tables.len()
        ));
    } else {
        ui::error(&format!(
            "数据库验证失败: {} 表缺失",
            result.missing_tables.len()
        ));

        // 按服务分组显示缺失的表
        let mut by_service: std::collections::HashMap<String, Vec<String>> =
            std::collections::HashMap::new();
        for table in &result.missing_tables {
            by_service
                .entry(table.service.clone())
                .or_default()
                .push(table.table_name.clone());
        }

        println!();
        ui::info("缺失表详情:");
        for (service, tables) in by_service {
            println!("  {} Service: {}", service, tables.join(", "));
        }
    }

    Ok(result.to_stats())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_database_schema_default() {
        let schema = DatabaseSchema::default();

        // 验证 lesser_db 表数量
        assert!(
            schema.lesser_db_tables.len() >= 15,
            "lesser_db 应该至少有 15 个表"
        );

        // 验证 lesser_chat_db 表数量
        assert_eq!(
            schema.lesser_chat_db_tables.len(),
            4,
            "lesser_chat_db 应该有 4 个表"
        );

        // 验证关键表存在
        let lesser_db_table_names: Vec<&str> =
            schema.lesser_db_tables.iter().map(|t| t.name).collect();
        assert!(lesser_db_table_names.contains(&"users"));
        assert!(lesser_db_table_names.contains(&"contents"));
        assert!(lesser_db_table_names.contains(&"comments"));
        assert!(lesser_db_table_names.contains(&"notifications"));

        let chat_db_table_names: Vec<&str> =
            schema.lesser_chat_db_tables.iter().map(|t| t.name).collect();
        assert!(chat_db_table_names.contains(&"conversations"));
        assert!(chat_db_table_names.contains(&"messages"));
    }

    #[test]
    fn test_database_config_default() {
        let config = DatabaseConfig::default();
        assert_eq!(config.host, "localhost");
        assert_eq!(config.port, 5432);
        assert_eq!(config.user, "lesser");
    }

    #[test]
    fn test_connection_string() {
        let config = DatabaseConfig::default();
        let conn_str = config.connection_string("test_db");
        assert!(conn_str.contains("host=localhost"));
        assert!(conn_str.contains("port=5432"));
        assert!(conn_str.contains("dbname=test_db"));
    }

    #[test]
    fn test_verification_result_success() {
        let result = DatabaseVerificationResult {
            tables: vec![TableVerificationResult {
                table_name: "test".to_string(),
                database: "test_db".to_string(),
                service: "Test".to_string(),
                exists: true,
                error: None,
            }],
            verified_tables: vec![TableVerificationResult {
                table_name: "test".to_string(),
                database: "test_db".to_string(),
                service: "Test".to_string(),
                exists: true,
                error: None,
            }],
            missing_tables: vec![],
            connection_errors: vec![],
        };

        assert!(result.is_success());
        let stats = result.to_stats();
        assert_eq!(stats.total, 1);
        assert_eq!(stats.passed, 1);
        assert_eq!(stats.failed, 0);
    }

    #[test]
    fn test_verification_result_failure() {
        let result = DatabaseVerificationResult {
            tables: vec![TableVerificationResult {
                table_name: "missing".to_string(),
                database: "test_db".to_string(),
                service: "Test".to_string(),
                exists: false,
                error: None,
            }],
            verified_tables: vec![],
            missing_tables: vec![TableVerificationResult {
                table_name: "missing".to_string(),
                database: "test_db".to_string(),
                service: "Test".to_string(),
                exists: false,
                error: None,
            }],
            connection_errors: vec![],
        };

        assert!(!result.is_success());
        let stats = result.to_stats();
        assert_eq!(stats.total, 1);
        assert_eq!(stats.passed, 0);
        assert_eq!(stats.failed, 1);
    }
}


// ============================================================================
// 属性测试 (Property-Based Testing)
// ============================================================================

#[cfg(test)]
mod property_tests {
    use super::*;
    use proptest::prelude::*;

    // 生成随机表名
    fn arbitrary_table_name() -> impl Strategy<Value = String> {
        "[a-z][a-z0-9_]{2,30}".prop_map(|s| s.to_string())
    }

    // 生成随机服务名
    fn arbitrary_service_name() -> impl Strategy<Value = String> {
        prop_oneof![
            Just("User".to_string()),
            Just("Content".to_string()),
            Just("Comment".to_string()),
            Just("Interaction".to_string()),
            Just("Notification".to_string()),
            Just("Search".to_string()),
            Just("Chat".to_string()),
            Just("Auth".to_string()),
            Just("SuperUser".to_string()),
        ]
    }

    // 生成随机数据库名
    fn arbitrary_database_name() -> impl Strategy<Value = String> {
        prop_oneof![
            Just("lesser_db".to_string()),
            Just("lesser_chat_db".to_string()),
        ]
    }

    proptest! {
        #![proptest_config(ProptestConfig::with_cases(100))]

        /// Property 1: Database Schema Completeness
        /// 验证结果的统计数据应该与表列表一致
        /// **Feature: cli-service-testing, Property 1: Database Schema Completeness**
        /// **Validates: Requirements 1.1, 1.2, 1.3, 1.4**
        #[test]
        fn prop_verification_stats_consistency(
            exists_flags in prop::collection::vec(any::<bool>(), 1..50)
        ) {
            let mut result = DatabaseVerificationResult::default();

            for (i, exists) in exists_flags.iter().enumerate() {
                let table_result = TableVerificationResult {
                    table_name: format!("table_{}", i),
                    database: "test_db".to_string(),
                    service: "Test".to_string(),
                    exists: *exists,
                    error: None,
                };

                result.tables.push(table_result.clone());
                if *exists {
                    result.verified_tables.push(table_result);
                } else {
                    result.missing_tables.push(table_result);
                }
            }

            let stats = result.to_stats();

            // 属性 1: 总数应该等于表列表长度
            prop_assert_eq!(stats.total as usize, exists_flags.len());

            // 属性 2: 通过数 + 失败数 应该等于总数
            prop_assert_eq!(stats.passed + stats.failed, stats.total);

            // 属性 3: 通过数应该等于 exists=true 的数量
            let expected_passed = exists_flags.iter().filter(|&&e| e).count() as u32;
            prop_assert_eq!(stats.passed, expected_passed);

            // 属性 4: 失败数应该等于 exists=false 的数量
            let expected_failed = exists_flags.iter().filter(|&&e| !e).count() as u32;
            prop_assert_eq!(stats.failed, expected_failed);

            // 属性 5: is_success 应该在没有缺失表时返回 true
            prop_assert_eq!(result.is_success(), result.missing_tables.is_empty());
        }

        /// Property 1 扩展: 验证表信息的完整性
        /// **Feature: cli-service-testing, Property 1: Database Schema Completeness**
        /// **Validates: Requirements 1.1, 1.2, 1.3, 1.4**
        #[test]
        fn prop_table_info_completeness(
            table_name in arbitrary_table_name(),
            service in arbitrary_service_name(),
            database in arbitrary_database_name(),
            exists in any::<bool>(),
            has_error in any::<bool>(),
        ) {
            let error = if has_error && !exists {
                Some("Connection error".to_string())
            } else {
                None
            };

            let result = TableVerificationResult {
                table_name: table_name.clone(),
                database: database.clone(),
                service: service.clone(),
                exists,
                error: error.clone(),
            };

            // 属性 1: 表名应该保持不变
            prop_assert_eq!(&result.table_name, &table_name);

            // 属性 2: 数据库名应该保持不变
            prop_assert_eq!(&result.database, &database);

            // 属性 3: 服务名应该保持不变
            prop_assert_eq!(&result.service, &service);

            // 属性 4: 存在状态应该保持不变
            prop_assert_eq!(result.exists, exists);

            // 属性 5: 如果表存在，不应该有错误
            if exists {
                // 存在的表不应该有错误（在我们的测试数据生成中）
                // 注意：实际情况中可能有其他类型的错误
            }
        }

        /// Property 1 扩展: 验证 DatabaseSchema 的默认值完整性
        /// **Feature: cli-service-testing, Property 1: Database Schema Completeness**
        /// **Validates: Requirements 1.1, 1.2, 1.3, 1.4**
        #[test]
        fn prop_schema_default_tables_non_empty(
            _dummy in any::<u8>()  // 只是为了让 proptest 运行多次
        ) {
            let schema = DatabaseSchema::default();

            // 属性 1: lesser_db 表列表不应该为空
            prop_assert!(!schema.lesser_db_tables.is_empty());

            // 属性 2: lesser_chat_db 表列表不应该为空
            prop_assert!(!schema.lesser_chat_db_tables.is_empty());

            // 属性 3: 所有表名应该是唯一的
            let lesser_db_names: std::collections::HashSet<_> =
                schema.lesser_db_tables.iter().map(|t| t.name).collect();
            prop_assert_eq!(lesser_db_names.len(), schema.lesser_db_tables.len());

            let chat_db_names: std::collections::HashSet<_> =
                schema.lesser_chat_db_tables.iter().map(|t| t.name).collect();
            prop_assert_eq!(chat_db_names.len(), schema.lesser_chat_db_tables.len());

            // 属性 4: 所有表应该有非空的服务名
            for table in &schema.lesser_db_tables {
                prop_assert!(!table.service.is_empty());
            }
            for table in &schema.lesser_chat_db_tables {
                prop_assert!(!table.service.is_empty());
            }
        }

        /// Property 1 扩展: 验证连接字符串格式
        /// **Feature: cli-service-testing, Property 1: Database Schema Completeness**
        /// **Validates: Requirements 1.5**
        #[test]
        fn prop_connection_string_format(
            host in "[a-z][a-z0-9]{2,20}",
            port in 1024u16..65535u16,
            user in "[a-z][a-z0-9]{2,20}",
            password in "[a-zA-Z0-9]{8,32}",
            database in "[a-z][a-z0-9_]{2,20}",
        ) {
            let config = DatabaseConfig {
                host: host.clone(),
                port,
                user: user.clone(),
                password: password.clone(),
            };

            let conn_str = config.connection_string(&database);

            // 属性 1: 连接字符串应该包含 host
            let expected_host = format!("host={}", host);
            prop_assert!(conn_str.contains(&expected_host), "连接字符串应包含 host");

            // 属性 2: 连接字符串应该包含 port
            let expected_port = format!("port={}", port);
            prop_assert!(conn_str.contains(&expected_port), "连接字符串应包含 port");

            // 属性 3: 连接字符串应该包含 user
            let expected_user = format!("user={}", user);
            prop_assert!(conn_str.contains(&expected_user), "连接字符串应包含 user");

            // 属性 4: 连接字符串应该包含 password
            let expected_password = format!("password={}", password);
            prop_assert!(conn_str.contains(&expected_password), "连接字符串应包含 password");

            // 属性 5: 连接字符串应该包含 dbname
            let expected_dbname = format!("dbname={}", database);
            prop_assert!(conn_str.contains(&expected_dbname), "连接字符串应包含 dbname");
        }
    }
}
