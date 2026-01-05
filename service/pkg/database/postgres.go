// Package database 提供统一的数据库连接封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/db 包
package database

import (
	"context"
	"database/sql"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
	_ "github.com/lib/pq"
)

// Config 数据库配置
// Deprecated: 请使用 db.PostgresConfig
type Config = db.PostgresConfig

// DefaultConfig 返回默认配置
// Deprecated: 请使用 db.DefaultPostgresConfig
func DefaultConfig() Config {
	return db.DefaultPostgresConfig()
}

// ConfigFromEnv 从环境变量读取配置
// Deprecated: 请使用 db.PostgresConfigFromEnv
func ConfigFromEnv() Config {
	return db.PostgresConfigFromEnv()
}

// NewConnection 创建新的 PostgreSQL 连接
// Deprecated: 请使用 db.NewPostgresConnection
func NewConnection(cfg Config) (*sql.DB, error) {
	return db.NewPostgresConnection(cfg)
}

// MustInitDB 初始化数据库连接，失败时 panic
// Deprecated: 请使用 db.MustInitPostgres
func MustInitDB(cfg Config) *sql.DB {
	return db.MustInitPostgres(cfg)
}

// HealthCheck 检查数据库连接健康状态
// Deprecated: 请使用 db.PostgresHealthCheck
func HealthCheck(d *sql.DB) error {
	return db.PostgresHealthCheck(d)
}

// HealthCheckWithTimeout 带超时的健康检查
// Deprecated: 请使用 db.PostgresHealthCheckWithTimeout
func HealthCheckWithTimeout(ctx context.Context, d *sql.DB, timeout time.Duration) error {
	return db.PostgresHealthCheckWithTimeout(ctx, d, timeout)
}

// TxFunc 事务函数类型
// Deprecated: 请使用 db.TxFunc
type TxFunc = db.TxFunc

// WithTransaction 在事务中执行函数
// Deprecated: 请使用 db.WithTransaction
func WithTransaction(ctx context.Context, d *sql.DB, fn TxFunc) error {
	return db.WithTransaction(ctx, d, fn)
}

// WithTransactionOptions 带选项的事务执行
// Deprecated: 请使用 db.WithTransactionOptions
func WithTransactionOptions(ctx context.Context, d *sql.DB, opts *sql.TxOptions, fn TxFunc) error {
	return db.WithTransactionOptions(ctx, d, opts, fn)
}

// Querier 查询接口
// Deprecated: 请使用 db.Querier
type Querier = db.Querier

// NullString 创建可空字符串
// Deprecated: 请使用 db.NullString
func NullString(s string) sql.NullString {
	return db.NullString(s)
}

// NullInt64 创建可空 int64
// Deprecated: 请使用 db.NullInt64
func NullInt64(i int64) sql.NullInt64 {
	return db.NullInt64(i)
}

// NullFloat64 创建可空 float64
// Deprecated: 请使用 db.NullFloat64
func NullFloat64(f float64) sql.NullFloat64 {
	return db.NullFloat64(f)
}

// NullBool 创建可空 bool
// Deprecated: 请使用 db.NullBool
func NullBool(b bool) sql.NullBool {
	return db.NullBool(b)
}

// NullTime 创建可空时间
// Deprecated: 请使用 db.NullTime
func NullTime(t time.Time) sql.NullTime {
	return db.NullTime(t)
}

// StringFromNull 从可空字符串获取值
// Deprecated: 请使用 db.StringFromNull
func StringFromNull(ns sql.NullString) string {
	return db.StringFromNull(ns)
}

// Int64FromNull 从可空 int64 获取值
// Deprecated: 请使用 db.Int64FromNull
func Int64FromNull(ni sql.NullInt64) int64 {
	return db.Int64FromNull(ni)
}

// Float64FromNull 从可空 float64 获取值
// Deprecated: 请使用 db.Float64FromNull
func Float64FromNull(nf sql.NullFloat64) float64 {
	return db.Float64FromNull(nf)
}

// BoolFromNull 从可空 bool 获取值
// Deprecated: 请使用 db.BoolFromNull
func BoolFromNull(nb sql.NullBool) bool {
	return db.BoolFromNull(nb)
}

// TimeFromNull 从可空时间获取值
// Deprecated: 请使用 db.TimeFromNull
func TimeFromNull(nt sql.NullTime) time.Time {
	return db.TimeFromNull(nt)
}

// BatchInsertBuilder 批量插入构建器
// Deprecated: 请使用 db.BatchInsertBuilder
type BatchInsertBuilder = db.BatchInsertBuilder

// NewBatchInsert 创建批量插入构建器
// Deprecated: 请使用 db.NewBatchInsert
func NewBatchInsert(table string, columns ...string) *BatchInsertBuilder {
	return db.NewBatchInsert(table, columns...)
}

// PoolStats 连接池统计信息
// Deprecated: 请使用 db.PoolStats
type PoolStats = db.PoolStats

// GetPoolStats 获取连接池统计信息
// Deprecated: 请使用 db.GetPoolStats
func GetPoolStats(d *sql.DB) PoolStats {
	return db.GetPoolStats(d)
}
