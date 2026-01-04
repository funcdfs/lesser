// Package main SuperUser 服务入口
// 职责：超级管理员认证、用户管理、内容管理、系统监控
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/superuser/internal/config"
	"github.com/funcdfs/lesser/superuser/internal/crypto"
	"github.com/funcdfs/lesser/superuser/internal/handler"
	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"github.com/funcdfs/lesser/superuser/internal/data_access/postgres"
	"github.com/funcdfs/lesser/superuser/internal/logic"
	pb "github.com/funcdfs/lesser/superuser/gen_protos/superuser"
	"github.com/redis/go-redis/v9"
)

func main() {
	// 初始化日志
	log := initLogger()

	// 加载配置
	cfg := config.LoadFromEnv()
	log.Info("配置已加载",
		slog.String("service", cfg.ServiceName),
		slog.String("port", cfg.GRPCPort))

	// 初始化数据库
	db, err := database.NewConnection(database.Config{
		Host:     cfg.DBHost,
		Port:     cfg.DBPort,
		User:     cfg.DBUser,
		Password: cfg.DBPassword,
		DBName:   cfg.DBName,
		SSLMode:  cfg.DBSSLMode,
	})
	if err != nil {
		log.Error("连接数据库失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()
	log.Info("数据库连接成功")

	// 初始化 Redis
	var redisClient *redis.Client
	if cfg.RedisURL != "" {
		opt, err := redis.ParseURL(cfg.RedisURL)
		if err != nil {
			log.Warn("解析 Redis URL 失败", slog.Any("error", err))
		} else {
			redisClient = redis.NewClient(opt)
			if err := redisClient.Ping(context.Background()).Err(); err != nil {
				log.Warn("连接 Redis 失败", slog.Any("error", err))
				redisClient = nil
			} else {
				defer redisClient.Close()
				log.Info("Redis 连接成功")
			}
		}
	}

	// 创建仓库
	superUserRepo := postgres.NewSuperUserRepository(db)
	auditLogRepo := postgres.NewAuditLogRepository(db)
	sessionRepo := postgres.NewSessionRepository(db)
	userRepo := postgres.NewUserRepository(db)
	contentRepo := postgres.NewContentRepository(db)
	systemRepo := postgres.NewSystemRepository(db)

	// 创建密码哈希器
	passwordHasher := crypto.NewPasswordHasher(&crypto.Argon2Params{
		Memory:      cfg.Argon2Memory,
		Iterations:  cfg.Argon2Iterations,
		Parallelism: cfg.Argon2Parallelism,
		SaltLength:  cfg.Argon2SaltLength,
		KeyLength:   cfg.Argon2KeyLength,
	})

	// 创建 JWT 管理器
	jwtManager := crypto.NewJWTManager(
		cfg.JWTSecret,
		cfg.AccessTokenDuration,
		cfg.RefreshTokenDuration,
	)

	// 初始化默认超级管理员
	if err := initDefaultSuperUser(context.Background(), superUserRepo, passwordHasher, cfg, log); err != nil {
		log.Error("初始化默认超级管理员失败", slog.Any("error", err))
		os.Exit(1)
	}

	// 创建服务
	superUserService := logic.NewSuperUserService(logic.ServiceDeps{
		SuperUserRepo:  superUserRepo,
		AuditLogRepo:   auditLogRepo,
		SessionRepo:    sessionRepo,
		UserRepo:       userRepo,
		ContentRepo:    contentRepo,
		SystemRepo:     systemRepo,
		PasswordHasher: passwordHasher,
		JWTManager:     jwtManager,
		RedisClient:    redisClient,
		Config:         cfg,
		Logger:         log,
	})

	// 创建 gRPC 处理器
	superUserHandler := handler.NewSuperUserHandler(superUserService, log)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterSuperUserServiceServer(grpcServer, superUserHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+cfg.GRPCPort)
	if err != nil {
		log.Error("监听端口失败", slog.String("port", cfg.GRPCPort), slog.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	go gracefulShutdown(grpcServer, log)

	log.Info("SuperUser 服务已启动", slog.String("port", cfg.GRPCPort))
	if err := grpcServer.Serve(lis); err != nil {
		log.Error("gRPC 服务异常退出", slog.Any("error", err))
		os.Exit(1)
	}
}

// initLogger 初始化日志
func initLogger() *slog.Logger {
	var handler slog.Handler

	if os.Getenv("ENV") == "production" {
		handler = slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
			Level:     slog.LevelInfo,
			AddSource: true,
		})
	} else {
		handler = slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
			Level:     slog.LevelDebug,
			AddSource: true,
		})
	}

	return slog.New(handler).With(slog.String("service", "superuser"))
}

// initDefaultSuperUser 初始化默认超级管理员
func initDefaultSuperUser(ctx context.Context, repo data_access.SuperUserRepository, hasher *crypto.PasswordHasher, cfg *config.Config, log *slog.Logger) error {
	// 检查是否已存在
	exists, err := repo.ExistsByUsername(ctx, cfg.DefaultUsername)
	if err != nil {
		return err
	}
	if exists {
		log.Info("默认超级管理员已存在", slog.String("username", cfg.DefaultUsername))

		// 更新密码（确保密码是最新的哈希）
		su, err := repo.GetByUsername(ctx, cfg.DefaultUsername)
		if err != nil {
			return err
		}

		// 检查密码是否是占位符
		if su.Password == "$placeholder$" {
			hashedPassword, err := hasher.Hash(cfg.DefaultPassword)
			if err != nil {
				return err
			}
			su.Password = hashedPassword
			if err := repo.Update(ctx, su); err != nil {
				return err
			}
			log.Info("已更新默认超级管理员密码")
		}
		return nil
	}

	// 创建默认超级管理员
	hashedPassword, err := hasher.Hash(cfg.DefaultPassword)
	if err != nil {
		return err
	}

	su := &data_access.SuperUser{
		Username:    cfg.DefaultUsername,
		Email:       cfg.DefaultEmail,
		Password:    hashedPassword,
		DisplayName: cfg.DefaultDisplayName,
		IsActive:    true,
	}

	if err := repo.Create(ctx, su); err != nil {
		return err
	}

	log.Info("已创建默认超级管理员",
		slog.String("username", cfg.DefaultUsername),
		slog.String("email", cfg.DefaultEmail))

	return nil
}

// gracefulShutdown 优雅关闭
func gracefulShutdown(grpcServer *grpc.Server, log *slog.Logger) {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	log.Info("收到关闭信号，开始关闭...")
	grpcServer.GracefulStop()
	log.Info("服务已关闭")
}
