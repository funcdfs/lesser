package router

import (
	"context"
	"fmt"
	"log"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/status"
)

// ServiceConfig 服务配置
type ServiceConfig struct {
	AuthAddr         string
	UserAddr         string
	PostAddr         string
	FeedAddr         string
	ChatAddr         string
	SearchAddr       string
	NotificationAddr string
}

// Router gRPC 路由器
// 设计要点：
// 1. 管理到各个 Service 的连接
// 2. 根据请求路径路由到对应 Service
// 3. 支持连接池和健康检查
type Router struct {
	config ServiceConfig

	// Service 连接
	authConn   *grpc.ClientConn
	userConn   *grpc.ClientConn
	postConn   *grpc.ClientConn
	feedConn   *grpc.ClientConn
	chatConn   *grpc.ClientConn
	searchConn *grpc.ClientConn
	notifConn  *grpc.ClientConn
}

// NewRouter 创建路由器
func NewRouter(config ServiceConfig) (*Router, error) {
	r := &Router{config: config}

	var err error

	// 连接 Auth Service
	if config.AuthAddr != "" {
		r.authConn, err = grpc.NewClient(config.AuthAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			return nil, fmt.Errorf("failed to connect to auth service: %w", err)
		}
		log.Printf("[Router] Connected to Auth Service: %s", config.AuthAddr)
	}

	// 连接 User Service
	if config.UserAddr != "" {
		r.userConn, err = grpc.NewClient(config.UserAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			return nil, fmt.Errorf("failed to connect to user service: %w", err)
		}
		log.Printf("[Router] Connected to User Service: %s", config.UserAddr)
	}

	// 连接 Post Service
	if config.PostAddr != "" {
		r.postConn, err = grpc.NewClient(config.PostAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			return nil, fmt.Errorf("failed to connect to post service: %w", err)
		}
		log.Printf("[Router] Connected to Post Service: %s", config.PostAddr)
	}

	// 连接 Feed Service
	if config.FeedAddr != "" {
		r.feedConn, err = grpc.NewClient(config.FeedAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			return nil, fmt.Errorf("failed to connect to feed service: %w", err)
		}
		log.Printf("[Router] Connected to Feed Service: %s", config.FeedAddr)
	}

	// 连接 Chat Service
	if config.ChatAddr != "" {
		r.chatConn, err = grpc.NewClient(config.ChatAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			return nil, fmt.Errorf("failed to connect to chat service: %w", err)
		}
		log.Printf("[Router] Connected to Chat Service: %s", config.ChatAddr)
	}

	// 连接 Search Service
	if config.SearchAddr != "" {
		r.searchConn, err = grpc.NewClient(config.SearchAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			return nil, fmt.Errorf("failed to connect to search service: %w", err)
		}
		log.Printf("[Router] Connected to Search Service: %s", config.SearchAddr)
	}

	// 连接 Notification Service
	if config.NotificationAddr != "" {
		r.notifConn, err = grpc.NewClient(config.NotificationAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			return nil, fmt.Errorf("failed to connect to notification service: %w", err)
		}
		log.Printf("[Router] Connected to Notification Service: %s", config.NotificationAddr)
	}

	return r, nil
}


// GetAuthConn 获取 Auth Service 连接
func (r *Router) GetAuthConn() *grpc.ClientConn {
	return r.authConn
}

// GetUserConn 获取 User Service 连接
func (r *Router) GetUserConn() *grpc.ClientConn {
	return r.userConn
}

// GetPostConn 获取 Post Service 连接
func (r *Router) GetPostConn() *grpc.ClientConn {
	return r.postConn
}

// GetFeedConn 获取 Feed Service 连接
func (r *Router) GetFeedConn() *grpc.ClientConn {
	return r.feedConn
}

// GetChatConn 获取 Chat Service 连接
func (r *Router) GetChatConn() *grpc.ClientConn {
	return r.chatConn
}

// GetSearchConn 获取 Search Service 连接
func (r *Router) GetSearchConn() *grpc.ClientConn {
	return r.searchConn
}

// GetNotificationConn 获取 Notification Service 连接
func (r *Router) GetNotificationConn() *grpc.ClientConn {
	return r.notifConn
}

// RouteByService 根据服务名路由
func (r *Router) RouteByService(serviceName string) (*grpc.ClientConn, error) {
	switch serviceName {
	case "auth":
		if r.authConn == nil {
			return nil, status.Error(codes.Unavailable, "auth service not available")
		}
		return r.authConn, nil
	case "user":
		if r.userConn == nil {
			return nil, status.Error(codes.Unavailable, "user service not available")
		}
		return r.userConn, nil
	case "post":
		if r.postConn == nil {
			return nil, status.Error(codes.Unavailable, "post service not available")
		}
		return r.postConn, nil
	case "feed":
		if r.feedConn == nil {
			return nil, status.Error(codes.Unavailable, "feed service not available")
		}
		return r.feedConn, nil
	case "chat":
		if r.chatConn == nil {
			return nil, status.Error(codes.Unavailable, "chat service not available")
		}
		return r.chatConn, nil
	case "search":
		if r.searchConn == nil {
			return nil, status.Error(codes.Unavailable, "search service not available")
		}
		return r.searchConn, nil
	case "notification":
		if r.notifConn == nil {
			return nil, status.Error(codes.Unavailable, "notification service not available")
		}
		return r.notifConn, nil
	default:
		return nil, status.Error(codes.NotFound, fmt.Sprintf("unknown service: %s", serviceName))
	}
}

// HealthCheck 检查所有服务健康状态
func (r *Router) HealthCheck(ctx context.Context) map[string]bool {
	health := make(map[string]bool)

	// 简单检查连接状态
	health["auth"] = r.authConn != nil && r.authConn.GetState().String() != "SHUTDOWN"
	health["user"] = r.userConn != nil && r.userConn.GetState().String() != "SHUTDOWN"
	health["post"] = r.postConn != nil && r.postConn.GetState().String() != "SHUTDOWN"
	health["feed"] = r.feedConn != nil && r.feedConn.GetState().String() != "SHUTDOWN"
	health["chat"] = r.chatConn != nil && r.chatConn.GetState().String() != "SHUTDOWN"
	health["search"] = r.searchConn != nil && r.searchConn.GetState().String() != "SHUTDOWN"
	health["notification"] = r.notifConn != nil && r.notifConn.GetState().String() != "SHUTDOWN"

	return health
}

// Close 关闭所有连接
func (r *Router) Close() {
	if r.authConn != nil {
		r.authConn.Close()
	}
	if r.userConn != nil {
		r.userConn.Close()
	}
	if r.postConn != nil {
		r.postConn.Close()
	}
	if r.feedConn != nil {
		r.feedConn.Close()
	}
	if r.chatConn != nil {
		r.chatConn.Close()
	}
	if r.searchConn != nil {
		r.searchConn.Close()
	}
	if r.notifConn != nil {
		r.notifConn.Close()
	}
	log.Println("[Router] All connections closed")
}
