package server

import (
	"context"
	"log"

	authpb "github.com/lesser/gateway/proto/auth"
	"github.com/lesser/gateway/proto/common"
	"google.golang.org/grpc"
)

// AuthProxyServer 代理 Auth 服务请求到后端 Auth 服务
type AuthProxyServer struct {
	authpb.UnimplementedAuthServiceServer
	authClient authpb.AuthServiceClient
}

// NewAuthProxyServer 创建 Auth 代理服务器
func NewAuthProxyServer(authConn *grpc.ClientConn) *AuthProxyServer {
	return &AuthProxyServer{
		authClient: authpb.NewAuthServiceClient(authConn),
	}
}

// Register 代理注册请求
func (s *AuthProxyServer) Register(ctx context.Context, req *authpb.RegisterRequest) (*authpb.AuthResponse, error) {
	log.Printf("[AuthProxy] Register: username=%s, email=%s", req.Username, req.Email)
	return s.authClient.Register(ctx, req)
}

// Login 代理登录请求
func (s *AuthProxyServer) Login(ctx context.Context, req *authpb.LoginRequest) (*authpb.AuthResponse, error) {
	log.Printf("[AuthProxy] Login: email=%s", req.Email)
	return s.authClient.Login(ctx, req)
}

// Logout 代理登出请求
func (s *AuthProxyServer) Logout(ctx context.Context, req *authpb.LogoutRequest) (*common.Empty, error) {
	log.Printf("[AuthProxy] Logout")
	return s.authClient.Logout(ctx, req)
}

// RefreshToken 代理刷新 Token 请求
func (s *AuthProxyServer) RefreshToken(ctx context.Context, req *authpb.RefreshRequest) (*authpb.AuthResponse, error) {
	log.Printf("[AuthProxy] RefreshToken")
	return s.authClient.RefreshToken(ctx, req)
}

// GetPublicKey 代理获取公钥请求
func (s *AuthProxyServer) GetPublicKey(ctx context.Context, req *authpb.GetPublicKeyRequest) (*authpb.GetPublicKeyResponse, error) {
	log.Printf("[AuthProxy] GetPublicKey")
	return s.authClient.GetPublicKey(ctx, req)
}

// BanUser 代理封禁用户请求
func (s *AuthProxyServer) BanUser(ctx context.Context, req *authpb.BanUserRequest) (*authpb.BanUserResponse, error) {
	log.Printf("[AuthProxy] BanUser: user_id=%s", req.UserId)
	return s.authClient.BanUser(ctx, req)
}

// CheckBanned 代理检查封禁状态请求
func (s *AuthProxyServer) CheckBanned(ctx context.Context, req *authpb.CheckBannedRequest) (*authpb.CheckBannedResponse, error) {
	log.Printf("[AuthProxy] CheckBanned: user_id=%s", req.UserId)
	return s.authClient.CheckBanned(ctx, req)
}

// GetUser 代理获取用户请求
func (s *AuthProxyServer) GetUser(ctx context.Context, req *authpb.GetUserRequest) (*authpb.User, error) {
	log.Printf("[AuthProxy] GetUser: user_id=%s", req.UserId)
	return s.authClient.GetUser(ctx, req)
}

// RegisterAuthProxyServer 注册 Auth 代理服务到 gRPC 服务器
func RegisterAuthProxyServer(s *grpc.Server, authConn *grpc.ClientConn) {
	authProxy := NewAuthProxyServer(authConn)
	authpb.RegisterAuthServiceServer(s, authProxy)
	log.Println("[Gateway] Auth proxy service registered")
}
