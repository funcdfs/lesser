// Package postgres 提供 PostgreSQL 数据访问实现
package postgres

import (
	"context"
	"database/sql"
	"time"

	"github.com/funcdfs/lesser/auth/internal/data_access"
)

// UserRepository PostgreSQL 用户仓库实现
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository 创建用户仓库
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create 创建用户
func (r *UserRepository) Create(ctx context.Context, user *data_access.User) error {
	query := `
		INSERT INTO users (
			id, username, email, password, display_name, bio, 
			is_active, is_staff, is_superuser, is_verified, 
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, false, false, false, $8, $9)
	`
	_, err := r.db.ExecContext(ctx, query,
		user.ID, user.Username, user.Email, user.Password,
		user.DisplayName, user.Bio, user.IsActive,
		user.CreatedAt, user.UpdatedAt,
	)
	return err
}

// GetByID 根据 ID 获取用户
func (r *UserRepository) GetByID(ctx context.Context, id string) (*data_access.User, error) {
	return r.getUser(ctx, "id", id)
}

// GetByEmail 根据邮箱获取用户
func (r *UserRepository) GetByEmail(ctx context.Context, email string) (*data_access.User, error) {
	return r.getUser(ctx, "email", email)
}

// GetByUsername 根据用户名获取用户
func (r *UserRepository) GetByUsername(ctx context.Context, username string) (*data_access.User, error) {
	return r.getUser(ctx, "username", username)
}

// getUser 通用查询方法
func (r *UserRepository) getUser(ctx context.Context, field, value string) (*data_access.User, error) {
	query := `
		SELECT id, username, email, password, display_name, avatar_url, bio, 
		       is_active, is_verified, created_at, updated_at
		FROM users WHERE ` + field + ` = $1
	`

	user := &data_access.User{}
	var displayName, avatarURL, bio sql.NullString

	err := r.db.QueryRowContext(ctx, query, value).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password,
		&displayName, &avatarURL, &bio,
		&user.IsActive, &user.IsVerified,
		&user.CreatedAt, &user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, data_access.ErrUserNotFound
	}
	if err != nil {
		return nil, err
	}

	user.DisplayName = displayName.String
	user.AvatarURL = avatarURL.String
	user.Bio = bio.String

	return user, nil
}

// ExistsByEmailOrUsername 检查邮箱或用户名是否已存在
func (r *UserRepository) ExistsByEmailOrUsername(ctx context.Context, email, username string) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE email = $1 OR username = $2)`
	var exists bool
	err := r.db.QueryRowContext(ctx, query, email, username).Scan(&exists)
	return exists, err
}

// UpdatePassword 更新密码
func (r *UserRepository) UpdatePassword(ctx context.Context, userID, hashedPassword string) error {
	query := `UPDATE users SET password = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, hashedPassword, time.Now(), userID)
	return err
}

// UpdateLastLogin 更新最后登录时间
func (r *UserRepository) UpdateLastLogin(ctx context.Context, userID string) error {
	query := `UPDATE users SET updated_at = $1 WHERE id = $2`
	_, err := r.db.ExecContext(ctx, query, time.Now(), userID)
	return err
}

// 确保实现接口
var _ data_access.UserRepository = (*UserRepository)(nil)
