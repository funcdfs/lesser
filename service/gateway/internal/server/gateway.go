package server

import (
	"context"
	"fmt"
	"log"

	"github.com/lesser/gateway/internal/auth"
	"github.com/lesser/gateway/internal/broker"
	pb "github.com/lesser/gateway/proto/gateway"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
)

// GatewayServer 实现 GatewayService
type GatewayServer struct {
	pb.UnimplementedGatewayServiceServer
	broker      *broker.Connection
	authService *auth.AuthService
}

// NewGatewayServer 创建新的 Gateway 服务器
func NewGatewayServer(brokerConn *broker.Connection, authSvc *auth.AuthService) (*GatewayServer, error) {
	return &GatewayServer{
		broker:      brokerConn,
		authService: authSvc,
	}, nil
}

// RegisterGatewayServer 注册 gRPC 服务
func RegisterGatewayServer(s *grpc.Server, srv *GatewayServer) {
	pb.RegisterGatewayServiceServer(s, srv)
}

// Process 处理所有客户端请求
func (s *GatewayServer) Process(ctx context.Context, req *pb.GatewayRequest) (*pb.GatewayResponse, error) {
	log.Printf("Received request: action=%v, request_id=%s", req.Action, req.RequestId)

	// 验证请求
	if req.RequestId == "" {
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "INVALID_REQUEST",
			ErrorMessage: "request_id is required",
		}, nil
	}

	// 判断是 Command 还是 Query
	actionType := s.getActionType(req.Action)

	switch actionType {
	case ActionTypeCommand:
		// Command: 发布到 MQ 异步处理
		return s.processCommand(ctx, req)
	case ActionTypeQuery:
		// Query: 直接查询返回（TODO: 实现直接查询逻辑）
		return s.processQuery(ctx, req)
	default:
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "INVALID_ACTION",
			ErrorMessage: fmt.Sprintf("unknown action: %v", req.Action),
		}, nil
	}
}

// ActionType 操作类型
type ActionType int

const (
	ActionTypeUnknown ActionType = iota
	ActionTypeCommand
	ActionTypeQuery
)

// getActionType 获取操作类型
func (s *GatewayServer) getActionType(action pb.Action) ActionType {
	switch action {
	// Command 类型（写操作）
	case pb.Action_POST_CREATE, pb.Action_POST_DELETE, pb.Action_POST_UPDATE,
		pb.Action_FEED_LIKE, pb.Action_FEED_UNLIKE, pb.Action_FEED_COMMENT,
		pb.Action_FEED_COMMENT_DELETE, pb.Action_FEED_REPOST, pb.Action_FEED_BOOKMARK,
		pb.Action_FEED_UNBOOKMARK, pb.Action_NOTIFICATION_READ, pb.Action_NOTIFICATION_READ_ALL,
		pb.Action_USER_PROFILE_UPDATE, pb.Action_USER_FOLLOW, pb.Action_USER_UNFOLLOW,
		pb.Action_CHAT_SEND, pb.Action_CHAT_CREATE_CONVERSATION, pb.Action_CHAT_MARK_READ:
		return ActionTypeCommand

	// Query 类型（读操作）
	case pb.Action_POST_GET, pb.Action_POST_LIST, pb.Action_NOTIFICATION_LIST,
		pb.Action_USER_PROFILE_GET, pb.Action_USER_FOLLOWERS, pb.Action_USER_FOLLOWING,
		pb.Action_SEARCH_POSTS, pb.Action_SEARCH_USERS,
		pb.Action_CHAT_GET_CONVERSATIONS, pb.Action_CHAT_GET_MESSAGES:
		return ActionTypeQuery

	default:
		return ActionTypeUnknown
	}
}

// processCommand 处理 Command 请求（发布到 MQ）
func (s *GatewayServer) processCommand(ctx context.Context, req *pb.GatewayRequest) (*pb.GatewayResponse, error) {
	routingKey := s.getRoutingKey(req.Action)
	if routingKey == "" {
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "INVALID_ACTION",
			ErrorMessage: fmt.Sprintf("unknown action: %v", req.Action),
		}, nil
	}

	// 序列化整个请求并发布到队列
	msgBytes, err := serializeRequest(req)
	if err != nil {
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "SERIALIZATION_ERROR",
			ErrorMessage: err.Error(),
		}, nil
	}

	// 发布到 RabbitMQ
	if err := s.broker.Publish(routingKey, msgBytes); err != nil {
		log.Printf("Failed to publish message: %v", err)
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "BROKER_ERROR",
			ErrorMessage: "failed to queue task",
		}, nil
	}

	log.Printf("Command queued: request_id=%s, queue=%s", req.RequestId, routingKey)

	return &pb.GatewayResponse{
		RequestId: req.RequestId,
		Accepted:  true,
	}, nil
}

