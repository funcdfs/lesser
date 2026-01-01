package worker

import (
	"context"
	"database/sql"

	"github.com/lesser/pkg/logger"
)

type NotificationWorker struct {
	db     *sql.DB
	logger *logger.Logger
}

func NewNotificationWorker(db *sql.DB, logger *logger.Logger) *NotificationWorker {
	return &NotificationWorker{
		db:     db,
		logger: logger,
	}
}

func (w *NotificationWorker) HandleList(ctx context.Context, body []byte) error {
	w.logger.Info("Received notification.list task")
	// TODO: 实现获取通知列表逻辑
	return nil
}

func (w *NotificationWorker) HandleRead(ctx context.Context, body []byte) error {
	w.logger.Info("Received notification.read task")
	// TODO: 实现标记已读逻辑
	return nil
}

func (w *NotificationWorker) HandleReadAll(ctx context.Context, body []byte) error {
	w.logger.Info("Received notification.read_all task")
	// TODO: 实现全部已读逻辑
	return nil
}
