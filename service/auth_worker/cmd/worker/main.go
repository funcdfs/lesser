package main

import (
	"context"
	"os"

	"github.com/lesser/auth_worker/internal/service"
	"github.com/lesser/auth_worker/internal/worker"
	"github.com/lesser/pkg/app"
	"github.com/lesser/pkg/broker"
)

func main() {
	ctx := context.Background()

	// 1. 从环境变量初始化配置
	cfg := app.ConfigFromEnv("auth-worker")

	// 2. 创建应用实例
	application, err := app.New(cfg)
	if err != nil {
		panic(err)
	}

	// 3. 获取 JWT Secret
	jwtSecret := getEnv("JWT_SECRET", "your-secret-key")

	// 4. 创建业务服务
	authSvc := service.NewAuthService(application.DB(), jwtSecret)

	// 5. 创建 Worker 处理器
	authWorker := worker.NewAuthWorker(authSvc, application.Worker(), application.Logger())

	// 6. 配置队列消费
	// 注意: auth.login 和 auth.register 已迁移到 Gateway 同步处理
	// 保留 Auth Worker 用于其他异步任务（如密码重置邮件）
	brokerConfigs := []broker.Config{
		// 密码重置等异步任务（未来扩展）
		{Queue: "auth.password_reset", Handler: authWorker.HandlePasswordReset},
	}

	// 7. 启动应用
	if err := application.Run(ctx, brokerConfigs...); err != nil {
		panic(err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
