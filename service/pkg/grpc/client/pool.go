// Package client 提供统一的 gRPC 客户端封装
// 支持连接池管理、自动重连、拦截器（日志、追踪、重试）
package client

import (
	"context"
	"fmt"
	"log/slog"
	"sync"

	"github.com/funcdfs/lesser/pkg/logger"
	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// Pool gRPC 客户端连接池
type Pool struct {
	conns   map[string]*grpc.ClientConn
	configs map[string]Config
	mu      sync.RWMutex
	log     *logger.Logger
}

// NewPool 创建客户端连接池
func NewPool(log *logger.Logger) *Pool {
	return &Pool{
		conns:   make(map[string]*grpc.ClientConn),
		configs: make(map[string]Config),
		log:     log,
	}
}

// Register 注册服务配置
func (p *Pool) Register(name string, cfg Config) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.configs[name] = cfg
}

// RegisterFromEnv 从环境变量注册服务配置
func (p *Pool) RegisterFromEnv(serviceName string) {
	cfg := ConfigFromEnv(serviceName)
	p.Register(serviceName, cfg)
}

// GetConn 获取服务连接（懒加载）
func (p *Pool) GetConn(ctx context.Context, name string) (*grpc.ClientConn, error) {
	// 先尝试读取已有连接
	p.mu.RLock()
	conn, exists := p.conns[name]
	p.mu.RUnlock()

	if exists && conn != nil {
		return conn, nil
	}

	// 需要创建新连接
	p.mu.Lock()
	defer p.mu.Unlock()

	// 双重检查
	if conn, exists := p.conns[name]; exists && conn != nil {
		return conn, nil
	}

	// 获取配置
	cfg, ok := p.configs[name]
	if !ok {
		return nil, fmt.Errorf("service %s not registered", name)
	}

	if cfg.Target == "" {
		return nil, fmt.Errorf("service %s has no target address", name)
	}

	// 创建连接
	conn, err := p.dial(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to %s: %w", name, err)
	}

	p.conns[name] = conn
	p.log.Info("grpc connection established", slog.String("service", name), slog.String("target", cfg.Target))

	return conn, nil
}

// dial 创建 gRPC 连接
// 添加 OpenTelemetry 拦截器用于分布式追踪
func (p *Pool) dial(ctx context.Context, cfg Config) (*grpc.ClientConn, error) {
	// 创建 OpenTelemetry gRPC 统计处理器
	otelStatsHandler := otelgrpc.NewClientHandler()

	opts := []grpc.DialOption{
		// 添加 OpenTelemetry 统计处理器（自动创建 Span）
		grpc.WithStatsHandler(otelStatsHandler),
		// 添加自定义拦截器链（TraceID 传递、日志、重试）
		grpc.WithUnaryInterceptor(ChainUnaryClient(
			TraceInterceptor(),
			LoggingInterceptor(p.log),
			RetryInterceptor(cfg.MaxRetries, cfg.RetryBackoff),
		)),
	}

	if cfg.Insecure {
		opts = append(opts, grpc.WithTransportCredentials(insecure.NewCredentials()))
	}

	// 使用带超时的 context
	dialCtx, cancel := context.WithTimeout(ctx, cfg.Timeout)
	defer cancel()

	return grpc.DialContext(dialCtx, cfg.Target, opts...)
}

// Close 关闭所有连接
// 收集所有关闭错误，确保所有连接都被尝试关闭
func (p *Pool) Close() error {
	p.mu.Lock()
	defer p.mu.Unlock()

	var errs []error
	for name, conn := range p.conns {
		if conn != nil {
			if err := conn.Close(); err != nil {
				p.log.Error("failed to close grpc connection",
					slog.String("service", name),
					slog.Any("error", err))
				errs = append(errs, fmt.Errorf("%s: %w", name, err))
			} else {
				p.log.Debug("grpc connection closed", slog.String("service", name))
			}
		}
	}

	p.conns = make(map[string]*grpc.ClientConn)

	// 返回所有错误的汇总
	if len(errs) > 0 {
		return fmt.Errorf("关闭 %d 个连接时出错: %v", len(errs), errs)
	}
	return nil
}
