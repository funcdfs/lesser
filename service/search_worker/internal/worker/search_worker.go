package worker

import (
	"context"
	"database/sql"

	"github.com/lesser/pkg/logger"
)

type SearchWorker struct {
	db     *sql.DB
	logger *logger.Logger
}

func NewSearchWorker(db *sql.DB, logger *logger.Logger) *SearchWorker {
	return &SearchWorker{
		db:     db,
		logger: logger,
	}
}

func (w *SearchWorker) HandleSearchPosts(ctx context.Context, body []byte) error {
	w.logger.Info("Received search.posts task")
	// TODO: 实现搜索帖子逻辑
	return nil
}

func (w *SearchWorker) HandleSearchUsers(ctx context.Context, body []byte) error {
	w.logger.Info("Received search.users task")
	// TODO: 实现搜索用户逻辑
	return nil
}
