// Package db 提供统一的数据存储封装
// 支持 PostgreSQL 和 Redis 连接池管理、健康检查、事务管理
package db

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"time"

	_ "github.com/lib/pq"
)

// PostgresConfig PostgreSQL 配置
type PostgresConfig struct {
	// DSN 数据库连接字符串，优先使用
	DSN string
	// 以下字段在 DSN 为空时使用
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
	SSLMode  string
	// 连接池配置
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
	ConnMaxIdleTime time.Duration
}

// DefaultPostgresConfig 返回默认配置
func DefaultPostgresConfig() PostgresConfig {
	return PostgresConfig{
		Host:            "localhost",
		Port:            "5432",
		User:            "postgres",
		Password:        "postgres",
		DBName:          "lesser",
		SSLMode:         "disable",
		MaxOpenConns:    25,
		MaxIdleConns:    10,
		ConnMaxLifetime: time.Hour,
		ConnMaxIdleTime: 5 * time.Minute,
	}
}

// PostgresConfigFromEnv 从环境变量读取配置
func PostgresConfigFromEnv() PostgresConfig {
	cfg := DefaultPostgresConfig()

	if host := os.Getenv("DB_HOST"); host != "" {
		cfg.Host = host
	}
	if port := os.Getenv("DB_PORT"); port != "" {
		cfg.Port = port
	}
	if user := os.Getenv("DB_USER"); user != "" {
		cfg.User = user
	}
	if password := os.Getenv("DB_PASSWORD"); password != "" {
		cfg.Password = password
	}
	if dbName := os.Getenv("DB_NAME"); dbName != "" {
		cfg.DBName = dbName
	}
	if sslMode := os.Getenv("DB_SSLMODE"); sslMode != "" {
		cfg.SSLMode = sslMode
	}

	return cfg
}

// NewPostgresConnection 创建新的 PostgreSQL 连接
func NewPostgresConnection(cfg PostgresConfig) (*sql.DB, error) {
	dsn := cfg.DSN
	if dsn == "" {
		dsn = buildPostgresDSN(cfg)
	}

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// 配置连接池
	if cfg.MaxOpenConns > 0 {
		db.SetMaxOpenConns(cfg.MaxOpenConns)
	}
	if cfg.MaxIdleConns > 0 {
		db.SetMaxIdleConns(cfg.MaxIdleConns)
	}
	if cfg.ConnMaxLifetime > 0 {
		db.SetConnMaxLifetime(cfg.ConnMaxLifetime)
	}
	if cfg.ConnMaxIdleTime > 0 {
		db.SetConnMaxIdleTime(cfg.ConnMaxIdleTime)
	}

	// 测试连接
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return db, nil
}

// MustInitPostgres 初始化数据库连接，失败时 panic
func MustInitPostgres(cfg PostgresConfig) *sql.DB {
	db, err := NewPostgresConnection(cfg)
	if err != nil {
		panic(fmt.Sprintf("failed to initialize database: %v", err))
	}
	return db
}

// buildPostgresDSN 根据配置构建 DSN 字符串
func buildPostgresDSN(cfg PostgresConfig) string {
	sslMode := cfg.SSLMode
	if sslMode == "" {
		sslMode = "disable"
	}
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.DBName, sslMode,
	)
}

// PostgresHealthCheck 检查数据库连接健康状态
func PostgresHealthCheck(db *sql.DB) error {
	return db.Ping()
}

// PostgresHealthCheckWithTimeout 带超时的健康检查
func PostgresHealthCheckWithTimeout(ctx context.Context, db *sql.DB, timeout time.Duration) error {
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()
	return db.PingContext(ctx)
}

// ---- 事务管理 ----

// TxFunc 事务函数类型
type TxFunc func(tx *sql.Tx) error

// WithTransaction 在事务中执行函数
// 使用 committed 标志确保 Commit 成功后不会再执行 Rollback
func WithTransaction(ctx context.Context, db *sql.DB, fn TxFunc) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("开始事务失败: %w", err)
	}

	var committed bool
	defer func() {
		if p := recover(); p != nil {
			tx.Rollback()
			panic(p)
		}
		// 只有在未提交时才回滚
		if !committed {
			tx.Rollback()
		}
	}()

	if err := fn(tx); err != nil {
		return err
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("提交事务失败: %w", err)
	}

	committed = true
	return nil
}

// WithTransactionOptions 带选项的事务执行
func WithTransactionOptions(ctx context.Context, db *sql.DB, opts *sql.TxOptions, fn TxFunc) error {
	tx, err := db.BeginTx(ctx, opts)
	if err != nil {
		return fmt.Errorf("开始事务失败: %w", err)
	}

	var committed bool
	defer func() {
		if p := recover(); p != nil {
			tx.Rollback()
			panic(p)
		}
		if !committed {
			tx.Rollback()
		}
	}()

	if err := fn(tx); err != nil {
		return err
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("提交事务失败: %w", err)
	}

	committed = true
	return nil
}

// ---- 查询辅助 ----

// Querier 查询接口（支持 *sql.DB 和 *sql.Tx）
type Querier interface {
	QueryContext(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error)
	QueryRowContext(ctx context.Context, query string, args ...interface{}) *sql.Row
	ExecContext(ctx context.Context, query string, args ...interface{}) (sql.Result, error)
}

// NullString 创建可空字符串
func NullString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{}
	}
	return sql.NullString{String: s, Valid: true}
}

// NullInt64 创建可空 int64
func NullInt64(i int64) sql.NullInt64 {
	if i == 0 {
		return sql.NullInt64{}
	}
	return sql.NullInt64{Int64: i, Valid: true}
}

// NullFloat64 创建可空 float64
func NullFloat64(f float64) sql.NullFloat64 {
	if f == 0 {
		return sql.NullFloat64{}
	}
	return sql.NullFloat64{Float64: f, Valid: true}
}

// NullBool 创建可空 bool
func NullBool(b bool) sql.NullBool {
	return sql.NullBool{Bool: b, Valid: true}
}

// NullTime 创建可空时间
func NullTime(t time.Time) sql.NullTime {
	if t.IsZero() {
		return sql.NullTime{}
	}
	return sql.NullTime{Time: t, Valid: true}
}

// StringFromNull 从可空字符串获取值
func StringFromNull(ns sql.NullString) string {
	if ns.Valid {
		return ns.String
	}
	return ""
}

// Int64FromNull 从可空 int64 获取值
func Int64FromNull(ni sql.NullInt64) int64 {
	if ni.Valid {
		return ni.Int64
	}
	return 0
}

// Float64FromNull 从可空 float64 获取值
func Float64FromNull(nf sql.NullFloat64) float64 {
	if nf.Valid {
		return nf.Float64
	}
	return 0
}

// BoolFromNull 从可空 bool 获取值
func BoolFromNull(nb sql.NullBool) bool {
	if nb.Valid {
		return nb.Bool
	}
	return false
}

// TimeFromNull 从可空时间获取值
func TimeFromNull(nt sql.NullTime) time.Time {
	if nt.Valid {
		return nt.Time
	}
	return time.Time{}
}
