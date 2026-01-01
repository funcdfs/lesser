// Package database 提供统一的数据库连接封装
// 支持连接池配置和健康检查
package database

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq"
)

// Config 数据库配置
type Config struct {
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

// DefaultConfig 返回默认配置
func DefaultConfig() Config {
	return Config{
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

// NewConnection 创建新的 PostgreSQL 连接
func NewConnection(cfg Config) (*sql.DB, error) {
	dsn := cfg.DSN
	if dsn == "" {
		dsn = buildDSN(cfg)
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

// MustInitDB 初始化数据库连接，失败时 panic
func MustInitDB(cfg Config) *sql.DB {
	db, err := NewConnection(cfg)
	if err != nil {
		panic(fmt.Sprintf("failed to initialize database: %v", err))
	}
	return db
}

// buildDSN 根据配置构建 DSN 字符串
func buildDSN(cfg Config) string {
	sslMode := cfg.SSLMode
	if sslMode == "" {
		sslMode = "disable"
	}
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.DBName, sslMode,
	)
}

// HealthCheck 检查数据库连接健康状态
func HealthCheck(db *sql.DB) error {
	return db.Ping()
}
