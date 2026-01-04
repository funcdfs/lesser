// Package service SuperUser 服务接口定义
package logic

import (
	"context"
	"time"

	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"github.com/google/uuid"
)

// SuperUserService 超级管理员服务接口
type SuperUserService interface {
	// ========== 认证相关 ==========
	// 登录
	Login(ctx context.Context, username, password, ip string) (*LoginResult, error)
	// 登出
	Logout(ctx context.Context, accessToken string) error
	// 刷新 Token
	RefreshToken(ctx context.Context, refreshToken string) (*LoginResult, error)
	// 验证 Token
	ValidateToken(ctx context.Context, accessToken string) (*TokenInfo, error)

	// ========== 用户管理 ==========
	// 获取用户列表
	ListUsers(ctx context.Context, filter data_access.UserFilter) ([]*data_access.User, int, error)
	// 获取用户详情
	GetUser(ctx context.Context, userID uuid.UUID) (*data_access.User, error)
	// 封禁用户
	BanUser(ctx context.Context, operatorID, userID uuid.UUID, reason string, durationSeconds int64) error
	// 解封用户
	UnbanUser(ctx context.Context, operatorID, userID uuid.UUID) error
	// 删除用户
	DeleteUser(ctx context.Context, operatorID, userID uuid.UUID, hardDelete bool) error
	// 更新用户
	UpdateUser(ctx context.Context, operatorID uuid.UUID, user *data_access.User) (*data_access.User, error)

	// ========== 内容管理 ==========
	// 获取内容列表
	ListContents(ctx context.Context, filter data_access.ContentFilter) ([]*data_access.Content, int, error)
	// 删除内容
	DeleteContent(ctx context.Context, operatorID, contentID uuid.UUID, hardDelete bool) error
	// 批量删除内容
	BatchDeleteContents(ctx context.Context, operatorID uuid.UUID, contentIDs []uuid.UUID, hardDelete bool) (int, []uuid.UUID, error)

	// ========== 系统监控 ==========
	// 获取系统统计
	GetSystemStats(ctx context.Context) (*SystemStats, error)
	// 获取数据库状态
	GetDatabaseStatus(ctx context.Context) (*DatabaseStatus, error)
	// 获取 Redis 状态
	GetRedisStatus(ctx context.Context) (*RedisStatus, error)
	// 获取 RabbitMQ 状态
	GetRabbitMQStatus(ctx context.Context) (*RabbitMQStatus, error)

	// ========== 数据库操作 ==========
	// 执行查询
	ExecuteQuery(ctx context.Context, operatorID uuid.UUID, query string, limit int) (*QueryResult, error)
	// 获取表结构
	GetTableSchema(ctx context.Context, tableName string) (*TableSchema, error)
	// 获取表列表
	ListTables(ctx context.Context, schema string) ([]string, error)

	// ========== 审计日志 ==========
	// 获取审计日志
	GetAuditLogs(ctx context.Context, filter data_access.AuditLogFilter) ([]*data_access.AuditLog, int, error)
}

// LoginResult 登录结果
type LoginResult struct {
	SuperUser    *data_access.SuperUser
	AccessToken  string
	RefreshToken string
}

// TokenInfo Token 信息
type TokenInfo struct {
	Valid       bool
	SuperUserID uuid.UUID
	Username    string
}

// SystemStats 系统统计
type SystemStats struct {
	TotalUsers    int64
	ActiveUsers   int64
	BannedUsers   int64
	TotalContents int64
	TotalComments int64
	TotalLikes    int64
	TotalMessages int64
	StatsAt       time.Time
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

// RedisStatus Redis 状态
type RedisStatus struct {
	Connected        bool
	Version          string
	UsedMemoryBytes  int64
	TotalKeys        int64
	ConnectedClients int64
	UptimeSeconds    float64
}

// RabbitMQStatus RabbitMQ 状态
type RabbitMQStatus struct {
	Connected    bool
	Version      string
	QueueCount   int32
	MessageCount int64
	Queues       []QueueInfo
}

// QueueInfo 队列信息
type QueueInfo struct {
	Name          string
	MessageCount  int64
	ConsumerCount int32
}

// QueryResult 查询结果
type QueryResult struct {
	Columns         []string
	Rows            [][]string
	RowCount        int
	ExecutionTimeMs float64
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
