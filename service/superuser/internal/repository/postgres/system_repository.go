// Package postgres 系统监控 PostgreSQL 仓库实现
package postgres

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"
)

// SystemRepository PostgreSQL 系统仓库
type SystemRepository struct {
	db *sql.DB
}

// NewSystemRepository 创建系统仓库
func NewSystemRepository(db *sql.DB) *SystemRepository {
	return &SystemRepository{db: db}
}

// SystemStats 系统统计信息
type SystemStats struct {
	TotalUsers     int64
	ActiveUsers    int64
	BannedUsers    int64
	TotalContents  int64
	TotalComments  int64
	TotalLikes     int64
	TotalMessages  int64
	StatsAt        time.Time
}

// GetSystemStats 获取系统统计信息
func (r *SystemRepository) GetSystemStats(ctx context.Context) (*SystemStats, error) {
	stats := &SystemStats{StatsAt: time.Now()}

	// 用户统计
	if err := r.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM users`).Scan(&stats.TotalUsers); err != nil {
		return nil, err
	}
	if err := r.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM users WHERE is_active = true`).Scan(&stats.ActiveUsers); err != nil {
		return nil, err
	}
	if err := r.db.QueryRowContext(ctx, `SELECT COUNT(DISTINCT user_id) FROM user_bans WHERE is_active = true`).Scan(&stats.BannedUsers); err != nil {
		return nil, err
	}

	// 内容统计
	if err := r.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM contents`).Scan(&stats.TotalContents); err != nil {
		return nil, err
	}

	// 评论统计
	if err := r.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM comments`).Scan(&stats.TotalComments); err != nil {
		return nil, err
	}

	// 点赞统计
	if err := r.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM likes`).Scan(&stats.TotalLikes); err != nil {
		return nil, err
	}

	return stats, nil
}

// DatabaseStatus 数据库状态
type DatabaseStatus struct {
	Connected         bool
	Version           string
	ActiveConnections int64
	MaxConnections    int64
	DatabaseSizeBytes int64
	Tables            []TableInfo
}

// TableInfo 表信息
type TableInfo struct {
	Name      string
	RowCount  int64
	SizeBytes int64
}

// GetDatabaseStatus 获取数据库状态
func (r *SystemRepository) GetDatabaseStatus(ctx context.Context) (*DatabaseStatus, error) {
	status := &DatabaseStatus{Connected: true}

	// 获取版本
	if err := r.db.QueryRowContext(ctx, `SELECT version()`).Scan(&status.Version); err != nil {
		return nil, err
	}

	// 获取连接数
	if err := r.db.QueryRowContext(ctx, `SELECT count(*) FROM pg_stat_activity`).Scan(&status.ActiveConnections); err != nil {
		return nil, err
	}
	if err := r.db.QueryRowContext(ctx, `SHOW max_connections`).Scan(&status.MaxConnections); err != nil {
		return nil, err
	}

	// 获取数据库大小
	if err := r.db.QueryRowContext(ctx, `SELECT pg_database_size(current_database())`).Scan(&status.DatabaseSizeBytes); err != nil {
		return nil, err
	}

	// 获取表信息
	rows, err := r.db.QueryContext(ctx, `
		SELECT 
			relname as table_name,
			n_live_tup as row_count,
			pg_total_relation_size(relid) as size_bytes
		FROM pg_stat_user_tables
		ORDER BY pg_total_relation_size(relid) DESC
		LIMIT 20
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var info TableInfo
		if err := rows.Scan(&info.Name, &info.RowCount, &info.SizeBytes); err != nil {
			return nil, err
		}
		status.Tables = append(status.Tables, info)
	}

	return status, rows.Err()
}

// TableSchema 表结构
type TableSchema struct {
	TableName string
	Columns   []ColumnInfo
	Indexes   []IndexInfo
}

// ColumnInfo 列信息
type ColumnInfo struct {
	Name         string
	Type         string
	Nullable     bool
	DefaultValue *string
	IsPrimaryKey bool
}

// IndexInfo 索引信息
type IndexInfo struct {
	Name     string
	Columns  []string
	IsUnique bool
}

