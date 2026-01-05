package db

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

// ---- 批量操作辅助 ----

// BatchInsertBuilder 批量插入构建器
type BatchInsertBuilder struct {
	table   string
	columns []string
	values  [][]interface{}
}

// NewBatchInsert 创建批量插入构建器
func NewBatchInsert(table string, columns ...string) *BatchInsertBuilder {
	return &BatchInsertBuilder{
		table:   table,
		columns: columns,
		values:  make([][]interface{}, 0),
	}
}

// Add 添加一行数据
func (b *BatchInsertBuilder) Add(values ...interface{}) *BatchInsertBuilder {
	if len(values) == len(b.columns) {
		b.values = append(b.values, values)
	}
	return b
}

// Build 构建 SQL 语句和参数
func (b *BatchInsertBuilder) Build() (string, []interface{}) {
	if len(b.values) == 0 {
		return "", nil
	}

	// 构建列名部分
	query := fmt.Sprintf("INSERT INTO %s (", b.table)
	for i, col := range b.columns {
		if i > 0 {
			query += ", "
		}
		query += col
	}
	query += ") VALUES "

	// 构建值占位符
	args := make([]interface{}, 0, len(b.values)*len(b.columns))
	paramIndex := 1

	for i, row := range b.values {
		if i > 0 {
			query += ", "
		}
		query += "("
		for j := range row {
			if j > 0 {
				query += ", "
			}
			query += fmt.Sprintf("$%d", paramIndex)
			paramIndex++
		}
		query += ")"
		args = append(args, row...)
	}

	return query, args
}

// Execute 执行批量插入
func (b *BatchInsertBuilder) Execute(ctx context.Context, q Querier) (sql.Result, error) {
	query, args := b.Build()
	if query == "" {
		return nil, nil
	}
	return q.ExecContext(ctx, query, args...)
}

// ---- 连接池统计 ----

// PoolStats 连接池统计信息
type PoolStats struct {
	MaxOpenConnections int           // 最大打开连接数
	OpenConnections    int           // 当前打开连接数
	InUse              int           // 使用中的连接数
	Idle               int           // 空闲连接数
	WaitCount          int64         // 等待连接的总次数
	WaitDuration       time.Duration // 等待连接的总时间
	MaxIdleClosed      int64         // 因超过最大空闲数而关闭的连接数
	MaxIdleTimeClosed  int64         // 因空闲超时而关闭的连接数
	MaxLifetimeClosed  int64         // 因生命周期超时而关闭的连接数
}

// GetPoolStats 获取连接池统计信息
func GetPoolStats(db *sql.DB) PoolStats {
	stats := db.Stats()
	return PoolStats{
		MaxOpenConnections: stats.MaxOpenConnections,
		OpenConnections:    stats.OpenConnections,
		InUse:              stats.InUse,
		Idle:               stats.Idle,
		WaitCount:          stats.WaitCount,
		WaitDuration:       stats.WaitDuration,
		MaxIdleClosed:      stats.MaxIdleClosed,
		MaxIdleTimeClosed:  stats.MaxIdleTimeClosed,
		MaxLifetimeClosed:  stats.MaxLifetimeClosed,
	}
}
