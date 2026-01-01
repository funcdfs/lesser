// Package example 展示如何使用 pkg 构建 Worker 服务
// 这是一个示例文件，展示重构后的 post_worker 代码
package example

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/lesser/pkg/app"
	"github.com/lesser/pkg/broker"
	"go.uber.org/zap"
)

// PostService 帖子业务逻辑
type PostService struct {
	app *app.App
}

// NewPostService 创建 PostService
func NewPostService(app *app.App) *PostService {
	return &PostService{app: app}
}

// HandleCreate 处理创建帖子
func (s *PostService) HandleCreate(ctx context.Context, body []byte) error {
	log := s.app.Logger().WithContext(ctx)
	log.Info("processing post.create task")

	// 解析请求
	var req struct {
		UserID  string `json:"user_id"`
		Content string `json:"content"`
	}
	if err := json.Unmarshal(body, &req); err != nil {
		return fmt.Errorf("failed to unmarshal request: %w", err)
	}

	// TODO: 实现创建帖子逻辑
	log.Info("post created",
		zap.String("user_id", req.UserID),
		zap.Int("content_length", len(req.Content)))

	return nil
}

// HandleDelete 处理删除帖子
func (s *PostService) HandleDelete(ctx context.Context, body []byte) error {
	log := s.app.Logger().WithContext(ctx)
	log.Info("processing post.delete task")
	// TODO: 实现删除帖子逻辑
	return nil
}

// ExampleMain 展示重构后的 main 函数
// 使用方式：将此函数的内容复制到 service/post_worker/cmd/worker/main.go
func ExampleMain() {
	ctx := context.Background()

	// 1. 从环境变量读取配置并初始化应用
	cfg := app.ConfigFromEnv("post-worker")
	application, err := app.New(cfg)
	if err != nil {
		panic(err)
	}

	// 2. 创建业务服务
	postSvc := NewPostService(application)

	// 3. 配置队列消费
	brokerConfigs := []broker.Config{
		{
			Queue:   "post.create",
			Handler: postSvc.HandleCreate,
		},
		{
			Queue:   "post.delete",
			Handler: postSvc.HandleDelete,
		},
		// 添加更多队列...
	}

	// 4. 启动应用（会阻塞直到收到停止信号）
	if err := application.Run(ctx, brokerConfigs...); err != nil {
		panic(err)
	}
}
