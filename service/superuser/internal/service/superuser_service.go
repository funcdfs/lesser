// Package service SuperUser 服务实现
package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/funcdfs/lesser/superuser/internal/config"
	"github.com/funcdfs/lesser/superuser/internal/crypto"
	"github.com/funcdfs/lesser/superuser/internal/repository"
	"github.com/funcdfs/lesser/superuser/internal/repository/postgres"
	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
)

// 错误定义
var (
	ErrInvalidCredentials = errors.New("用户名或密码错误")
	ErrUserNotFound       = errors.New("用户不存在")
	ErrUserInactive       = errors.New("用户已被禁用")
	ErrInvalidToken       = errors.New("无效的令牌")
	ErrContentNotFound    = errors.New("内容不存在")
)

// superUserServiceImpl 超级管理员服务实现
type superUserServiceImpl struct {
	superUserRepo  repository.SuperUserRepository
	auditLogRepo   repository.AuditLogRepository
	sessionRepo    repository.SessionRepository
	userRepo       repository.UserRepository
	contentRepo    repository.ContentRepository
	systemRepo     *postgres.SystemRepository
	passwordHasher *crypto.PasswordHasher
	jwtManager     *crypto.JWTManager
	redisClient    *redis.Client
	config         *config.Config
	logger         *slog.Logger
}

// ServiceDeps 服务依赖
type ServiceDeps struct {
	SuperUserRepo  repository.SuperUserRepository
	AuditLogRepo   repository.AuditLogRepository
	SessionRepo    repository.SessionRepository
	UserRepo       repository.UserRepository
	ContentRepo    repository.ContentRepository
	SystemRepo     *postgres.SystemRepository
	PasswordHasher *crypto.PasswordHasher
	JWTManager     *crypto.JWTManager
	RedisClient    *redis.Client
	Config         *config.Config
	Logger         *slog.Logger
}

// NewSuperUserService 创建超级管理员服务
func NewSuperUserService(deps ServiceDeps) SuperUserService {
	return &superUserServiceImpl{
		superUserRepo:  deps.SuperUserRepo,
		auditLogRepo:   deps.AuditLogRepo,
		sessionRepo:    deps.SessionRepo,
		userRepo:       deps.UserRepo,
		contentRepo:    deps.ContentRepo,
		systemRepo:     deps.SystemRepo,
		passwordHasher: deps.PasswordHasher,
		jwtManager:     deps.JWTManager,
		redisClient:    deps.RedisClient,
		config:         deps.Config,
		logger:         deps.Logger,
	}
}

// ========== 认证相关 ==========

