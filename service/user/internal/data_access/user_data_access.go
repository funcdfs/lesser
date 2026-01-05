// Package data_access 提供用户服务的数据访问层
package data_access

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/google/uuid"
	"github.com/lib/pq"
)

// UserDataAccess 用户数据访问
type UserDataAccess struct {
	db *sql.DB
}

// NewUserDataAccess 创建用户数据访问实例
func NewUserDataAccess(db *sql.DB) *UserDataAccess {
	return &UserDataAccess{db: db}
}

// ============================================================================
// 查询方法
// ============================================================================

// GetByID 根据 ID 获取用户
func (r *UserDataAccess) GetByID(ctx context.Context, id string) (*User, error) {
	user := &User{}
	var displayName, avatarURL, bio, location, website sql.NullString
	var birthday sql.NullTime

	err := r.db.QueryRowContext(ctx, `
		SELECT id, username, email, display_name, avatar_url, bio, 
		       location, website, birthday, is_verified, is_private, is_active,
		       followers_count, following_count, posts_count, created_at, updated_at
		FROM users WHERE id = $1 AND is_active = true
	`, id).Scan(
		&user.ID, &user.Username, &user.Email, &displayName, &avatarURL, &bio,
		&location, &website, &birthday, &user.IsVerified, &user.IsPrivate, &user.IsActive,
		&user.FollowersCount, &user.FollowingCount, &user.PostsCount,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, ErrUserNotFound
	}
	if err != nil {
		return nil, err
	}

	user.DisplayName = db.StringFromNull(displayName)
	user.AvatarURL = db.StringFromNull(avatarURL)
	user.Bio = db.StringFromNull(bio)
	user.Location = db.StringFromNull(location)
	user.Website = db.StringFromNull(website)
	user.Birthday = birthday
	return user, nil
}

// GetByUsername 根据用户名获取用户
func (r *UserDataAccess) GetByUsername(ctx context.Context, username string) (*User, error) {
	user := &User{}
	var displayName, avatarURL, bio, location, website sql.NullString
	var birthday sql.NullTime

	err := r.db.QueryRowContext(ctx, `
		SELECT id, username, email, display_name, avatar_url, bio,
		       location, website, birthday, is_verified, is_private, is_active,
		       followers_count, following_count, posts_count, created_at, updated_at
		FROM users WHERE LOWER(username) = LOWER($1) AND is_active = true
	`, username).Scan(
		&user.ID, &user.Username, &user.Email, &displayName, &avatarURL, &bio,
		&location, &website, &birthday, &user.IsVerified, &user.IsPrivate, &user.IsActive,
		&user.FollowersCount, &user.FollowingCount, &user.PostsCount,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, ErrUsernameNotFound
	}
	if err != nil {
		return nil, err
	}

	user.DisplayName = db.StringFromNull(displayName)
	user.AvatarURL = db.StringFromNull(avatarURL)
	user.Bio = db.StringFromNull(bio)
	user.Location = db.StringFromNull(location)
	user.Website = db.StringFromNull(website)
	user.Birthday = birthday
	return user, nil
}

// BatchGetByIDs 批量获取用户
func (r *UserDataAccess) BatchGetByIDs(ctx context.Context, ids []string) (map[string]*User, error) {
	if len(ids) == 0 {
		return make(map[string]*User), nil
	}

	query := `
		SELECT id, username, email, display_name, avatar_url, bio,
		       location, website, birthday, is_verified, is_private, is_active,
		       followers_count, following_count, posts_count, created_at, updated_at
		FROM users WHERE id = ANY($1) AND is_active = true
	`

	rows, err := r.db.QueryContext(ctx, query, pq.Array(ids))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := make(map[string]*User)
	for rows.Next() {
		user := &User{}
		var displayName, avatarURL, bio, location, website sql.NullString
		var birthday sql.NullTime

		if err := rows.Scan(
			&user.ID, &user.Username, &user.Email, &displayName, &avatarURL, &bio,
			&location, &website, &birthday, &user.IsVerified, &user.IsPrivate, &user.IsActive,
			&user.FollowersCount, &user.FollowingCount, &user.PostsCount,
			&user.CreatedAt, &user.UpdatedAt,
		); err != nil {
			return nil, err
		}

		user.DisplayName = db.StringFromNull(displayName)
		user.AvatarURL = db.StringFromNull(avatarURL)
		user.Bio = db.StringFromNull(bio)
		user.Location = db.StringFromNull(location)
		user.Website = db.StringFromNull(website)
		user.Birthday = birthday
		result[user.ID] = user
	}

	return result, rows.Err()
}

