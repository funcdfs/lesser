// Package data_access 提供数据访问层实现
package data_access

import (
	"context"
	"database/sql"
	"errors"
	"time"
)

// BanDataAccessImpl PostgreSQL 封禁数据访问实现
type BanDataAccessImpl struct {
	db *sql.DB
}

// NewBanDataAccess 创建封禁数据访问
func NewBanDataAccess(db *sql.DB) *BanDataAccessImpl {
	return &BanDataAccessImpl{db: db}
}

// Create 创建封禁记录
func (r *BanDataAccessImpl) Create(ctx context.Context, ban *Ban) error {
	// 先将该用户的旧封禁记录设为非活跃
	deactivateQuery := `UPDATE user_bans SET is_active = false WHERE user_id = $1 AND is_active = true`
	_, _ = r.db.ExecContext(ctx, deactivateQuery, ban.UserID)

	query := `
		INSERT INTO user_bans (id, user_id, reason, expires_at, operator_id, is_active, created_at)
		VALUES ($1, $2, $3, $4, $5, true, $6)
	`
	_, err := r.db.ExecContext(ctx, query,
		ban.ID, ban.UserID, ban.Reason, ban.ExpiresAt, ban.CreatedBy, ban.CreatedAt,
	)
	return err
}

// GetByUserID 获取用户的活跃封禁记录
func (r *BanDataAccessImpl) GetByUserID(ctx context.Context, userID string) (*Ban, error) {
	query := `
		SELECT id, user_id, reason, expires_at, created_at, COALESCE(operator_id::text, '')
		FROM user_bans WHERE user_id = $1 AND is_active = true
	`

	ban := &Ban{}
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

// Delete 删除封禁记录（解封）- 将 is_active 设为 false
func (r *BanDataAccessImpl) Delete(ctx context.Context, userID string) error {
	query := `UPDATE user_bans SET is_active = false, updated_at = NOW() WHERE user_id = $1 AND is_active = true`
	_, err := r.db.ExecContext(ctx, query, userID)
	return err
}

// IsUserBanned 检查用户是否被封禁
func (r *BanDataAccessImpl) IsUserBanned(ctx context.Context, userID string) (bool, *Ban, error) {
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
var _ BanDataAccess = (*BanDataAccessImpl)(nil)