// processQuery 处理 Query 请求（直接查询返回）
func (s *GatewayServer) processQuery(ctx context.Context, req *pb.GatewayRequest) (*pb.GatewayResponse, error) {
	// TODO: 实现直接查询逻辑
	// 目前暂时仍通过 MQ 处理，后续可改为直接 RPC 调用下游服务
	routingKey := s.getRoutingKey(req.Action)
	if routingKey == "" {
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "INVALID_ACTION",
			ErrorMessage: fmt.Sprintf("unknown action: %v", req.Action),
		}, nil
	}

	// 序列化整个请求并发布到队列
	msgBytes, err := serializeRequest(req)
	if err != nil {
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "SERIALIZATION_ERROR",
			ErrorMessage: err.Error(),
		}, nil
	}

	// 发布到 RabbitMQ
	if err := s.broker.Publish(routingKey, msgBytes); err != nil {
		log.Printf("Failed to publish message: %v", err)
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "BROKER_ERROR",
			ErrorMessage: "failed to queue task",
		}, nil
	}

	log.Printf("Query queued: request_id=%s, queue=%s", req.RequestId, routingKey)

	return &pb.GatewayResponse{
		RequestId: req.RequestId,
		Accepted:  true,
	}, nil
}

// getRoutingKey 根据 action 获取对应的队列名
func (s *GatewayServer) getRoutingKey(action pb.Action) string {
	switch action {
	// Auth
	case pb.Action_USER_REGISTER:
		return broker.QueueAuthRegister
	case pb.Action_USER_LOGIN:
		return broker.QueueAuthLogin

	// Post
	case pb.Action_POST_CREATE:
		return broker.QueuePostCreate
	case pb.Action_POST_GET:
		return broker.QueuePostGet
	case pb.Action_POST_LIST:
		return broker.QueuePostList
	case pb.Action_POST_DELETE:
		return broker.QueuePostDelete
	case pb.Action_POST_UPDATE:
		return broker.QueuePostUpdate

	// Feed
	case pb.Action_FEED_LIKE:
		return broker.QueueFeedLike
	case pb.Action_FEED_UNLIKE:
		return broker.QueueFeedUnlike
	case pb.Action_FEED_COMMENT:
		return broker.QueueFeedComment
	case pb.Action_FEED_COMMENT_DELETE:
		return broker.QueueFeedCommentDelete
	case pb.Action_FEED_REPOST:
		return broker.QueueFeedRepost
	case pb.Action_FEED_BOOKMARK:
		return broker.QueueFeedBookmark
	case pb.Action_FEED_UNBOOKMARK:
		return broker.QueueFeedUnbookmark

	// Notification
	case pb.Action_NOTIFICATION_LIST:
		return broker.QueueNotificationList
	case pb.Action_NOTIFICATION_READ:
		return broker.QueueNotificationRead
	case pb.Action_NOTIFICATION_READ_ALL:
		return broker.QueueNotificationReadAll

	// User
	case pb.Action_USER_PROFILE_GET:
		return broker.QueueUserProfileGet
	case pb.Action_USER_PROFILE_UPDATE:
		return broker.QueueUserProfileUpdate
	case pb.Action_USER_FOLLOW:
		return broker.QueueUserFollow
	case pb.Action_USER_UNFOLLOW:
		return broker.QueueUserUnfollow
	case pb.Action_USER_FOLLOWERS:
		return broker.QueueUserFollowers
	case pb.Action_USER_FOLLOWING:
		return broker.QueueUserFollowing

	// Search
	case pb.Action_SEARCH_POSTS:
		return broker.QueueSearchPosts
	case pb.Action_SEARCH_USERS:
		return broker.QueueSearchUsers

	// Chat
	case pb.Action_CHAT_SEND:
		return broker.QueueChatSend
	case pb.Action_CHAT_GET_CONVERSATIONS:
		return broker.QueueChatGetConversations
	case pb.Action_CHAT_GET_MESSAGES:
		return broker.QueueChatGetMessages
	case pb.Action_CHAT_CREATE_CONVERSATION:
		return broker.QueueChatCreateConversation
	case pb.Action_CHAT_MARK_READ:
		return broker.QueueChatMarkRead

	default:
		return ""
	}
}