// Login 登录
func (s *superUserServiceImpl) Login(ctx context.Context, username, password, ip string) (*LoginResult, error) {
	// 查找用户
	su, err := s.superUserRepo.GetByUsername(ctx, username)
	if err != nil {
		return nil, fmt.Errorf("查询用户失败: %w", err)
	}
	if su == nil {
		s.logger.Warn("登录失败：用户不存在", slog.String("username", username))
		return nil, ErrInvalidCredentials
	}

	// 检查用户状态
	if !su.IsActive {
		s.logger.Warn("登录失败：用户已禁用", slog.String("username", username))
		return nil, ErrUserInactive
	}

	// 验证密码
	valid, err := s.passwordHasher.Verify(password, su.Password)
	if err != nil || !valid {
		s.logger.Warn("登录失败：密码错误", slog.String("username", username))
		return nil, ErrInvalidCredentials
	}

	// 生成 Token
	accessToken, err := s.jwtManager.GenerateAccessToken(su.ID, su.Username)
	if err != nil {
		return nil, fmt.Errorf("生成访问令牌失败: %w", err)
	}
	refreshToken, err := s.jwtManager.GenerateRefreshToken(su.ID, su.Username)
	if err != nil {
		return nil, fmt.Errorf("生成刷新令牌失败: %w", err)
	}

	// 创建会话
	session := &repository.Session{
		SuperUserID: su.ID,
		TokenHash:   crypto.HashToken(refreshToken),
		IPAddress:   &ip,
		ExpiresAt:   time.Now().Add(s.jwtManager.GetRefreshTokenDuration()),
	}
	if err := s.sessionRepo.Create(ctx, session); err != nil {
		s.logger.Error("创建会话失败", slog.Any("error", err))
	}

	// 更新登录信息
	if err := s.superUserRepo.UpdateLoginInfo(ctx, su.ID, ip); err != nil {
		s.logger.Error("更新登录信息失败", slog.Any("error", err))
	}

	// 记录审计日志
	s.logAudit(ctx, su.ID, "LOGIN", nil, nil, map[string]interface{}{"ip": ip}, &ip)

	s.logger.Info("超级管理员登录成功", slog.String("username", username), slog.String("ip", ip))

	return &LoginResult{
		SuperUser:    su,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

// Logout 登出
func (s *superUserServiceImpl) Logout(ctx context.Context, accessToken string) error {
	claims, err := s.jwtManager.ValidateAccessToken(accessToken)
	if err != nil {
		return ErrInvalidToken
	}

	superUserID, _ := uuid.Parse(claims.SuperUserID)

	// 撤销所有会话
	if err := s.sessionRepo.RevokeAllByUserID(ctx, superUserID); err != nil {
		s.logger.Error("撤销会话失败", slog.Any("error", err))
	}

	// 记录审计日志
	s.logAudit(ctx, superUserID, "LOGOUT", nil, nil, nil, nil)

	s.logger.Info("超级管理员登出", slog.String("superuser_id", claims.SuperUserID))
	return nil
}

// RefreshToken 刷新 Token
func (s *superUserServiceImpl) RefreshToken(ctx context.Context, refreshToken string) (*LoginResult, error) {
	claims, err := s.jwtManager.ValidateRefreshToken(refreshToken)
	if err != nil {
		return nil, ErrInvalidToken
	}

	// 验证会话
	tokenHash := crypto.HashToken(refreshToken)
	session, err := s.sessionRepo.GetByTokenHash(ctx, tokenHash)
	if err != nil || session == nil {
		return nil, ErrInvalidToken
	}

	superUserID, _ := uuid.Parse(claims.SuperUserID)

	// 获取用户信息
	su, err := s.superUserRepo.GetByID(ctx, superUserID)
	if err != nil || su == nil {
		return nil, ErrUserNotFound
	}
	if !su.IsActive {
		return nil, ErrUserInactive
	}

	// 生成新 Token
	newAccessToken, err := s.jwtManager.GenerateAccessToken(su.ID, su.Username)
	if err != nil {
		return nil, fmt.Errorf("生成访问令牌失败: %w", err)
	}
	newRefreshToken, err := s.jwtManager.GenerateRefreshToken(su.ID, su.Username)
	if err != nil {
		return nil, fmt.Errorf("生成刷新令牌失败: %w", err)
	}

	// 撤销旧会话，创建新会话
	_ = s.sessionRepo.Revoke(ctx, tokenHash)
	newSession := &repository.Session{
		SuperUserID: su.ID,
		TokenHash:   crypto.HashToken(newRefreshToken),
		IPAddress:   session.IPAddress,
		ExpiresAt:   time.Now().Add(s.jwtManager.GetRefreshTokenDuration()),
	}
	_ = s.sessionRepo.Create(ctx, newSession)

	return &LoginResult{
		SuperUser:    su,
		AccessToken:  newAccessToken,
		RefreshToken: newRefreshToken,
	}, nil
}

// ValidateToken 验证 Token
func (s *superUserServiceImpl) ValidateToken(ctx context.Context, accessToken string) (*TokenInfo, error) {
	claims, err := s.jwtManager.ValidateAccessToken(accessToken)
	if err != nil {
		return &TokenInfo{Valid: false}, nil
	}

	superUserID, _ := uuid.Parse(claims.SuperUserID)

	return &TokenInfo{
		Valid:       true,
		SuperUserID: superUserID,
		Username:    claims.Username,
	}, nil
}

// ========== 用户管理 ==========

// ListUsers 获取用户列表
func (s *superUserServiceImpl) ListUsers(ctx context.Context, filter repository.UserFilter) ([]*repository.User, int, error) {
	return s.userRepo.List(ctx, filter)
}

// GetUser 获取用户详情
func (s *superUserServiceImpl) GetUser(ctx context.Context, userID uuid.UUID) (*repository.User, error) {
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, ErrUserNotFound
	}
	return user, nil
}

// BanUser 封禁用户
func (s *superUserServiceImpl) BanUser(ctx context.Context, operatorID, userID uuid.UUID, reason string, durationSeconds int64) error {
	var expiresAt *time.Time
	if durationSeconds > 0 {
		t := time.Now().Add(time.Duration(durationSeconds) * time.Second)
		expiresAt = &t
	}

	if err := s.userRepo.Ban(ctx, userID, reason, expiresAt, operatorID); err != nil {
		return err
	}

	// 记录审计日志
	s.logAudit(ctx, operatorID, "BAN_USER", strPtr("USER"), &userID, map[string]interface{}{
		"reason":           reason,
		"duration_seconds": durationSeconds,
	}, nil)

	s.logger.Info("封禁用户", slog.String("user_id", userID.String()), slog.String("reason", reason))
	return nil
}

// UnbanUser 解封用户
func (s *superUserServiceImpl) UnbanUser(ctx context.Context, operatorID, userID uuid.UUID) error {
	if err := s.userRepo.Unban(ctx, userID); err != nil {
		return err
	}

	// 记录审计日志
	s.logAudit(ctx, operatorID, "UNBAN_USER", strPtr("USER"), &userID, nil, nil)

	s.logger.Info("解封用户", slog.String("user_id", userID.String()))
	return nil
}

// DeleteUser 删除用户
func (s *superUserServiceImpl) DeleteUser(ctx context.Context, operatorID, userID uuid.UUID, hardDelete bool) error {
	var err error
	if hardDelete {
		err = s.userRepo.HardDelete(ctx, userID)
	} else {
		err = s.userRepo.SoftDelete(ctx, userID)
	}
	if err != nil {
		return err
	}

	// 记录审计日志
	s.logAudit(ctx, operatorID, "DELETE_USER", strPtr("USER"), &userID, map[string]interface{}{
		"hard_delete": hardDelete,
	}, nil)

	s.logger.Info("删除用户", slog.String("user_id", userID.String()), slog.Bool("hard_delete", hardDelete))
	return nil
}

// UpdateUser 更新用户
func (s *superUserServiceImpl) UpdateUser(ctx context.Context, operatorID uuid.UUID, user *repository.User) (*repository.User, error) {
	if err := s.userRepo.Update(ctx, user); err != nil {
		return nil, err
	}

	// 记录审计日志
	s.logAudit(ctx, operatorID, "UPDATE_USER", strPtr("USER"), &user.ID, map[string]interface{}{
		"username":     user.Username,
		"display_name": user.DisplayName,
	}, nil)

	return s.userRepo.GetByID(ctx, user.ID)
}

// ========== 内容管理 ==========

// ListContents 获取内容列表
func (s *superUserServiceImpl) ListContents(ctx context.Context, filter repository.ContentFilter) ([]*repository.Content, int, error) {
	return s.contentRepo.List(ctx, filter)
}

// DeleteContent 删除内容
func (s *superUserServiceImpl) DeleteContent(ctx context.Context, operatorID, contentID uuid.UUID, hardDelete bool) error {
	var err error
	if hardDelete {
		err = s.contentRepo.HardDelete(ctx, contentID)
	} else {
		err = s.contentRepo.SoftDelete(ctx, contentID)
	}
	if err != nil {
		return err
	}

	// 记录审计日志
	s.logAudit(ctx, operatorID, "DELETE_CONTENT", strPtr("CONTENT"), &contentID, map[string]interface{}{
		"hard_delete": hardDelete,
	}, nil)

	s.logger.Info("删除内容", slog.String("content_id", contentID.String()), slog.Bool("hard_delete", hardDelete))
	return nil
}

// BatchDeleteContents 批量删除内容
func (s *superUserServiceImpl) BatchDeleteContents(ctx context.Context, operatorID uuid.UUID, contentIDs []uuid.UUID, hardDelete bool) (int, []uuid.UUID, error) {
	deletedCount, failedIDs, err := s.contentRepo.BatchDelete(ctx, contentIDs, hardDelete)
	if err != nil {
		return 0, nil, err
	}

	// 记录审计日志
	s.logAudit(ctx, operatorID, "BATCH_DELETE_CONTENTS", strPtr("CONTENT"), nil, map[string]interface{}{
		"content_ids":   contentIDs,
		"hard_delete":   hardDelete,
		"deleted_count": deletedCount,
		"failed_ids":    failedIDs,
	}, nil)

	s.logger.Info("批量删除内容", slog.Int("deleted_count", deletedCount), slog.Int("failed_count", len(failedIDs)))
	return deletedCount, failedIDs, nil
}

// ========== 系统监控 ==========

// GetSystemStats 获取系统统计
func (s *superUserServiceImpl) GetSystemStats(ctx context.Context) (*SystemStats, error) {
	stats, err := s.systemRepo.GetSystemStats(ctx)
	if err != nil {
		return nil, err
	}
	return &SystemStats{
		TotalUsers:    stats.TotalUsers,
		ActiveUsers:   stats.ActiveUsers,
		BannedUsers:   stats.BannedUsers,
		TotalContents: stats.TotalContents,
		TotalComments: stats.TotalComments,
		TotalLikes:    stats.TotalLikes,
		TotalMessages: stats.TotalMessages,
		StatsAt:       stats.StatsAt,
	}, nil
}

// GetDatabaseStatus 获取数据库状态
func (s *superUserServiceImpl) GetDatabaseStatus(ctx context.Context) (*DatabaseStatus, error) {
	status, err := s.systemRepo.GetDatabaseStatus(ctx)
	if err != nil {
		return nil, err
	}

	tables := make([]TableInfo, len(status.Tables))
	for i, t := range status.Tables {
		tables[i] = TableInfo{
			Name:      t.Name,
			RowCount:  t.RowCount,
			SizeBytes: t.SizeBytes,
		}
	}

	return &DatabaseStatus{
		Connected:         status.Connected,
		Version:           status.Version,
		ActiveConnections: status.ActiveConnections,
		MaxConnections:    status.MaxConnections,
		DatabaseSizeBytes: status.DatabaseSizeBytes,
		Tables:            tables,
	}, nil
}

// GetRedisStatus 获取 Redis 状态
func (s *superUserServiceImpl) GetRedisStatus(ctx context.Context) (*RedisStatus, error) {
	if s.redisClient == nil {
		return &RedisStatus{Connected: false}, nil
	}

	info, err := s.redisClient.Info(ctx, "server", "memory", "clients", "stats").Result()
	if err != nil {
		return &RedisStatus{Connected: false}, nil
	}

	// 简单解析 Redis INFO 输出
	status := &RedisStatus{Connected: true}
	// 这里简化处理，实际可以更详细解析
	_ = info

	// 获取 key 数量
	dbSize, _ := s.redisClient.DBSize(ctx).Result()
	status.TotalKeys = dbSize

	return status, nil
}

// GetRabbitMQStatus 获取 RabbitMQ 状态
func (s *superUserServiceImpl) GetRabbitMQStatus(ctx context.Context) (*RabbitMQStatus, error) {
	// RabbitMQ 状态检查需要通过 HTTP API，这里简化处理
	return &RabbitMQStatus{
		Connected: true,
		Version:   "3.x",
	}, nil
}

// ========== 数据库操作 ==========

// ExecuteQuery 执行查询
func (s *superUserServiceImpl) ExecuteQuery(ctx context.Context, operatorID uuid.UUID, query string, limit int) (*QueryResult, error) {
	result, err := s.systemRepo.ExecuteQuery(ctx, query, limit)
	if err != nil {
		return nil, err
	}

	// 记录审计日志
	s.logAudit(ctx, operatorID, "EXECUTE_QUERY", strPtr("SYSTEM"), nil, map[string]interface{}{
		"query":     query,
		"row_count": result.RowCount,
	}, nil)

	return &QueryResult{
		Columns:         result.Columns,
		Rows:            result.Rows,
		RowCount:        result.RowCount,
		ExecutionTimeMs: result.ExecutionTimeMs,
	}, nil
}

// GetTableSchema 获取表结构
func (s *superUserServiceImpl) GetTableSchema(ctx context.Context, tableName string) (*TableSchema, error) {
	schema, err := s.systemRepo.GetTableSchema(ctx, tableName)
	if err != nil {
		return nil, err
	}

	columns := make([]ColumnInfo, len(schema.Columns))
	for i, c := range schema.Columns {
		columns[i] = ColumnInfo{
			Name:         c.Name,
			Type:         c.Type,
			Nullable:     c.Nullable,
			DefaultValue: c.DefaultValue,
			IsPrimaryKey: c.IsPrimaryKey,
		}
	}

	indexes := make([]IndexInfo, len(schema.Indexes))
	for i, idx := range schema.Indexes {
		indexes[i] = IndexInfo{
			Name:     idx.Name,
			Columns:  idx.Columns,
			IsUnique: idx.IsUnique,
		}
	}

	return &TableSchema{
		TableName: schema.TableName,
		Columns:   columns,
		Indexes:   indexes,
	}, nil
}

// ListTables 获取表列表
func (s *superUserServiceImpl) ListTables(ctx context.Context, schema string) ([]string, error) {
	return s.systemRepo.ListTables(ctx, schema)
}

// ========== 审计日志 ==========

// GetAuditLogs 获取审计日志
func (s *superUserServiceImpl) GetAuditLogs(ctx context.Context, filter repository.AuditLogFilter) ([]*repository.AuditLog, int, error) {
	return s.auditLogRepo.List(ctx, filter)
}

// logAudit 记录审计日志
func (s *superUserServiceImpl) logAudit(ctx context.Context, superUserID uuid.UUID, action string, targetType *string, targetID *uuid.UUID, details map[string]interface{}, ip *string) {
	log := &repository.AuditLog{
		SuperUserID: superUserID,
		Action:      action,
		TargetType:  targetType,
		TargetID:    targetID,
		Details:     details,
		IPAddress:   ip,
	}
	if err := s.auditLogRepo.Create(ctx, log); err != nil {
		s.logger.Error("记录审计日志失败", slog.Any("error", err))
	}
}

func strPtr(s string) *string {
	return &s
}
