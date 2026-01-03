// Package postgres 提供 PostgreSQL 数据访问实现
package postgres

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/funcdfs/lesser/auth/internal/repository"
)

// BanRepository PostgreSQL 封禁仓库实现
type BanRepository struct {
	db *sql.DB
}

// NewBanRepository 创建封禁仓库
func NewBanRepository(db *sql.DB) *BanRepository {
	return &BanRepository{db: db}
}

// Create 创建封禁记录
func (r *BanRepository) Create(ctx context.Context, ban *repository.Ban) error {
	query := `
		INSERT INTO user_bans (id, user_id, reason, expires_at, created_at, created_by)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (user_id) DO UPDATE SET
			reason = EXCLUDED.reason,
			expires_at = EXCLUDED.expires_at,
			created_at = EXCLUDED.created_at,
			created_by = EXCLUDED.created_by
	`
	_, err := r.db.ExecContext(ctx, query,
		ban.ID, ban.UserID, ban.Reason, ban.ExpiresAt, ban.CreatedAt, ban.CreatedBy,
	)
	return err
}

// GetByUserID 获取用户的封禁记录
func (r *BanRepository) GetByUserID(ctx context.Context, userID string) (*repository.Ban, error) {
	query := `
		SELECT id, user_id, reason, expires_at, created_at, COALESCE(created_by, '')
		FROM user_bans WHERE user_id = $1
	`

	ban := &repository.Ban{}
	var expiresAt sql.NullTime

	err := r.db.QueryRowContext(ctx, query, userID).Scan(
		&ban.ID, &ban.UserID, &ban.Reason, &expiresAt, &ban.CreatedAt, &ban.CreatedBy,
	)

	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil // 未被封禁
	}
	if err != nil {
		return nil, err
	}

	if expiresAt.Valid {
		ban.ExpiresAt = &expiresAt.Time
	}

	return ban, nil
}

// Delete 删除封禁记录（解封）
func (r *BanRepository) Delete(ctx context.Context, userID string) error {
	query := `DELETE FROM user_bans WHERE user_id = $1`
	_, err := r.db.ExecContext(ctx, query, userID)
	return err
}

// IsUserBanned 检查用户是否被封禁
func (r *BanRepository) IsUserBanned(ctx context.Context, userID string) (bool, *repository.Ban, error) {
	ban, err := r.GetByUserID(ctx, userID)
	if err != nil {
		return false, nil, err
	}
	if ban == nil {
		return false, nil, nil
	}

	// 检查是否已过期
	if ban.ExpiresAt != nil && ban.ExpiresAt.Before(time.Now()) {
		// 封禁已过期，删除记录
		_ = r.Delete(ctx, userID)
		return false, nil, nil
	}

	return true, ban, nil
}

// 确保实现接口
var _ repository.BanRepository = (*BanRepository)(nil)
