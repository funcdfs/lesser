// Package data_access 提供数据访问层实现
package data_access

import (
	"context"
	"database/sql"
	"time"
)

// UserDataAccessImpl PostgreSQL 用户数据访问实现
type UserDataAccessImpl struct {
	db *sql.DB
}

// NewUserDataAccess 创建用户数据访问
func NewUserDataAccess(db *sql.DB) *UserDataAccessImpl {
	return &UserDataAccessImpl{db: db}
}

// Create 创建用户
func (r *UserDataAccessImpl) Create(ctx context.Context, user *User) error {
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
func (r *UserDataAccessImpl) GetByID(ctx context.Context, id string) (*User, error) {
	return r.getUser(ctx, "id", id)
}

// GetByEmail 根据邮箱获取用户
func (r *UserDataAccessImpl) GetByEmail(ctx context.Context, email string) (*User, error) {
	return r.getUser(ctx, "email", email)
}

// GetByUsername 根据用户名获取用户
func (r *UserDataAccessImpl) GetByUsername(ctx context.Context, username string) (*User, error) {
	return r.getUser(ctx, "username", username)
}

// getUser 通用查询方法
// 注意：field 参数必须是预定义的安全字段名，不能来自用户输入
func (r *UserDataAccessImpl) getUser(ctx context.Context, field, value string) (*User, error) {
	// 白名单验证，防止 SQL 注入
	allowedFields := map[string]bool{
		"id":       true,
		"email":    true,
		"username": true,
	}
	if !allowedFields[field] {
		return nil, ErrInvalidInput
	}

	// 使用预定义的查询模板
	var query string
	switch field {
	case "id":
		query = `SELECT id, username, email, password, display_name, avatar_url, bio, 
		         is_active, is_verified, created_at, updated_at
		         FROM users WHERE id = $1`
	case "email":
		query = `SELECT id, username, email, password, display_name, avatar_url, bio, 
		         is_active, is_verified, created_at, updated_at
		         FROM users WHERE email = $1`
	case "username":
		query = `SELECT id, username, email, password, display_name, avatar_url, bio, 
		         is_active, is_verified, created_at, updated_at
		         FROM users WHERE username = $1`
	}

	user := &User{}
	var displayName, avatarURL, bio sql.NullString

	err := r.db.QueryRowContext(ctx, query, value).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password,
		&displayName, &avatarURL, &bio,
		&user.IsActive, &user.IsVerified,
		&user.CreatedAt, &user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, ErrUserNotFound
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
func (r *UserDataAccessImpl) ExistsByEmailOrUsername(ctx context.Context, email, username string) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE email = $1 OR username = $2)`
	var exists bool
	err := r.db.QueryRowContext(ctx, query, email, username).Scan(&exists)
	return exists, err
}

// UpdatePassword 更新密码
func (r *UserDataAccessImpl) UpdatePassword(ctx context.Context, userID, hashedPassword string) error {
	query := `UPDATE users SET password = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, hashedPassword, time.Now(), userID)
	return err
}

// UpdateLastLogin 更新最后登录时间
func (r *UserDataAccessImpl) UpdateLastLogin(ctx context.Context, userID string) error {
	query := `UPDATE users SET updated_at = $1 WHERE id = $2`
	_, err := r.db.ExecContext(ctx, query, time.Now(), userID)
	return err
}

// 确保实现接口
var _ UserDataAccess = (*UserDataAccessImpl)(nil)
