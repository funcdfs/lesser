package handler

import (
	"context"

	"github.com/lesser/auth/internal/repository"
	"github.com/lesser/auth/internal/service"
	pb "github.com/lesser/auth/proto/auth"
	"github.com/lesser/pkg/proto/common"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// AuthHandler gRPC 处理器
type AuthHandler struct {
	pb.UnimplementedAuthServiceServer
	authService *service.AuthService
}

// NewAuthHandler 创建处理器
func NewAuthHandler(authService *service.AuthService) *AuthHandler {
	return &AuthHandler{authService: authService}
}

// Register 用户注册
func (h *AuthHandler) Register(ctx context.Context, req *pb.RegisterRequest) (*pb.AuthResponse, error) {
	if req.Username == "" || req.Email == "" || req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "username, email and password are required")
	}

	result, err := h.authService.Register(req.Username, req.Email, req.Password, req.DisplayName)
	if err != nil {
		if err == repository.ErrUserExists {
			return nil, status.Error(codes.AlreadyExists, "user already exists")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.AuthResponse{
		User:         userToProto(result.User),
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	}, nil
}

// Login 用户登录
func (h *AuthHandler) Login(ctx context.Context, req *pb.LoginRequest) (*pb.AuthResponse, error) {
	if req.Email == "" || req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "email and password are required")
	}

	result, err := h.authService.Login(req.Email, req.Password)
	if err != nil {
		if err == service.ErrInvalidCredentials {
			return nil, status.Error(codes.Unauthenticated, "invalid email or password")
		}
		if err == service.ErrUserBanned {
			return nil, status.Error(codes.PermissionDenied, "user is banned")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.AuthResponse{
		User:         userToProto(result.User),
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
	}, nil
}

// Logout 用户登出
func (h *AuthHandler) Logout(ctx context.Context, req *pb.LogoutRequest) (*common.Empty, error) {
	// TODO: 将 token 加入黑名单（可选实现）
	return &common.Empty{}, nil
}

// RefreshToken 刷新 Token
func (h *AuthHandler) RefreshToken(ctx context.Context, req *pb.RefreshRequest) (*pb.AuthResponse, error) {
	if req.RefreshToken == "" {
		return nil, status.Error(codes.InvalidArgument, "refresh_token is required")
	}

	result, err := h.authService.RefreshToken(req.RefreshToken)
	if err != nil {
		if err == service.ErrInvalidToken || err == service.ErrTokenExpired {
			return nil, status.Error(codes.Unauthenticated, "invalid or expired refresh token")
		}
		if err == service.ErrUserBanned {
			return nil, status.Error(codes.PermissionDenied, "user is banned")
		}
		return nil, status.Error(codes.Internal, err.Error())
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
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}

	err := h.authService.BanUser(req.UserId, req.Reason, req.DurationSeconds)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.BanUserResponse{Success: true}, nil
}

// CheckBanned 检查封禁状态
func (h *AuthHandler) CheckBanned(ctx context.Context, req *pb.CheckBannedRequest) (*pb.CheckBannedResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}

	banned, reason, expiresAt := h.authService.CheckBanned(req.UserId)
	return &pb.CheckBannedResponse{
		Banned:    banned,
		Reason:    reason,
		ExpiresAt: expiresAt,
	}, nil
}

// GetUser 获取用户信息
func (h *AuthHandler) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}

	user, err := h.authService.GetUser(req.UserId)
	if err != nil {
		if err == repository.ErrUserNotFound {
			return nil, status.Error(codes.NotFound, "user not found")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	return userToProto(user), nil
}

// userToProto 转换用户实体为 proto
func userToProto(user *repository.User) *pb.User {
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