// GetTableSchema 获取表结构
func (r *SystemRepository) GetTableSchema(ctx context.Context, tableName string) (*TableSchema, error) {
	schema := &TableSchema{TableName: tableName}

	// 获取列信息
	rows, err := r.db.QueryContext(ctx, `
		SELECT 
			c.column_name,
			c.data_type,
			c.is_nullable = 'YES' as nullable,
			c.column_default,
			COALESCE(tc.constraint_type = 'PRIMARY KEY', false) as is_primary_key
		FROM information_schema.columns c
		LEFT JOIN information_schema.key_column_usage kcu 
			ON c.table_name = kcu.table_name AND c.column_name = kcu.column_name
		LEFT JOIN information_schema.table_constraints tc 
			ON kcu.constraint_name = tc.constraint_name AND tc.constraint_type = 'PRIMARY KEY'
		WHERE c.table_name = $1 AND c.table_schema = 'public'
		ORDER BY c.ordinal_position
	`, tableName)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var col ColumnInfo
		if err := rows.Scan(&col.Name, &col.Type, &col.Nullable, &col.DefaultValue, &col.IsPrimaryKey); err != nil {
			return nil, err
		}
		schema.Columns = append(schema.Columns, col)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	// 获取索引信息
	indexRows, err := r.db.QueryContext(ctx, `
		SELECT 
			i.relname as index_name,
			array_agg(a.attname ORDER BY array_position(ix.indkey, a.attnum)) as columns,
			ix.indisunique as is_unique
		FROM pg_class t
		JOIN pg_index ix ON t.oid = ix.indrelid
		JOIN pg_class i ON i.oid = ix.indexrelid
		JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
		WHERE t.relname = $1 AND t.relkind = 'r'
		GROUP BY i.relname, ix.indisunique
	`, tableName)
	if err != nil {
		return nil, err
	}
	defer indexRows.Close()

	for indexRows.Next() {
		var idx IndexInfo
		var columnsStr string
		if err := indexRows.Scan(&idx.Name, &columnsStr, &idx.IsUnique); err != nil {
			return nil, err
		}
		// 解析列名数组
		columnsStr = strings.Trim(columnsStr, "{}")
		if columnsStr != "" {
			idx.Columns = strings.Split(columnsStr, ",")
		}
		schema.Indexes = append(schema.Indexes, idx)
	}

	return schema, indexRows.Err()
}

// ListTables 获取所有表列表
func (r *SystemRepository) ListTables(ctx context.Context, schemaName string) ([]string, error) {
	if schemaName == "" {
		schemaName = "public"
	}

	rows, err := r.db.QueryContext(ctx, `
		SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = $1 AND table_type = 'BASE TABLE'
		ORDER BY table_name
	`, schemaName)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tables []string
	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			return nil, err
		}
		tables = append(tables, name)
	}

	return tables, rows.Err()
}

// QueryResult 查询结果
type QueryResult struct {
	Columns         []string
	Rows            [][]string
	RowCount        int
	ExecutionTimeMs float64
}

// ExecuteQuery 执行只读查询
func (r *SystemRepository) ExecuteQuery(ctx context.Context, query string, limit int) (*QueryResult, error) {
	// 安全检查：只允许 SELECT 语句
	normalizedQuery := strings.ToUpper(strings.TrimSpace(query))
	if !strings.HasPrefix(normalizedQuery, "SELECT") {
		return nil, fmt.Errorf("只允许执行 SELECT 语句")
	}

	// 禁止危险关键字
	dangerousKeywords := []string{"INSERT", "UPDATE", "DELETE", "DROP", "TRUNCATE", "ALTER", "CREATE", "GRANT", "REVOKE"}
	for _, keyword := range dangerousKeywords {
		if strings.Contains(normalizedQuery, keyword) {
			return nil, fmt.Errorf("查询包含禁止的关键字: %s", keyword)
		}
	}

	// 添加 LIMIT
	if limit <= 0 {
		limit = 100
	}
	if limit > 1000 {
		limit = 1000
	}
	if !strings.Contains(normalizedQuery, "LIMIT") {
		query = fmt.Sprintf("%s LIMIT %d", query, limit)
	}

	start := time.Now()
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// 获取列名
	columns, err := rows.Columns()
	if err != nil {
		return nil, err
	}

	result := &QueryResult{
		Columns: columns,
	}

	// 读取数据
	for rows.Next() {
		values := make([]interface{}, len(columns))
		valuePtrs := make([]interface{}, len(columns))
		for i := range values {
			valuePtrs[i] = &values[i]
		}

		if err := rows.Scan(valuePtrs...); err != nil {
			return nil, err
		}

		row := make([]string, len(columns))
		for i, v := range values {
			if v == nil {
				row[i] = "NULL"
			} else {
				row[i] = fmt.Sprintf("%v", v)
			}
		}
		result.Rows = append(result.Rows, row)
	}

	result.RowCount = len(result.Rows)
	result.ExecutionTimeMs = float64(time.Since(start).Microseconds()) / 1000

	return result, rows.Err()
}
