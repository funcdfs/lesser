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

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/grpc/interceptor"
	"github.com/funcdfs/lesser/pkg/trace"
	"github.com/funcdfs/lesser/timeline/internal/data_access"
	"github.com/funcdfs/lesser/timeline/internal/handler"
	"github.com/funcdfs/lesser/timeline/internal/logic"
	"github.com/funcdfs/lesser/timeline/internal/remote"
	pb "github.com/funcdfs/lesser/timeline/gen_protos/timeline"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	pkgLog := log.New("timeline")

	grpcPort := getEnv("GRPC_PORT", "50057")
	interactionServiceAddr := getEnv("INTERACTION_SERVICE_ADDR", "interaction:50056")

	// 初始化 OpenTelemetry
	ctx := context.Background()
	tracingCfg := trace.DefaultConfig("timeline")
	shutdown, err := trace.Init(ctx, tracingCfg)
	if err != nil {
		pkgLog.Error("初始化 OpenTelemetry 失败", slog.Any("error", err))
	} else {
		defer shutdown(ctx)
		pkgLog.Info("OpenTelemetry 初始化成功", slog.String("endpoint", tracingCfg.Endpoint))
	}

	// 数据库连接
	dbConfig := db.PostgresConfig{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser_db"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	database, err := db.NewPostgresConnection(dbConfig)
	if err != nil {
		pkgLog.Error("数据库连接失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer database.Close()
	pkgLog.Info("数据库连接成功", slog.String("db", dbConfig.DBName))

	// 初始化 Interaction Service 客户端
	interactionClient, err := remote.NewInteractionServiceClient(interactionServiceAddr, pkgLog)
	if err != nil {
		pkgLog.Error("连接 Interaction Service 失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer interactionClient.Close()
	pkgLog.Info("已连接 Interaction Service", slog.String("addr", interactionServiceAddr))

	// 初始化各层
	timelineRepo := data_access.NewTimelineRepository(database, pkgLog)
	timelineSvc := logic.NewTimelineService(timelineRepo, interactionClient)
	timelineHandler := handler.NewTimelineHandler(timelineSvc, pkgLog)

	// 创建 gRPC 服务器（带拦截器）
	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			interceptor.RecoveryInterceptor(pkgLog),
			interceptor.TraceInterceptor(),
			interceptor.LoggingInterceptor(pkgLog),
		),
	)
	pb.RegisterTimelineServiceServer(grpcServer, timelineHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		pkgLog.Error("端口监听失败", slog.String("port", grpcPort), slog.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		pkgLog.Info("收到关闭信号，开始关闭...")
		cancel()
		grpcServer.GracefulStop()
	}()

	pkgLog.Info("Timeline 服务已启动", slog.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		pkgLog.Error("gRPC 服务异常退出", slog.Any("error", err))
		os.Exit(1)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
