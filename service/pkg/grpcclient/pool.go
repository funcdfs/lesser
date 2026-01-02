package grpcclient

import (
	"context"
	"fmt"
	"sync"

	"github.com/funcdfs/lesser/pkg/logger"
	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// ClientPool gRPC 客户端连接池
type ClientPool struct {
	conns   map[string]*grpc.ClientConn
	configs map[string]ClientConfig
	mu      sync.RWMutex
	log     *logger.Logger
}

// NewClientPool 创建客户端连接池
func NewClientPool(log *logger.Logger) *ClientPool {
	return &ClientPool{
		conns:   make(map[string]*grpc.ClientConn),
		configs: make(map[string]ClientConfig),
		log:     log,
	}
}

// Register 注册服务配置
func (p *ClientPool) Register(name string, cfg ClientConfig) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.configs[name] = cfg
}

// RegisterFromEnv 从环境变量注册服务配置
func (p *ClientPool) RegisterFromEnv(serviceName string) {
	cfg := ConfigFromEnv(serviceName)
	p.Register(serviceName, cfg)
}

// GetConn 获取服务连接（懒加载）
func (p *ClientPool) GetConn(ctx context.Context, name string) (*grpc.ClientConn, error) {
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
	p.log.Info("grpc connection established", zap.String("service", name), zap.String("target", cfg.Target))

	return conn, nil
}

// dial 创建 gRPC 连接
func (p *ClientPool) dial(ctx context.Context, cfg ClientConfig) (*grpc.ClientConn, error) {
	opts := []grpc.DialOption{
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
func (p *ClientPool) Close() error {
	p.mu.Lock()
	defer p.mu.Unlock()

	var lastErr error
	for name, conn := range p.conns {
		if conn != nil {
			if err := conn.Close(); err != nil {
				p.log.Error("failed to close grpc connection",
					zap.String("service", name),
					zap.Error(err))
				lastErr = err
			}
		}
	}

	p.conns = make(map[string]*grpc.ClientConn)
	return lastErr
}
