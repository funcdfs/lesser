package worker

import (
	"context"
	"database/sql"

	"github.com/lesser/pkg/logger"
)

type PostWorker struct {
	db     *sql.DB
	logger *logger.Logger
}

func NewPostWorker(db *sql.DB, logger *logger.Logger) *PostWorker {
	return &PostWorker{
		db:     db,
		logger: logger,
	}
}

func (w *PostWorker) HandleCreate(ctx context.Context, body []byte) error {
	w.logger.Info("Received post.create task")
	// TODO: 实现创建帖子逻辑
	return nil
}

func (w *PostWorker) HandleGet(ctx context.Context, body []byte) error {
	w.logger.Info("Received post.get task")
	// TODO: 实现获取帖子逻辑
	return nil
}

func (w *PostWorker) HandleList(ctx context.Context, body []byte) error {
	w.logger.Info("Received post.list task")
	// TODO: 实现获取帖子列表逻辑
	return nil
}

func (w *PostWorker) HandleDelete(ctx context.Context, body []byte) error {
	w.logger.Info("Received post.delete task")
	// TODO: 实现删除帖子逻辑
	return nil
}

func (w *PostWorker) HandleUpdate(ctx context.Context, body []byte) error {
	w.logger.Info("Received post.update task")
	// TODO: 实现更新帖子逻辑
	return nil
}
