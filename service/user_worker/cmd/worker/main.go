package main

import (
	"context"

	"github.com/lesser/pkg/app"
	"github.com/lesser/pkg/broker"
	"github.com/lesser/user_worker/internal/worker"
)

func main() {
	ctx := context.Background()

	// 1. 从环境变量初始化配置
	cfg := app.ConfigFromEnv("user-worker")

	// 2. 创建应用实例
	application, err := app.New(cfg)
	if err != nil {
		panic(err)
	}

	// 3. 创建 Worker 处理器
	userWorker := worker.NewUserWorker(application.DB(), application.Logger())

	// 4. 配置队列消费
	brokerConfigs := []broker.Config{
		{Queue: "user.profile.get", Handler: userWorker.HandleProfileGet},
		{Queue: "user.profile.update", Handler: userWorker.HandleProfileUpdate},
		{Queue: "user.follow", Handler: userWorker.HandleFollow},
		{Queue: "user.unfollow", Handler: userWorker.HandleUnfollow},
		{Queue: "user.followers", Handler: userWorker.HandleFollowers},
		{Queue: "user.following", Handler: userWorker.HandleFollowing},
	}

	// 5. 启动应用
	if err := application.Run(ctx, brokerConfigs...); err != nil {
		panic(err)
	}
}
