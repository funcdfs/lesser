package database

import (
	"fmt"
	"time"

	"github.com/lesser/chat/pkg/logger"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	gormlogger "gorm.io/gorm/logger"
)

// NewPostgres creates a new PostgreSQL connection using GORM
func NewPostgres(databaseURL string) (*gorm.DB, error) {
	if databaseURL == "" {
		return nil, fmt.Errorf("database URL is required")
	}

	// Configure GORM with Zap Logger
	zapLogger := logger.Get() // Get global Zap logger
	gormLogger := NewZapGormLogger(zapLogger)
	
	// Apply custom configurations
	gormLogger.LogLevel = gormlogger.Warn
	gormLogger.SlowThreshold = time.Second
	gormLogger.IgnoreRecordNotFoundError = true

	config := &gorm.Config{
		Logger: gormLogger,
		NowFunc: func() time.Time {
			return time.Now().UTC()
		},
	}

	// Connect to database
	db, err := gorm.Open(postgres.Open(databaseURL), config)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Get underlying SQL DB
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get underlying DB: %w", err)
	}

	// Configure connection pool
	// 注意: PostgreSQL 默认 max_connections=100，需要合理分配给各服务
	// Go Chat 服务: 25, Django: 50, 预留: 25
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(25)
	sqlDB.SetConnMaxLifetime(time.Hour)
	sqlDB.SetConnMaxIdleTime(5 * time.Minute) // 空闲连接 5 分钟后回收

	// Test connection
	if err := sqlDB.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return db, nil
}

// AutoMigrate runs auto migration for the given models
func AutoMigrate(db *gorm.DB, models ...interface{}) error {
	return db.AutoMigrate(models...)
}
