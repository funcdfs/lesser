package worker

import (
	"context"
	"database/sql"

	"github.com/lesser/pkg/logger"
)

type FeedWorker struct {
	db  *sql.DB
	log *logger.Logger
}

func NewFeedWorker(db *sql.DB, log *logger.Logger) *FeedWorker {
	return &FeedWorker{db: db, log: log}
}

func (w *FeedWorker) HandleLike(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received feed.like task")
	return nil
}

func (w *FeedWorker) HandleUnlike(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received feed.unlike task")
	return nil
}

func (w *FeedWorker) HandleComment(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received feed.comment task")
	return nil
}

func (w *FeedWorker) HandleCommentDelete(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received feed.comment.delete task")
	return nil
}

func (w *FeedWorker) HandleRepost(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received feed.repost task")
	return nil
}

func (w *FeedWorker) HandleBookmark(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received feed.bookmark task")
	return nil
}

func (w *FeedWorker) HandleUnbookmark(ctx context.Context, body []byte) error {
	w.log.WithContext(ctx).Info("received feed.unbookmark task")
	return nil
}