// Exists 检查用户是否存在
func (r *UserDataAccess) Exists(ctx context.Context, id string) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM users WHERE id = $1 AND is_active = true)
	`, id).Scan(&exists)
	return exists, err
}

// ============================================================================
// 更新方法
// ============================================================================

// Update 更新用户资料
func (r *UserDataAccess) Update(ctx context.Context, user *User) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET 
			display_name = $1, avatar_url = $2, bio = $3, 
			location = $4, website = $5, birthday = $6, is_private = $7,
			updated_at = $8
		WHERE id = $9
	`, user.DisplayName, user.AvatarURL, user.Bio,
		user.Location, user.Website, user.Birthday, user.IsPrivate,
		time.Now(), user.ID)
	return err
}

// UpdatePartial 部分更新用户资料
func (r *UserDataAccess) UpdatePartial(ctx context.Context, userID string, updates map[string]interface{}) error {
	if len(updates) == 0 {
		return nil
	}

	// 白名单验证允许更新的字段
	allowedFields := map[string]bool{
		"display_name": true,
		"avatar_url":   true,
		"bio":          true,
		"location":     true,
		"website":      true,
		"birthday":     true,
		"is_private":   true,
	}

	// 构建动态 UPDATE 语句
	setClauses := make([]string, 0, len(updates))
	args := make([]interface{}, 0, len(updates)+2)
	argIndex := 1

	for field, value := range updates {
		if !allowedFields[field] {
			continue
		}
		setClauses = append(setClauses, fmt.Sprintf("%s = $%d", field, argIndex))
		args = append(args, value)
		argIndex++
	}

	if len(setClauses) == 0 {
		return nil
	}

	// 添加 updated_at
	setClauses = append(setClauses, fmt.Sprintf("updated_at = $%d", argIndex))
	args = append(args, time.Now())
	argIndex++

	// 添加 WHERE 条件
	args = append(args, userID)

	query := fmt.Sprintf("UPDATE users SET %s WHERE id = $%d", strings.Join(setClauses, ", "), argIndex)
	_, err := r.db.ExecContext(ctx, query, args...)
	return err
}


// ============================================================================
// 计数器方法
// ============================================================================

// IncrementFollowersCount 增加粉丝数
func (r *UserDataAccess) IncrementFollowersCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET followers_count = followers_count + 1, updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// DecrementFollowersCount 减少粉丝数
func (r *UserDataAccess) DecrementFollowersCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET followers_count = GREATEST(followers_count - 1, 0), updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// IncrementFollowingCount 增加关注数
func (r *UserDataAccess) IncrementFollowingCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET following_count = following_count + 1, updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// DecrementFollowingCount 减少关注数
func (r *UserDataAccess) DecrementFollowingCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET following_count = GREATEST(following_count - 1, 0), updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// IncrementPostsCount 增加帖子数
func (r *UserDataAccess) IncrementPostsCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET posts_count = posts_count + 1, updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// DecrementPostsCount 减少帖子数
func (r *UserDataAccess) DecrementPostsCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET posts_count = GREATEST(posts_count - 1, 0), updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// ============================================================================
// 搜索方法
// ============================================================================

// Search 搜索用户（按用户名或昵称）
func (r *UserDataAccess) Search(ctx context.Context, query string, limit, offset int) ([]*User, int, error) {
	searchPattern := "%" + strings.ToLower(query) + "%"

	// 获取总数
	var total int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM users 
		WHERE is_active = true 
		AND (LOWER(username) LIKE $1 OR LOWER(display_name) LIKE $1)
	`, searchPattern).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	// 获取列表
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, username, email, display_name, avatar_url, bio,
		       location, website, birthday, is_verified, is_private, is_active,
		       followers_count, following_count, posts_count, created_at, updated_at
		FROM users 
		WHERE is_active = true 
		AND (LOWER(username) LIKE $1 OR LOWER(display_name) LIKE $1)
		ORDER BY 
			CASE WHEN LOWER(username) = LOWER($2) THEN 0
			     WHEN LOWER(username) LIKE LOWER($2) || '%' THEN 1
			     ELSE 2 END,
			followers_count DESC
		LIMIT $3 OFFSET $4
	`, searchPattern, query, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanUsers(rows), total, nil
}

// ============================================================================
// 辅助方法
// ============================================================================

// generateID 生成 UUID
func generateID() string {
	return uuid.New().String()
}
