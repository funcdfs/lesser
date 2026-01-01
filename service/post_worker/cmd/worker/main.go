package main

import (
	"context"

	"github.com/lesser/post_worker/internal/worker"
	"github.com/lesser/pkg/app"
	"github.com/lesser/pkg/broker"
)

func main() {
	ctx := context.Background()

	// 1. 从环境变量初始化配置
	cfg := app.ConfigFromEnv("post-worker")

	// 2. 创建应用实例
	application, err := app.New(cfg)
	if err != nil {
		panic(err)
	}

	// 3. 创建 Worker 处理器
	postWorker := worker.NewPostWorker(application.DB(), application.Logger())

	// 4. 配置队列消费
	brokerConfigs := []broker.Config{
		{Queue: "post.create", Handler: postWorker.HandleCreate},
		{Queue: "post.get", Handler: postWorker.HandleGet},
		{Queue: "post.list", Handler: postWorker.HandleList},
		{Queue: "post.delete", Handler: postWorker.HandleDelete},
		{Queue: "post.update", Handler: postWorker.HandleUpdate},
	}

	// 5. 启动应用
	if err := application.Run(ctx, brokerConfigs...); err != nil {
		panic(err)
	}
}
