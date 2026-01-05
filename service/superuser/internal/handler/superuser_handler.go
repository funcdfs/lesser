// Package handler SuperUser gRPC 处理器
package handler

import (
	"context"
	"strings"
	"time"

	commonpb "github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
	pb "github.com/funcdfs/lesser/superuser/gen_protos/superuser"
	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"github.com/funcdfs/lesser/superuser/internal/logic"
	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// SuperUserHandler gRPC 处理器
type SuperUserHandler struct {
	pb.UnimplementedSuperUserServiceServer
	logic  logic.SuperUserService
	logger *log.Logger
}

// NewSuperUserHandler 创建处理器
func NewSuperUserHandler(svc logic.SuperUserService, logger *log.Logger) *SuperUserHandler {
	return &SuperUserHandler{
		logic:  svc,
		logger: logger,
	}
}

// ========== 认证相关 ==========

// Login 登录
func (h *SuperUserHandler) Login(ctx context.Context, req *pb.SuperUserLoginRequest) (*pb.SuperUserLoginResponse, error) {
	if req.Username == "" || req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "用户名和密码不能为空")
	}

	ip := h.getClientIP(ctx)
	result, err := h.logic.Login(ctx, req.Username, req.Password, ip)
	if err != nil {
		h.logger.Error("登录失败",
			log.String("username", req.Username),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.SuperUserLoginResponse{
		Superuser:    h.toSuperUserPB(result.SuperUser),
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	}, nil
}

// Logout 登出
func (h *SuperUserHandler) Logout(ctx context.Context, req *pb.SuperUserLogoutRequest) (*commonpb.Empty, error) {
	if req.AccessToken == "" {
		return nil, status.Error(codes.InvalidArgument, "访问令牌不能为空")
	}

	if err := h.logic.Logout(ctx, req.AccessToken); err != nil {
		h.logger.Error("登出失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &commonpb.Empty{}, nil
}

// RefreshToken 刷新 Token
func (h *SuperUserHandler) RefreshToken(ctx context.Context, req *pb.SuperUserRefreshRequest) (*pb.SuperUserLoginResponse, error) {
	if req.RefreshToken == "" {
		return nil, status.Error(codes.InvalidArgument, "刷新令牌不能为空")
	}

	result, err := h.logic.RefreshToken(ctx, req.RefreshToken)
	if err != nil {
		h.logger.Error("刷新 Token 失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.SuperUserLoginResponse{
		Superuser:    h.toSuperUserPB(result.SuperUser),
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	}, nil
}

// ValidateToken 验证 Token
func (h *SuperUserHandler) ValidateToken(ctx context.Context, req *pb.ValidateTokenRequest) (*pb.ValidateTokenResponse, error) {
	if req.AccessToken == "" {
		return &pb.ValidateTokenResponse{Valid: false}, nil
	}

	info, err := h.logic.ValidateToken(ctx, req.AccessToken)
	if err != nil {
		return &pb.ValidateTokenResponse{Valid: false}, nil
	}

	return &pb.ValidateTokenResponse{
		Valid:       info.Valid,
		SuperuserId: info.SuperUserID.String(),
		Username:    info.Username,
	}, nil
}

// ========== 用户管理 ==========

// ListUsers 获取用户列表
func (h *SuperUserHandler) ListUsers(ctx context.Context, req *pb.ListUsersRequest) (*pb.ListUsersResponse, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	filter := data_access.UserFilter{
		Page:      int(req.Page),
		PageSize:  int(req.PageSize),
		SortBy:    req.SortBy,
		SortOrder: req.SortOrder,
	}
	if req.Search != "" {
		filter.Search = &req.Search
	}
	if req.Status != "" {
		filter.Status = &req.Status
	}

	users, total, err := h.logic.ListUsers(ctx, filter)
	if err != nil {
		h.logger.Error("获取用户列表失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	pbUsers := make([]*pb.UserDetail, len(users))
	for i, u := range users {
		pbUsers[i] = h.toUserDetailPB(u)
	}

	return &pb.ListUsersResponse{
		Users:    pbUsers,
		Total:    int32(total),
		Page:     req.Page,
		PageSize: req.PageSize,
	}, nil
}

// GetUser 获取用户详情
func (h *SuperUserHandler) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.UserDetail, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "无效的用户 ID")
	}

	user, err := h.logic.GetUser(ctx, userID)
	if err != nil {
		h.logger.Error("获取用户详情失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return h.toUserDetailPB(user), nil
}

// BanUser 封禁用户
func (h *SuperUserHandler) BanUser(ctx context.Context, req *pb.BanUserRequest) (*pb.BanUserResponse, error) {
	operatorID, err := h.validateAuth(ctx)
	if err != nil {
		return nil, err
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "无效的用户 ID")
	}

	if err := h.logic.BanUser(ctx, operatorID, userID, req.Reason, req.DurationSeconds); err != nil {
		h.logger.Error("封禁用户失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.BanUserResponse{Success: true, Message: "用户已封禁"}, nil
}

// UnbanUser 解封用户
func (h *SuperUserHandler) UnbanUser(ctx context.Context, req *pb.UnbanUserRequest) (*pb.UnbanUserResponse, error) {
	operatorID, err := h.validateAuth(ctx)
	if err != nil {
		return nil, err
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "无效的用户 ID")
	}

	if err := h.logic.UnbanUser(ctx, operatorID, userID); err != nil {
		h.logger.Error("解封用户失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.UnbanUserResponse{Success: true, Message: "用户已解封"}, nil
}

// DeleteUser 删除用户
func (h *SuperUserHandler) DeleteUser(ctx context.Context, req *pb.DeleteUserRequest) (*pb.DeleteUserResponse, error) {
	operatorID, err := h.validateAuth(ctx)
	if err != nil {
		return nil, err
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "无效的用户 ID")
	}

	if err := h.logic.DeleteUser(ctx, operatorID, userID, req.HardDelete); err != nil {
		h.logger.Error("删除用户失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.DeleteUserResponse{Success: true, Message: "用户已删除"}, nil
}

// UpdateUser 更新用户
func (h *SuperUserHandler) UpdateUser(ctx context.Context, req *pb.UpdateUserRequest) (*pb.UserDetail, error) {
	operatorID, err := h.validateAuth(ctx)
	if err != nil {
		return nil, err
	}

	userID, err := uuid.Parse(req.UserId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "无效的用户 ID")
	}

	// 获取现有用户
	user, err := h.logic.GetUser(ctx, userID)
	if err != nil {
		h.logger.Error("获取用户失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	// 更新字段
	if req.Username != nil {
		user.Username = *req.Username
	}
	if req.Email != nil {
		user.Email = *req.Email
	}
	if req.DisplayName != nil {
		user.DisplayName = *req.DisplayName
	}
	if req.Bio != nil {
		user.Bio = *req.Bio
	}
	if req.IsActive != nil {
		user.IsActive = *req.IsActive
	}

	updatedUser, err := h.logic.UpdateUser(ctx, operatorID, user)
	if err != nil {
		h.logger.Error("更新用户失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return h.toUserDetailPB(updatedUser), nil
}

// ========== 内容管理 ==========

// ListContents 获取内容列表
func (h *SuperUserHandler) ListContents(ctx context.Context, req *pb.ListContentsRequest) (*pb.ListContentsResponse, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	filter := data_access.ContentFilter{
		Page:      int(req.Page),
		PageSize:  int(req.PageSize),
		SortBy:    req.SortBy,
		SortOrder: req.SortOrder,
	}
	if req.AuthorId != "" {
		authorID, _ := uuid.Parse(req.AuthorId)
		filter.AuthorID = &authorID
	}
	if req.Type != 0 {
		t := int(req.Type)
		filter.Type = &t
	}
	if req.Status != 0 {
		s := int(req.Status)
		filter.Status = &s
	}
	if req.Search != "" {
		filter.Search = &req.Search
	}

	contents, total, err := h.logic.ListContents(ctx, filter)
	if err != nil {
		h.logger.Error("获取内容列表失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	pbContents := make([]*pb.ContentDetail, len(contents))
	for i, c := range contents {
		pbContents[i] = h.toContentDetailPB(c)
	}

	return &pb.ListContentsResponse{
		Contents: pbContents,
		Total:    int32(total),
		Page:     req.Page,
		PageSize: req.PageSize,
	}, nil
}

// DeleteContent 删除内容
func (h *SuperUserHandler) DeleteContent(ctx context.Context, req *pb.DeleteContentRequest) (*pb.DeleteContentResponse, error) {
	operatorID, err := h.validateAuth(ctx)
	if err != nil {
		return nil, err
	}

	contentID, err := uuid.Parse(req.ContentId)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "无效的内容 ID")
	}

	if err := h.logic.DeleteContent(ctx, operatorID, contentID, req.HardDelete); err != nil {
		h.logger.Error("删除内容失败",
			log.String("content_id", req.ContentId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.DeleteContentResponse{Success: true, Message: "内容已删除"}, nil
}

// BatchDeleteContents 批量删除内容
func (h *SuperUserHandler) BatchDeleteContents(ctx context.Context, req *pb.BatchDeleteContentsRequest) (*pb.BatchDeleteContentsResponse, error) {
	operatorID, err := h.validateAuth(ctx)
	if err != nil {
		return nil, err
	}

	contentIDs := make([]uuid.UUID, len(req.ContentIds))
	for i, id := range req.ContentIds {
		contentIDs[i], _ = uuid.Parse(id)
	}

	deletedCount, failedIDs, err := h.logic.BatchDeleteContents(ctx, operatorID, contentIDs, req.HardDelete)
	if err != nil {
		h.logger.Error("批量删除内容失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	failedIDStrs := make([]string, len(failedIDs))
	for i, id := range failedIDs {
		failedIDStrs[i] = id.String()
	}

	return &pb.BatchDeleteContentsResponse{
		DeletedCount: int32(deletedCount),
		FailedIds:    failedIDStrs,
		Message:      "批量删除完成",
	}, nil
}

// ========== 系统监控 ==========

// GetSystemStats 获取系统统计
func (h *SuperUserHandler) GetSystemStats(ctx context.Context, req *pb.GetSystemStatsRequest) (*pb.SystemStats, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	stats, err := h.logic.GetSystemStats(ctx)
	if err != nil {
		h.logger.Error("获取系统统计失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.SystemStats{
		TotalUsers:    stats.TotalUsers,
		ActiveUsers:   stats.ActiveUsers,
		BannedUsers:   stats.BannedUsers,
		TotalContents: stats.TotalContents,
		TotalComments: stats.TotalComments,
		TotalLikes:    stats.TotalLikes,
		TotalMessages: stats.TotalMessages,
		StatsAt:       toTimestampPB(stats.StatsAt),
	}, nil
}

// GetDatabaseStatus 获取数据库状态
func (h *SuperUserHandler) GetDatabaseStatus(ctx context.Context, req *pb.GetDatabaseStatusRequest) (*pb.DatabaseStatus, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	dbStatus, err := h.logic.GetDatabaseStatus(ctx)
	if err != nil {
		h.logger.Error("获取数据库状态失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	tables := make([]*pb.TableInfo, len(dbStatus.Tables))
	for i, t := range dbStatus.Tables {
		tables[i] = &pb.TableInfo{
			Name:      t.Name,
			RowCount:  t.RowCount,
			SizeBytes: t.SizeBytes,
		}
	}

	return &pb.DatabaseStatus{
		Connected:         dbStatus.Connected,
		Version:           dbStatus.Version,
		ActiveConnections: dbStatus.ActiveConnections,
		MaxConnections:    dbStatus.MaxConnections,
		DatabaseSizeBytes: dbStatus.DatabaseSizeBytes,
		Tables:            tables,
	}, nil
}

// GetRedisStatus 获取 Redis 状态
func (h *SuperUserHandler) GetRedisStatus(ctx context.Context, req *pb.GetRedisStatusRequest) (*pb.RedisStatus, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	redisStatus, err := h.logic.GetRedisStatus(ctx)
	if err != nil {
		h.logger.Error("获取 Redis 状态失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.RedisStatus{
		Connected:        redisStatus.Connected,
		Version:          redisStatus.Version,
		UsedMemoryBytes:  redisStatus.UsedMemoryBytes,
		TotalKeys:        redisStatus.TotalKeys,
		ConnectedClients: redisStatus.ConnectedClients,
		UptimeSeconds:    redisStatus.UptimeSeconds,
	}, nil
}

// GetRabbitMQStatus 获取 RabbitMQ 状态
func (h *SuperUserHandler) GetRabbitMQStatus(ctx context.Context, req *pb.GetRabbitMQStatusRequest) (*pb.RabbitMQStatus, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	mqStatus, err := h.logic.GetRabbitMQStatus(ctx)
	if err != nil {
		h.logger.Error("获取 RabbitMQ 状态失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	queues := make([]*pb.QueueInfo, len(mqStatus.Queues))
	for i, q := range mqStatus.Queues {
		queues[i] = &pb.QueueInfo{
			Name:          q.Name,
			MessageCount:  q.MessageCount,
			ConsumerCount: q.ConsumerCount,
		}
	}

	return &pb.RabbitMQStatus{
		Connected:    mqStatus.Connected,
		Version:      mqStatus.Version,
		QueueCount:   mqStatus.QueueCount,
		MessageCount: mqStatus.MessageCount,
		Queues:       queues,
	}, nil
}

// ========== 数据库操作 ==========

// ExecuteQuery 执行查询
func (h *SuperUserHandler) ExecuteQuery(ctx context.Context, req *pb.ExecuteQueryRequest) (*pb.ExecuteQueryResponse, error) {
	operatorID, err := h.validateAuth(ctx)
	if err != nil {
		return nil, err
	}

	if req.Query == "" {
		return nil, status.Error(codes.InvalidArgument, "查询语句不能为空")
	}

	result, err := h.logic.ExecuteQuery(ctx, operatorID, req.Query, int(req.Limit))
	if err != nil {
		h.logger.Error("执行查询失败",
			log.String("query", req.Query),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	rows := make([]*pb.QueryRow, len(result.Rows))
	for i, r := range result.Rows {
		rows[i] = &pb.QueryRow{Values: r}
	}

	return &pb.ExecuteQueryResponse{
		Columns:         result.Columns,
		Rows:            rows,
		RowCount:        int32(result.RowCount),
		ExecutionTimeMs: result.ExecutionTimeMs,
	}, nil
}

// GetTableSchema 获取表结构
func (h *SuperUserHandler) GetTableSchema(ctx context.Context, req *pb.GetTableSchemaRequest) (*pb.TableSchema, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	if req.TableName == "" {
		return nil, status.Error(codes.InvalidArgument, "表名不能为空")
	}

	schema, err := h.logic.GetTableSchema(ctx, req.TableName)
	if err != nil {
		h.logger.Error("获取表结构失败",
			log.String("table_name", req.TableName),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	columns := make([]*pb.ColumnInfo, len(schema.Columns))
	for i, c := range schema.Columns {
		columns[i] = &pb.ColumnInfo{
			Name:         c.Name,
			Type:         c.Type,
			Nullable:     c.Nullable,
			IsPrimaryKey: c.IsPrimaryKey,
		}
		if c.DefaultValue != nil {
			columns[i].DefaultValue = *c.DefaultValue
		}
	}

	indexes := make([]*pb.IndexInfo, len(schema.Indexes))
	for i, idx := range schema.Indexes {
		indexes[i] = &pb.IndexInfo{
			Name:     idx.Name,
			Columns:  idx.Columns,
			IsUnique: idx.IsUnique,
		}
	}

	return &pb.TableSchema{
		TableName: schema.TableName,
		Columns:   columns,
		Indexes:   indexes,
	}, nil
}

// ListTables 获取表列表
func (h *SuperUserHandler) ListTables(ctx context.Context, req *pb.ListTablesRequest) (*pb.ListTablesResponse, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	tables, err := h.logic.ListTables(ctx, req.Schema)
	if err != nil {
		h.logger.Error("获取表列表失败",
			log.String("schema", req.Schema),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.ListTablesResponse{Tables: tables}, nil
}

// ========== 审计日志 ==========

// GetAuditLogs 获取审计日志
func (h *SuperUserHandler) GetAuditLogs(ctx context.Context, req *pb.GetAuditLogsRequest) (*pb.AuditLogsResponse, error) {
	if _, err := h.validateAuth(ctx); err != nil {
		return nil, err
	}

	filter := data_access.AuditLogFilter{
		Page:     int(req.Page),
		PageSize: int(req.PageSize),
	}
	if req.SuperuserId != "" {
		id, _ := uuid.Parse(req.SuperuserId)
		filter.SuperUserID = &id
	}
	if req.Action != "" {
		filter.Action = &req.Action
	}

	logs, total, err := h.logic.GetAuditLogs(ctx, filter)
	if err != nil {
		h.logger.Error("获取审计日志失败",
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	pbLogs := make([]*pb.AuditLog, len(logs))
	for i, l := range logs {
		pbLogs[i] = h.toAuditLogPB(l)
	}

	return &pb.AuditLogsResponse{
		Logs:     pbLogs,
		Total:    int32(total),
		Page:     req.Page,
		PageSize: req.PageSize,
	}, nil
}

// ========== 辅助方法 ==========

// validateAuth 验证认证
func (h *SuperUserHandler) validateAuth(ctx context.Context) (uuid.UUID, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return uuid.Nil, status.Error(codes.Unauthenticated, "缺少认证信息")
	}

	authHeader := md.Get("authorization")
	if len(authHeader) == 0 {
		return uuid.Nil, status.Error(codes.Unauthenticated, "缺少认证令牌")
	}

	token := strings.TrimPrefix(authHeader[0], "Bearer ")
	info, err := h.logic.ValidateToken(ctx, token)
	if err != nil || !info.Valid {
		return uuid.Nil, status.Error(codes.Unauthenticated, "无效的认证令牌")
	}

	return info.SuperUserID, nil
}

// getClientIP 获取客户端 IP
func (h *SuperUserHandler) getClientIP(ctx context.Context) string {
	md, ok := metadata.FromIncomingContext(ctx)
	if ok {
		if xff := md.Get("x-forwarded-for"); len(xff) > 0 {
			return strings.Split(xff[0], ",")[0]
		}
		if xri := md.Get("x-real-ip"); len(xri) > 0 {
			return xri[0]
		}
	}
	return "unknown"
}

// toSuperUserPB 转换为 protobuf SuperUser
func (h *SuperUserHandler) toSuperUserPB(su *data_access.SuperUser) *pb.SuperUser {
	result := &pb.SuperUser{
		Id:          su.ID.String(),
		Username:    su.Username,
		Email:       su.Email,
		DisplayName: su.DisplayName,
		CreatedAt:   toTimestampPB(su.CreatedAt),
	}
	if su.LastLoginAt != nil {
		result.LastLoginAt = toTimestampPB(*su.LastLoginAt)
	}
	return result
}

// toUserDetailPB 转换为 protobuf UserDetail
func (h *SuperUserHandler) toUserDetailPB(u *data_access.User) *pb.UserDetail {
	result := &pb.UserDetail{
		Id:             u.ID.String(),
		Username:       u.Username,
		Email:          u.Email,
		DisplayName:    u.DisplayName,
		Bio:            u.Bio,
		IsActive:       u.IsActive,
		IsBanned:       u.IsBanned,
		FollowersCount: int32(u.FollowersCount),
		FollowingCount: int32(u.FollowingCount),
		PostsCount:     int32(u.PostsCount),
		CreatedAt:      toTimestampPB(u.CreatedAt),
		UpdatedAt:      toTimestampPB(u.UpdatedAt),
	}
	if u.AvatarURL != nil {
		result.AvatarUrl = *u.AvatarURL
	}
	if u.BanReason != nil {
		result.BanReason = *u.BanReason
	}
	if u.BanExpiresAt != nil {
		result.BanExpiresAt = toTimestampPB(*u.BanExpiresAt)
	}
	return result
}

// toContentDetailPB 转换为 protobuf ContentDetail
func (h *SuperUserHandler) toContentDetailPB(c *data_access.Content) *pb.ContentDetail {
	result := &pb.ContentDetail{
		Id:             c.ID.String(),
		AuthorId:       c.AuthorID.String(),
		AuthorUsername: c.AuthorUsername,
		Type:           int32(c.Type),
		Status:         int32(c.Status),
		Text:           c.Text,
		MediaUrls:      c.MediaURLs,
		Tags:           c.Tags,
		LikeCount:      int32(c.LikeCount),
		CommentCount:   int32(c.CommentCount),
		RepostCount:    int32(c.RepostCount),
		ViewCount:      int32(c.ViewCount),
		CreatedAt:      toTimestampPB(c.CreatedAt),
	}
	if c.Title != nil {
		result.Title = *c.Title
	}
	if c.PublishedAt != nil {
		result.PublishedAt = toTimestampPB(*c.PublishedAt)
	}
	return result
}

// toAuditLogPB 转换为 protobuf AuditLog
func (h *SuperUserHandler) toAuditLogPB(l *data_access.AuditLog) *pb.AuditLog {
	result := &pb.AuditLog{
		Id:                l.ID.String(),
		SuperuserId:       l.SuperUserID.String(),
		SuperuserUsername: l.SuperUserUsername,
		Action:            l.Action,
		CreatedAt:         toTimestampPB(l.CreatedAt),
	}
	if l.TargetType != nil {
		result.TargetType = *l.TargetType
	}
	if l.TargetID != nil {
		result.TargetId = l.TargetID.String()
	}
	if l.IPAddress != nil {
		result.IpAddress = *l.IPAddress
	}
	return result
}

// toTimestampPB 转换为 protobuf Timestamp
func toTimestampPB(t interface{}) *commonpb.Timestamp {
	switch v := t.(type) {
	case time.Time:
		return &commonpb.Timestamp{Seconds: v.Unix(), Nanos: int32(v.Nanosecond())}
	case int64:
		return &commonpb.Timestamp{Seconds: v}
	default:
		return nil
	}
}
