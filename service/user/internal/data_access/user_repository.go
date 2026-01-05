// Package repository 提供用户服务的数据访问层
package data_access

import (
	"context"
	"database/sql"
	"strings"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/google/uuid"
	"github.com/lib/pq"
)

// UserRepository 用户数据仓库
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository 创建用户仓库实例
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// ============================================================================
// 查询方法
// ============================================================================

// GetByID 根据 ID 获取用户
func (r *UserRepository) GetByID(ctx context.Context, id string) (*User, error) {
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
func (r *UserRepository) GetByUsername(ctx context.Context, username string) (*User, error) {
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
func (r *UserRepository) BatchGetByIDs(ctx context.Context, ids []string) (map[string]*User, error) {
	if len(ids) == 0 {
		return make(map[string]*User), nil
	}

	query := `
		SELECT id, username, email, display_name, avatar_url, bio,
		       location, website, birthday, is_verified, is_private, is_active,
		       followers_count, following_count, posts_count, created_at, updated_at
		FROM users WHERE id = ANY($1) AND is_active = true
	`

	// 使用 pq.Array 转换 []string 为 PostgreSQL 数组类型
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
func (r *UserRepository) Exists(ctx context.Context, id string) (bool, error) {
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
func (r *UserRepository) Update(ctx context.Context, user *User) error {
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
func (r *UserRepository) UpdatePartial(ctx context.Context, userID string, updates map[string]interface{}) error {
	if len(updates) == 0 {
		return nil
	}

	// 构建动态 UPDATE 语句
	setClauses := make([]string, 0, len(updates))
	args := make([]interface{}, 0, len(updates)+1)
	i := 1

	for field, value := range updates {
		setClauses = append(setClauses, field+" = $"+string(rune('0'+i)))
		args = append(args, value)
		i++
	}

	// 添加 updated_at
	setClauses = append(setClauses, "updated_at = $"+string(rune('0'+i)))
	args = append(args, time.Now())
	i++

	// 添加 WHERE 条件
	args = append(args, userID)

	query := "UPDATE users SET " + strings.Join(setClauses, ", ") + " WHERE id = $" + string(rune('0'+i))
	_, err := r.db.ExecContext(ctx, query, args...)
	return err
}

// ============================================================================
// 计数器方法
// ============================================================================

// IncrementFollowersCount 增加粉丝数
func (r *UserRepository) IncrementFollowersCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET followers_count = followers_count + 1, updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// DecrementFollowersCount 减少粉丝数
func (r *UserRepository) DecrementFollowersCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET followers_count = GREATEST(followers_count - 1, 0), updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// IncrementFollowingCount 增加关注数
func (r *UserRepository) IncrementFollowingCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET following_count = following_count + 1, updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// DecrementFollowingCount 减少关注数
func (r *UserRepository) DecrementFollowingCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET following_count = GREATEST(following_count - 1, 0), updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// IncrementPostsCount 增加帖子数
func (r *UserRepository) IncrementPostsCount(ctx context.Context, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE users SET posts_count = posts_count + 1, updated_at = NOW()
		WHERE id = $1
	`, userID)
	return err
}

// DecrementPostsCount 减少帖子数
func (r *UserRepository) DecrementPostsCount(ctx context.Context, userID string) error {
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
func (r *UserRepository) Search(ctx context.Context, query string, limit, offset int) ([]*User, int, error) {
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

	return r.scanUsers(rows), total, nil
}

// ============================================================================
// 辅助方法
// ============================================================================

// scanUsers 扫描用户列表
func (r *UserRepository) scanUsers(rows *sql.Rows) []*User {
	var users []*User
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
			continue
		}

		user.DisplayName = db.StringFromNull(displayName)
		user.AvatarURL = db.StringFromNull(avatarURL)
		user.Bio = db.StringFromNull(bio)
		user.Location = db.StringFromNull(location)
		user.Website = db.StringFromNull(website)
		user.Birthday = birthday
		users = append(users, user)
	}
	return users
}

// generateID 生成 UUID
func generateID() string {
	return uuid.New().String()
}
