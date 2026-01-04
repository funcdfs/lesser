// Timeline 服务入口
// 职责：Feed 流聚合
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/timeline/internal/remote"
	"github.com/funcdfs/lesser/timeline/internal/handler"
	"github.com/funcdfs/lesser/timeline/internal/data_access"
	"github.com/funcdfs/lesser/timeline/internal/logic"
	pb "github.com/funcdfs/lesser/timeline/gen_protos/timeline"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	log := initLogger()

	grpcPort := getEnv("GRPC_PORT", "50062")
	interactionServiceAddr := getEnv("INTERACTION_SERVICE_ADDR", "interaction:50060")

	// 数据库连接
	dbConfig := database.Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser_db"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Error("数据库连接失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()
	log.Info("数据库连接成功", slog.String("db", dbConfig.DBName))

	// 初始化 Interaction Service 客户端
	interactionClient, err := remote.NewInteractionServiceClient(interactionServiceAddr)
	if err != nil {
		log.Error("连接 Interaction Service 失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer interactionClient.Close()
	log.Info("已连接 Interaction Service", slog.String("addr", interactionServiceAddr))

	// 初始化各层
	timelineRepo := data_access.NewTimelineRepository(db, log)
	timelineSvc := logic.NewTimelineService(timelineRepo, interactionClient)
	timelineHandler := handler.NewTimelineHandler(timelineSvc, log)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterTimelineServiceServer(grpcServer, timelineHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Error("端口监听失败", slog.String("port", grpcPort), slog.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Info("收到关闭信号，开始关闭...")
		cancel()
		grpcServer.GracefulStop()
	}()

	log.Info("Timeline 服务已启动", slog.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		log.Error("gRPC 服务异常退出", slog.Any("error", err))
		os.Exit(1)
	}
}

func initLogger() *slog.Logger {
	var h slog.Handler
	if os.Getenv("ENV") == "production" {
		h = slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo, AddSource: true})
	} else {
		h = slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelDebug, AddSource: true})
	}
	return slog.New(h).With(slog.String("service", "timeline"))
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
