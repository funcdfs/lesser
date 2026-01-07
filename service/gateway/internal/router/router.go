// Package router 提供 gRPC 服务路由功能
// 管理到各个后端服务的连接，支持健康检查
package router

import (
	"context"
	"fmt"
	"sync"

	"google.golang.org/grpc"
	"google.golang.org/grpc/connectivity"
	"google.golang.org/grpc/credentials/insecure"

	gwErr "github.com/funcdfs/lesser/gateway/internal/errors"
	"github.com/funcdfs/lesser/pkg/log"
)

// ============================================================================
// 服务名称常量（按功能分组排序）
// ============================================================================

type ServiceName string

const (
	// 认证与用户
	ServiceAuth      ServiceName = "auth"      // 50052
	ServiceUser      ServiceName = "user"      // 50053
	ServiceSuperUser ServiceName = "superuser" // 50061

	// 内容与交互
	ServiceContent     ServiceName = "content"     // 50054
	ServiceComment     ServiceName = "comment"     // 50055
	ServiceInteraction ServiceName = "interaction" // 50056
	ServiceTimeline    ServiceName = "timeline"    // 50057

	// 搜索与通知
	ServiceSearch       ServiceName = "search"       // 50058
	ServiceNotification ServiceName = "notification" // 50059

	// 实时通信
	ServiceChat    ServiceName = "chat"    // 50060
	ServiceChannel ServiceName = "channel" // 50062
)

// ============================================================================
// 服务配置
// ============================================================================

type ServiceConfig struct {
	// 认证与用户
	AuthAddr      string
	UserAddr      string
	SuperUserAddr string

	// 内容与交互
	ContentAddr     string
	CommentAddr     string
	InteractionAddr string
	TimelineAddr    string

	// 搜索与通知
	SearchAddr       string
	NotificationAddr string

	// 实时通信
	ChatAddr    string
	ChannelAddr string
}

// ============================================================================
// Router 路由器
// ============================================================================

type Router struct {
	mu    sync.RWMutex
	conns map[ServiceName]*grpc.ClientConn
	log   *log.Logger
}

// NewRouter 创建路由器并建立所有服务连接
func NewRouter(cfg ServiceConfig, logger *log.Logger) (*Router, error) {
	if logger == nil {
		logger = log.Global()
	}

	r := &Router{
		conns: make(map[ServiceName]*grpc.ClientConn),
		log:   logger.With(log.String("component", "router")),
	}

	// 服务地址映射（按功能分组）
	services := map[ServiceName]string{
		// 认证与用户
		ServiceAuth:      cfg.AuthAddr,
		ServiceUser:      cfg.UserAddr,
		ServiceSuperUser: cfg.SuperUserAddr,

		// 内容与交互
		ServiceContent:     cfg.ContentAddr,
		ServiceComment:     cfg.CommentAddr,
		ServiceInteraction: cfg.InteractionAddr,
		ServiceTimeline:    cfg.TimelineAddr,

		// 搜索与通知
		ServiceSearch:       cfg.SearchAddr,
		ServiceNotification: cfg.NotificationAddr,

		// 实时通信
		ServiceChat:    cfg.ChatAddr,
		ServiceChannel: cfg.ChannelAddr,
	}

	// 建立连接
	for name, addr := range services {
		if addr == "" {
			continue
		}
		conn, err := grpc.NewClient(addr,
			grpc.WithTransportCredentials(insecure.NewCredentials()),
		)
		if err != nil {
			r.Close()
			return nil, fmt.Errorf("连接 %s 服务失败: %w", name, err)
		}
		r.conns[name] = conn
		r.log.Info("服务已连接", log.String("service", string(name)), log.String("addr", addr))
	}

	return r, nil
}

// ============================================================================
// 连接获取方法
// ============================================================================

// GetConn 获取指定服务的连接
func (r *Router) GetConn(name ServiceName) *grpc.ClientConn {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return r.conns[name]
}

// ---- 认证与用户 ----

func (r *Router) GetAuthConn() *grpc.ClientConn {
	return r.GetConn(ServiceAuth)
}

func (r *Router) GetUserConn() *grpc.ClientConn {
	return r.GetConn(ServiceUser)
}

func (r *Router) GetSuperUserConn() *grpc.ClientConn {
	return r.GetConn(ServiceSuperUser)
}

// ---- 内容与交互 ----

func (r *Router) GetContentConn() *grpc.ClientConn {
	return r.GetConn(ServiceContent)
}

func (r *Router) GetCommentConn() *grpc.ClientConn {
	return r.GetConn(ServiceComment)
}

func (r *Router) GetInteractionConn() *grpc.ClientConn {
	return r.GetConn(ServiceInteraction)
}

func (r *Router) GetTimelineConn() *grpc.ClientConn {
	return r.GetConn(ServiceTimeline)
}

// ---- 搜索与通知 ----

func (r *Router) GetSearchConn() *grpc.ClientConn {
	return r.GetConn(ServiceSearch)
}

func (r *Router) GetNotificationConn() *grpc.ClientConn {
	return r.GetConn(ServiceNotification)
}

// ---- 实时通信 ----

func (r *Router) GetChatConn() *grpc.ClientConn {
	return r.GetConn(ServiceChat)
}

func (r *Router) GetChannelConn() *grpc.ClientConn {
	return r.GetConn(ServiceChannel)
}

// ============================================================================
// 路由与健康检查
// ============================================================================

// RouteByService 根据服务名路由，返回连接或错误
func (r *Router) RouteByService(name string) (*grpc.ClientConn, error) {
	serviceName := ServiceName(name)
	conn := r.GetConn(serviceName)
	if conn == nil {
		return nil, gwErr.ServiceUnavailableError(name)
	}
	return conn, nil
}

// HealthCheck 检查所有服务的健康状态
func (r *Router) HealthCheck(ctx context.Context) map[string]bool {
	r.mu.RLock()
	defer r.mu.RUnlock()

	health := make(map[string]bool)
	for name, conn := range r.conns {
		healthy := conn != nil && conn.GetState() != connectivity.Shutdown
		health[string(name)] = healthy
	}
	return health
}

// Close 关闭所有连接
func (r *Router) Close() {
	r.mu.Lock()
	defer r.mu.Unlock()

	for name, conn := range r.conns {
		if conn != nil {
			if err := conn.Close(); err != nil {
				r.log.Warn("关闭连接失败", log.String("service", string(name)), log.Any("error", err))
			}
		}
	}
	r.conns = make(map[ServiceName]*grpc.ClientConn)
	r.log.Info("所有连接已关闭")
}
