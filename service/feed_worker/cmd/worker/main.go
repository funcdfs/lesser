package main

import (
	"context"

	"github.com/lesser/feed_worker/internal/worker"
	"github.com/lesser/pkg/app"
	"github.com/lesser/pkg/broker"
)

func main() {
	ctx := context.Background()

	cfg := app.ConfigFromEnv("feed-worker")

	application, err := app.New(cfg)
	if err != nil {
		panic(err)
	}

	feedWorker := worker.NewFeedWorker(application.DB(), application.Logger())

	brokerConfigs := []broker.Config{
		{Queue: "feed.like", Handler: feedWorker.HandleLike},
		{Queue: "feed.unlike", Handler: feedWorker.HandleUnlike},
		{Queue: "feed.comment", Handler: feedWorker.HandleComment},
		{Queue: "feed.comment.delete", Handler: feedWorker.HandleCommentDelete},
		{Queue: "feed.repost", Handler: feedWorker.HandleRepost},
		{Queue: "feed.bookmark", Handler: feedWorker.HandleBookmark},
		{Queue: "feed.unbookmark", Handler: feedWorker.HandleUnbookmark},
	}

	if err := application.Run(ctx, brokerConfigs...); err != nil {
		panic(err)
	}
}