// GetResult 获取异步任务结果（暂时返回 pending）
func (s *GatewayServer) GetResult(ctx context.Context, req *pb.GetResultRequest) (*pb.TaskResult, error) {
	// TODO: 从 Redis 或其他存储获取结果
	return &pb.TaskResult{
		RequestId: req.RequestId,
		Status:    pb.TaskStatus_PENDING,
	}, nil
}

// serializeRequest 序列化请求为字节
func serializeRequest(req *pb.GatewayRequest) ([]byte, error) {
	return proto.Marshal(req)
}

// Login 同步登录
func (s *GatewayServer) Login(ctx context.Context, req *pb.LoginRequest) (*pb.AuthResponse, error) {
	log.Printf("Login request: username=%s", req.Username)

	if req.Username == "" || req.Password == "" {
		return &pb.AuthResponse{
			Success:      false,
			ErrorCode:    "INVALID_ARGUMENT",
			ErrorMessage: "username and password are required",
		}, nil
	}

	result, err := s.authService.Login(req.Username, req.Password)
	if err != nil {
		if err == auth.ErrInvalidCredentials {
			return &pb.AuthResponse{
				Success:      false,
				ErrorCode:    "UNAUTHENTICATED",
				ErrorMessage: "invalid username or password",
			}, nil
		}
		log.Printf("Login error: %v", err)
		return nil, status.Errorf(codes.Internal, "internal error")
	}

	return &pb.AuthResponse{
		Success:      true,
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
		UserId:       result.UserID,
	}, nil
}

// Register 同步注册
func (s *GatewayServer) Register(ctx context.Context, req *pb.RegisterRequest) (*pb.AuthResponse, error) {
	log.Printf("Register request: username=%s, email=%s", req.Username, req.Email)

	if req.Username == "" || req.Email == "" || req.Password == "" {
		return &pb.AuthResponse{
			Success:      false,
			ErrorCode:    "INVALID_ARGUMENT",
			ErrorMessage: "username, email and password are required",
		}, nil
	}

	result, err := s.authService.Register(req.Username, req.Email, req.Password)
	if err != nil {
		if err == auth.ErrUserExists {
			return &pb.AuthResponse{
				Success:      false,
				ErrorCode:    "ALREADY_EXISTS",
				ErrorMessage: "user already exists",
			}, nil
		}
		log.Printf("Register error: %v", err)
		return nil, status.Errorf(codes.Internal, "internal error")
	}

	return &pb.AuthResponse{
		Success:      true,
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
		UserId:       result.UserID,
	}, nil
}

// RefreshToken 刷新 Token
func (s *GatewayServer) RefreshToken(ctx context.Context, req *pb.RefreshTokenRequest) (*pb.AuthResponse, error) {
	log.Printf("RefreshToken request")

	if req.RefreshToken == "" {
		return &pb.AuthResponse{
			Success:      false,
			ErrorCode:    "INVALID_ARGUMENT",
			ErrorMessage: "refresh_token is required",
		}, nil
	}

	result, err := s.authService.RefreshToken(req.RefreshToken)
	if err != nil {
		if err == auth.ErrInvalidToken || err == auth.ErrTokenExpired {
			return &pb.AuthResponse{
				Success:      false,
				ErrorCode:    "UNAUTHENTICATED",
				ErrorMessage: "invalid or expired refresh token",
			}, nil
		}
		if err == auth.ErrUserNotFound {
			return &pb.AuthResponse{
				Success:      false,
				ErrorCode:    "NOT_FOUND",
				ErrorMessage: "user not found",
			}, nil
		}
		log.Printf("RefreshToken error: %v", err)
		return nil, status.Errorf(codes.Internal, "internal error")
	}

	return &pb.AuthResponse{
		Success:      true,
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
		UserId:       result.UserID,
	}, nil
}
