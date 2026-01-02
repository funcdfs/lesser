package repository

import (
	"database/sql"
	"time"
)

// Ban 封禁记录
type Ban struct {
	ID        string
	UserID    string
	Reason    string
	ExpiresAt *time.Time // nil 表示永久封禁
	CreatedAt time.Time
}

// BanRepository 封禁数据访问
type BanRepository struct {
	db *sql.DB
}

// NewBanRepository 创建封禁仓库
func NewBanRepository(db *sql.DB) *BanRepository {
	return &BanRepository{db: db}
}

// Create 创建封禁记录
func (r *BanRepository) Create(ban *Ban) error {
	_, err := r.db.Exec(`
		INSERT INTO user_bans (id, user_id, reason, expires_at, created_at)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (user_id) DO UPDATE SET
			reason = EXCLUDED.reason,
			expires_at = EXCLUDED.expires_at,
			created_at = EXCLUDED.created_at
	`, ban.ID, ban.UserID, ban.Reason, ban.ExpiresAt, ban.CreatedAt)
	return err
}

// GetByUserID 获取用户的封禁记录
func (r *BanRepository) GetByUserID(userID string) (*Ban, error) {
	ban := &Ban{}
	var expiresAt sql.NullTime

	err := r.db.QueryRow(`
		SELECT id, user_id, reason, expires_at, created_at
		FROM user_bans WHERE user_id = $1
	`, userID).Scan(&ban.ID, &ban.UserID, &ban.Reason, &expiresAt, &ban.CreatedAt)
	if err == sql.ErrNoRows {
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
func (r *BanRepository) Delete(userID string) error {
	_, err := r.db.Exec(`DELETE FROM user_bans WHERE user_id = $1`, userID)
	return err
}

// IsUserBanned 检查用户是否被封禁
func (r *BanRepository) IsUserBanned(userID string) (bool, *Ban, error) {
	ban, err := r.GetByUserID(userID)
	if err != nil {
		return false, nil, err
	}
	if ban == nil {
		return false, nil, nil
	}

	// 检查是否已过期
	if ban.ExpiresAt != nil && ban.ExpiresAt.Before(time.Now()) {
		// 封禁已过期，删除记录
		_ = r.Delete(userID)
		return false, nil, nil
	}

	return true, ban, nil
}
