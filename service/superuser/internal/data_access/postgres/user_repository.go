// Package postgres 用户管理 PostgreSQL 仓库实现
package postgres

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"github.com/google/uuid"
)

// UserRepository PostgreSQL 用户仓库（用于管理普通用户）
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository 创建用户仓库
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// List 获取用户列表
func (r *UserRepository) List(ctx context.Context, filter data_access.UserFilter) ([]*data_access.User, int, error) {
	// 构建查询条件
	var conditions []string
	var args []interface{}
	argIndex := 1

	if filter.Search != nil && *filter.Search != "" {
		conditions = append(conditions, fmt.Sprintf("(u.username ILIKE $%d OR u.email ILIKE $%d OR u.display_name ILIKE $%d)", argIndex, argIndex, argIndex))
		args = append(args, "%"+*filter.Search+"%")
		argIndex++
	}
	if filter.Status != nil {
		switch *filter.Status {
		case "active":
			conditions = append(conditions, "u.is_active = true AND NOT EXISTS (SELECT 1 FROM user_bans ub WHERE ub.user_id = u.id AND ub.is_active = true)")
		case "banned":
			conditions = append(conditions, "EXISTS (SELECT 1 FROM user_bans ub WHERE ub.user_id = u.id AND ub.is_active = true)")
		}
	}

	whereClause := ""
	if len(conditions) > 0 {
		whereClause = "WHERE " + strings.Join(conditions, " AND ")
	}

	// 获取总数
	countQuery := fmt.Sprintf(`SELECT COUNT(*) FROM users u %s`, whereClause)
	var total int
	if err := r.db.QueryRowContext(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	// 排序
	sortBy := "created_at"
	if filter.SortBy != "" {
		switch filter.SortBy {
		case "username", "email", "followers_count", "following_count", "posts_count", "created_at":
			sortBy = filter.SortBy
		}
	}
	sortOrder := "DESC"
	if filter.SortOrder == "asc" {
		sortOrder = "ASC"
	}

	// 分页
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 20
	}
	offset := (filter.Page - 1) * filter.PageSize

	query := fmt.Sprintf(`
		SELECT u.id, u.username, u.email, u.display_name, u.bio, u.avatar_url, u.is_active,
		       COALESCE(ub.is_active, false) as is_banned, ub.reason as ban_reason, ub.expires_at as ban_expires_at,
		       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at
		FROM users u
		LEFT JOIN user_bans ub ON u.id = ub.user_id AND ub.is_active = true
		%s
		ORDER BY u.%s %s
		LIMIT $%d OFFSET $%d
	`, whereClause, sortBy, sortOrder, argIndex, argIndex+1)
	args = append(args, filter.PageSize, offset)

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var users []*data_access.User
	for rows.Next() {
		user := &data_access.User{}
		err := rows.Scan(
			&user.ID, &user.Username, &user.Email, &user.DisplayName, &user.Bio, &user.AvatarURL, &user.IsActive,
			&user.IsBanned, &user.BanReason, &user.BanExpiresAt,
			&user.FollowersCount, &user.FollowingCount, &user.PostsCount, &user.CreatedAt, &user.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		users = append(users, user)
	}

	return users, total, rows.Err()
}

// GetByID 根据 ID 获取用户
func (r *UserRepository) GetByID(ctx context.Context, id uuid.UUID) (*data_access.User, error) {
	query := `
		SELECT u.id, u.username, u.email, u.display_name, u.bio, u.avatar_url, u.is_active,
		       COALESCE(ub.is_active, false) as is_banned, ub.reason as ban_reason, ub.expires_at as ban_expires_at,
		       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at
		FROM users u
		LEFT JOIN user_bans ub ON u.id = ub.user_id AND ub.is_active = true
		WHERE u.id = $1
	`
	user := &data_access.User{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&user.ID, &user.Username, &user.Email, &user.DisplayName, &user.Bio, &user.AvatarURL, &user.IsActive,
		&user.IsBanned, &user.BanReason, &user.BanExpiresAt,
		&user.FollowersCount, &user.FollowingCount, &user.PostsCount, &user.CreatedAt, &user.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return user, nil
}

// Update 更新用户
func (r *UserRepository) Update(ctx context.Context, user *data_access.User) error {
	query := `
		UPDATE users 
		SET username = $2, email = $3, display_name = $4, bio = $5, is_active = $6, updated_at = $7
		WHERE id = $1
	`
	user.UpdatedAt = time.Now()
	_, err := r.db.ExecContext(ctx, query,
		user.ID, user.Username, user.Email, user.DisplayName, user.Bio, user.IsActive, user.UpdatedAt)
	return err
}

// SoftDelete 软删除用户
func (r *UserRepository) SoftDelete(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE users SET is_active = false, updated_at = $2 WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id, time.Now())
	return err
}

// HardDelete 硬删除用户
func (r *UserRepository) HardDelete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM users WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}

// Ban 封禁用户
func (r *UserRepository) Ban(ctx context.Context, id uuid.UUID, reason string, expiresAt *time.Time, operatorID uuid.UUID) error {
	// 先取消之前的封禁记录
	_, _ = r.db.ExecContext(ctx, `UPDATE user_bans SET is_active = false WHERE user_id = $1 AND is_active = true`, id)

	// 创建新的封禁记录
	query := `
		INSERT INTO user_bans (user_id, reason, expires_at, operator_id, is_active)
		VALUES ($1, $2, $3, $4, true)
	`
	_, err := r.db.ExecContext(ctx, query, id, reason, expiresAt, operatorID)
	return err
}

// Unban 解封用户
func (r *UserRepository) Unban(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE user_bans SET is_active = false, updated_at = $2 WHERE user_id = $1 AND is_active = true`
	_, err := r.db.ExecContext(ctx, query, id, time.Now())
	return err
}
