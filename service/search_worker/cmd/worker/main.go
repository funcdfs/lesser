package main

import (
	"context"

	"github.com/lesser/pkg/app"
	"github.com/lesser/pkg/broker"
	"github.com/lesser/search_worker/internal/worker"
)

func main() {
	ctx := context.Background()

	// 1. 从环境变量初始化配置
	cfg := app.ConfigFromEnv("search-worker")

	// 2. 创建应用实例
	application, err := app.New(cfg)
	if err != nil {
		panic(err)
	}

	// 3. 创建 Worker 处理器
	searchWorker := worker.NewSearchWorker(application.DB(), application.Logger())

	// 4. 配置队列消费
	brokerConfigs := []broker.Config{
		{Queue: "search.posts", Handler: searchWorker.HandleSearchPosts},
		{Queue: "search.users", Handler: searchWorker.HandleSearchUsers},
	}

	// 5. 启动应用
	if err := application.Run(ctx, brokerConfigs...); err != nil {
		panic(err)
	}
}
