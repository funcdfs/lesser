// Package handler 提供 gRPC 处理器实现
package handler

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	"github.com/funcdfs/lesser/auth/internal/data_access"
	"github.com/funcdfs/lesser/auth/internal/logic"
	pb "github.com/funcdfs/lesser/auth/gen_protos/auth"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
)

// AuthHandler gRPC 认证处理器
type AuthHandler struct {
	pb.UnimplementedAuthServiceServer
	authService logic.AuthService
	log         *slog.Logger
}

// NewAuthHandler 创建认证处理器
func NewAuthHandler(authService logic.AuthService, log *slog.Logger) *AuthHandler {
	return &AuthHandler{
		authService: authService,
		log:         log.With(slog.String("component", "handler")),
	}
}

// Register 用户注册
func (h *AuthHandler) Register(ctx context.Context, req *pb.RegisterRequest) (*pb.AuthResponse, error) {
	// 参数验证
	if req.Username == "" {
		return nil, status.Error(codes.InvalidArgument, "用户名不能为空")
	}
	if req.Email == "" {
		return nil, status.Error(codes.InvalidArgument, "邮箱不能为空")
	}
	if req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "密码不能为空")
	}

	result, err := h.authService.Register(ctx, req.Username, req.Email, req.Password, req.DisplayName)
	if err != nil {
		return nil, h.handleError(err, "注册失败")
	}

	return &pb.AuthResponse{
		User:         userToProto(result.User),
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	}, nil
}

// Login 用户登录
func (h *AuthHandler) Login(ctx context.Context, req *pb.LoginRequest) (*pb.AuthResponse, error) {
	// 参数验证
	if req.Email == "" {
		return nil, status.Error(codes.InvalidArgument, "邮箱不能为空")
	}
	if req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "密码不能为空")
	}

	result, err := h.authService.Login(ctx, req.Email, req.Password)
	if err != nil {
		return nil, h.handleError(err, "登录失败")
	}

	return &pb.AuthResponse{
		User:         userToProto(result.User),
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	}, nil
}

// Logout 用户登出
func (h *AuthHandler) Logout(ctx context.Context, req *pb.LogoutRequest) (*common.Empty, error) {
	if req.AccessToken == "" {
		return nil, status.Error(codes.InvalidArgument, "access_token 不能为空")
	}

	if err := h.authService.Logout(ctx, req.AccessToken); err != nil {
		h.log.Warn("登出处理失败", slog.Any("error", err))
		// 登出失败不返回错误，允许客户端继续
	}

	return &common.Empty{}, nil
}

// RefreshToken 刷新 Token
func (h *AuthHandler) RefreshToken(ctx context.Context, req *pb.RefreshRequest) (*pb.AuthResponse, error) {
	if req.RefreshToken == "" {
		return nil, status.Error(codes.InvalidArgument, "refresh_token 不能为空")
	}

	result, err := h.authService.RefreshToken(ctx, req.RefreshToken)
	if err != nil {
		return nil, h.handleError(err, "刷新 Token 失败")
	}

	return &pb.AuthResponse{
		User:         userToProto(result.User),
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	}, nil
}

// GetPublicKey 获取公钥
func (h *AuthHandler) GetPublicKey(ctx context.Context, req *pb.GetPublicKeyRequest) (*pb.GetPublicKeyResponse, error) {
	info := h.authService.GetPublicKey()
	if info == nil {
		return nil, status.Error(codes.Internal, "公钥未初始化")
	}

	return &pb.GetPublicKeyResponse{
		PublicKey: info.PublicKey,
		KeyId:     info.KeyID,
		Algorithm: info.Algorithm,
		ExpiresAt: info.ExpiresAt,
	}, nil
}

// BanUser 封禁用户
func (h *AuthHandler) BanUser(ctx context.Context, req *pb.BanUserRequest) (*pb.BanUserResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	var duration time.Duration
	if req.DurationSeconds > 0 {
		duration = time.Duration(req.DurationSeconds) * time.Second
	}

	// TODO: 从 context 获取操作者 ID
	operatorID := ""

	if err := h.authService.BanUser(ctx, req.UserId, req.Reason, duration, operatorID); err != nil {
		return nil, h.handleError(err, "封禁用户失败")
	}

	return &pb.BanUserResponse{Success: true}, nil
}

// CheckBanned 检查封禁状态
func (h *AuthHandler) CheckBanned(ctx context.Context, req *pb.CheckBannedRequest) (*pb.CheckBannedResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	info, err := h.authService.CheckBanned(ctx, req.UserId)
	if err != nil {
		return nil, h.handleError(err, "检查封禁状态失败")
	}

	return &pb.CheckBannedResponse{
		Banned:    info.Banned,
		Reason:    info.Reason,
		ExpiresAt: info.ExpiresAt,
	}, nil
}

// GetUser 获取用户信息
func (h *AuthHandler) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	user, err := h.authService.GetUser(ctx, req.UserId)
	if err != nil {
		return nil, h.handleError(err, "获取用户失败")
	}

	return userToProto(user), nil
}

// handleError 统一错误处理
func (h *AuthHandler) handleError(err error, msg string) error {
	switch {
	case errors.Is(err, data_access.ErrUserExists):
		return status.Error(codes.AlreadyExists, "用户已存在")
	case errors.Is(err, data_access.ErrUserNotFound):
		return status.Error(codes.NotFound, "用户不存在")
	case errors.Is(err, logic.ErrInvalidCredentials):
		return status.Error(codes.Unauthenticated, "邮箱或密码错误")
	case errors.Is(err, logic.ErrUserBanned):
		return status.Error(codes.PermissionDenied, "用户已被封禁")
	case errors.Is(err, logic.ErrAccountLocked):
		return status.Error(codes.ResourceExhausted, "账户已被锁定，请稍后再试")
	case errors.Is(err, logic.ErrInvalidToken):
		return status.Error(codes.Unauthenticated, "无效的令牌")
	case errors.Is(err, logic.ErrTokenExpired):
		return status.Error(codes.Unauthenticated, "令牌已过期")
	case errors.Is(err, logic.ErrPasswordTooWeak):
		return status.Error(codes.InvalidArgument, err.Error())
	case errors.Is(err, logic.ErrUserNotActive):
		return status.Error(codes.PermissionDenied, "用户账户未激活")
	default:
		h.log.Error(msg, slog.Any("error", err))
		return status.Error(codes.Internal, msg)
	}
}

// userToProto 转换用户实体为 proto
func userToProto(user *data_access.User) *pb.User {
	if user == nil {
		return nil
	}
	return &pb.User{
		Id:          user.ID,
		Username:    user.Username,
		Email:       user.Email,
		DisplayName: user.DisplayName,
		AvatarUrl:   user.AvatarURL,
		Bio:         user.Bio,
		CreatedAt: &common.Timestamp{
			Seconds: user.CreatedAt.Unix(),
			Nanos:   int32(user.CreatedAt.Nanosecond()),
		},
	}
}
