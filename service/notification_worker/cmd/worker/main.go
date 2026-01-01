package main

import (
	"context"

	"github.com/lesser/notification_worker/internal/worker"
	"github.com/lesser/pkg/app"
	"github.com/lesser/pkg/broker"
)

func main() {
	ctx := context.Background()

	// 1. 从环境变量初始化配置
	cfg := app.ConfigFromEnv("notification-worker")

	// 2. 创建应用实例
	application, err := app.New(cfg)
	if err != nil {
		panic(err)
	}

	// 3. 创建 Worker 处理器
	notificationWorker := worker.NewNotificationWorker(application.DB(), application.Logger())

	// 4. 配置队列消费
	brokerConfigs := []broker.Config{
		{Queue: "notification.list", Handler: notificationWorker.HandleList},
		{Queue: "notification.read", Handler: notificationWorker.HandleRead},
		{Queue: "notification.read_all", Handler: notificationWorker.HandleReadAll},
	}

	// 5. 启动应用
	if err := application.Run(ctx, brokerConfigs...); err != nil {
		panic(err)
	}
}
