// Package health 提供健康检查功能
// 支持多组件健康状态聚合
package health

import (
	"context"
	"database/sql"
	"encoding/json"
	"sync"
	"time"

	"github.com/funcdfs/lesser/pkg/cache"
)

// Status 健康状态
type Status string

const (
	StatusHealthy   Status = "healthy"
	StatusUnhealthy Status = "unhealthy"
	StatusDegraded  Status = "degraded"
)

// ComponentHealth 组件健康状态
type ComponentHealth struct {
	Name    string        `json:"name"`
	Status  Status        `json:"status"`
	Message string        `json:"message,omitempty"`
	Latency time.Duration `json:"latency_ms"`
}

// Report 健康报告
type Report struct {
	Status     Status            `json:"status"`
	Components []ComponentHealth `json:"components"`
	Timestamp  time.Time         `json:"timestamp"`
}

// Checker 健康检查器
type Checker struct {
	checks []Check
	mu     sync.RWMutex
}

// Check 健康检查函数
type Check struct {
	Name string
	Fn   func(ctx context.Context) error
}

// NewChecker 创建健康检查器
func NewChecker() *Checker {
	return &Checker{
		checks: make([]Check, 0),
	}
}

// Register 注册健康检查
func (c *Checker) Register(name string, fn func(ctx context.Context) error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.checks = append(c.checks, Check{Name: name, Fn: fn})
}

// Check 执行健康检查
func (c *Checker) Check(ctx context.Context) *Report {
	c.mu.RLock()
	checks := make([]Check, len(c.checks))
	copy(checks, c.checks)
	c.mu.RUnlock()

	report := &Report{
		Status:     StatusHealthy,
		Components: make([]ComponentHealth, 0, len(checks)),
		Timestamp:  time.Now(),
	}

	var wg sync.WaitGroup
	results := make(chan ComponentHealth, len(checks))

	for _, check := range checks {
		wg.Add(1)
		go func(chk Check) {
			defer wg.Done()

			start := time.Now()
			err := chk.Fn(ctx)
			latency := time.Since(start)

			health := ComponentHealth{
				Name:    chk.Name,
				Status:  StatusHealthy,
				Latency: latency,
			}

			if err != nil {
				health.Status = StatusUnhealthy
				health.Message = err.Error()
			}

			results <- health
		}(check)
	}

	// 等待所有检查完成
	go func() {
		wg.Wait()
		close(results)
	}()

	// 收集结果
	for health := range results {
		report.Components = append(report.Components, health)
		if health.Status == StatusUnhealthy {
			report.Status = StatusUnhealthy
		} else if health.Status == StatusDegraded && report.Status == StatusHealthy {
			report.Status = StatusDegraded
		}
	}

	return report
}

// IsHealthy 检查是否健康
func (c *Checker) IsHealthy(ctx context.Context) bool {
	report := c.Check(ctx)
	return report.Status == StatusHealthy
}

// ToJSON 转换为 JSON
func (r *Report) ToJSON() ([]byte, error) {
	return json.Marshal(r)
}

// ---- 预定义检查函数 ----

// DatabaseCheck 创建数据库健康检查
func DatabaseCheck(db *sql.DB) func(ctx context.Context) error {
	return func(ctx context.Context) error {
		return db.PingContext(ctx)
	}
}

// RedisCheck 创建 Redis 健康检查
func RedisCheck(client *cache.Client) func(ctx context.Context) error {
	return func(ctx context.Context) error {
		return client.GetClient().Ping(ctx).Err()
	}
}

// CustomCheck 创建自定义健康检查
func CustomCheck(fn func() error) func(ctx context.Context) error {
	return func(ctx context.Context) error {
		return fn()
	}
}

// TimeoutCheck 创建带超时的健康检查
func TimeoutCheck(timeout time.Duration, fn func(ctx context.Context) error) func(ctx context.Context) error {
	return func(ctx context.Context) error {
		ctx, cancel := context.WithTimeout(ctx, timeout)
		defer cancel()
		return fn(ctx)
	}
}

// ---- 全局健康检查器 ----

var globalChecker = NewChecker()

// RegisterGlobal 注册全局健康检查
func RegisterGlobal(name string, fn func(ctx context.Context) error) {
	globalChecker.Register(name, fn)
}

// CheckGlobal 执行全局健康检查
func CheckGlobal(ctx context.Context) *Report {
	return globalChecker.Check(ctx)
}

// IsGlobalHealthy 检查全局是否健康
func IsGlobalHealthy(ctx context.Context) bool {
	return globalChecker.IsHealthy(ctx)
}
