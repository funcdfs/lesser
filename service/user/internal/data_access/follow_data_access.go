// Package data_access 提供用户服务的数据访问层
package data_access

import (
	"context"
	"database/sql"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/google/uuid"
)

// FollowDataAccess 关注关系数据访问
type FollowDataAccess struct {
	db *sql.DB
}

// NewFollowDataAccess 创建关注数据访问实例
func NewFollowDataAccess(db *sql.DB) *FollowDataAccess {
	return &FollowDataAccess{db: db}
}

// ============================================================================
// 关注操作
// ============================================================================

// Create 创建关注关系
func (r *FollowDataAccess) Create(ctx context.Context, followerID, followingID string) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO follows (id, follower_id, following_id, created_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (follower_id, following_id) DO NOTHING
	`, uuid.New().String(), followerID, followingID, time.Now())
	return err
}

// Delete 删除关注关系
func (r *FollowDataAccess) Delete(ctx context.Context, followerID, followingID string) error {
	_, err := r.db.ExecContext(ctx, `
		DELETE FROM follows WHERE follower_id = $1 AND following_id = $2
	`, followerID, followingID)
	return err
}

// Exists 检查关注关系是否存在
func (r *FollowDataAccess) Exists(ctx context.Context, followerID, followingID string) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM follows WHERE follower_id = $1 AND following_id = $2)
	`, followerID, followingID).Scan(&exists)
	return exists, err
}

// IsMutual 检查是否互相关注
func (r *FollowDataAccess) IsMutual(ctx context.Context, userID1, userID2 string) (bool, error) {
	var count int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM follows 
		WHERE (follower_id = $1 AND following_id = $2)
		   OR (follower_id = $2 AND following_id = $1)
	`, userID1, userID2).Scan(&count)
	return count == 2, err
}

// ============================================================================
// 列表查询
// ============================================================================

// GetFollowers 获取粉丝列表
func (r *FollowDataAccess) GetFollowers(ctx context.Context, userID string, limit, offset int) ([]*User, int, error) {
	var total int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM follows WHERE following_id = $1
	`, userID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.QueryContext(ctx, `
		SELECT u.id, u.username, u.email, u.display_name, u.avatar_url, u.bio,
		       u.location, u.website, u.birthday, u.is_verified, u.is_private, u.is_active,
		       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at
		FROM users u
		JOIN follows f ON u.id = f.follower_id
		WHERE f.following_id = $1 AND u.is_active = true
		ORDER BY f.created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanUsers(rows), total, nil
}

// GetFollowing 获取关注列表
func (r *FollowDataAccess) GetFollowing(ctx context.Context, userID string, limit, offset int) ([]*User, int, error) {
	var total int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM follows WHERE follower_id = $1
	`, userID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.QueryContext(ctx, `
		SELECT u.id, u.username, u.email, u.display_name, u.avatar_url, u.bio,
		       u.location, u.website, u.birthday, u.is_verified, u.is_private, u.is_active,
		       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at
		FROM users u
		JOIN follows f ON u.id = f.following_id
		WHERE f.follower_id = $1 AND u.is_active = true
		ORDER BY f.created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanUsers(rows), total, nil
}

// GetMutualFollowers 获取共同关注的用户
func (r *FollowDataAccess) GetMutualFollowers(ctx context.Context, userID, targetID string, limit, offset int) ([]*User, int, error) {
	var total int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM follows f1
		JOIN follows f2 ON f1.following_id = f2.following_id
		WHERE f1.follower_id = $1 AND f2.follower_id = $2
	`, userID, targetID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.QueryContext(ctx, `
		SELECT u.id, u.username, u.email, u.display_name, u.avatar_url, u.bio,
		       u.location, u.website, u.birthday, u.is_verified, u.is_private, u.is_active,
		       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at
		FROM users u
		JOIN follows f1 ON u.id = f1.following_id
		JOIN follows f2 ON u.id = f2.following_id
		WHERE f1.follower_id = $1 AND f2.follower_id = $2 AND u.is_active = true
		ORDER BY u.followers_count DESC
		LIMIT $3 OFFSET $4
	`, userID, targetID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanUsers(rows), total, nil
}

// GetFollowerIDs 获取粉丝 ID 列表
func (r *FollowDataAccess) GetFollowerIDs(ctx context.Context, userID string, limit, offset int) ([]string, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT follower_id FROM follows 
		WHERE following_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			continue
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

// GetFollowingIDs 获取关注 ID 列表
func (r *FollowDataAccess) GetFollowingIDs(ctx context.Context, userID string, limit, offset int) ([]string, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT following_id FROM follows 
		WHERE follower_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			continue
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}


// ============================================================================
// 关注请求（私密账户）
// ============================================================================

// CreateFollowRequest 创建关注请求
func (r *FollowDataAccess) CreateFollowRequest(ctx context.Context, requesterID, targetID string) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO follow_requests (id, requester_id, target_id, status, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $5)
		ON CONFLICT (requester_id, target_id) DO UPDATE SET status = $4, updated_at = $5
	`, uuid.New().String(), requesterID, targetID, FollowRequestPending, time.Now())
	return err
}

// GetFollowRequest 获取关注请求
func (r *FollowDataAccess) GetFollowRequest(ctx context.Context, requesterID, targetID string) (*FollowRequest, error) {
	req := &FollowRequest{}
	err := r.db.QueryRowContext(ctx, `
		SELECT id, requester_id, target_id, status, created_at, updated_at
		FROM follow_requests
		WHERE requester_id = $1 AND target_id = $2
	`, requesterID, targetID).Scan(
		&req.ID, &req.RequesterID, &req.TargetID, &req.Status, &req.CreatedAt, &req.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return req, err
}

// UpdateFollowRequestStatus 更新关注请求状态
func (r *FollowDataAccess) UpdateFollowRequestStatus(ctx context.Context, requesterID, targetID string, status FollowRequestStatus) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE follow_requests SET status = $1, updated_at = $2
		WHERE requester_id = $3 AND target_id = $4
	`, status, time.Now(), requesterID, targetID)
	return err
}

// DeleteFollowRequest 删除关注请求
func (r *FollowDataAccess) DeleteFollowRequest(ctx context.Context, requesterID, targetID string) error {
	_, err := r.db.ExecContext(ctx, `
		DELETE FROM follow_requests WHERE requester_id = $1 AND target_id = $2
	`, requesterID, targetID)
	return err
}

// GetPendingFollowRequests 获取待处理的关注请求
func (r *FollowDataAccess) GetPendingFollowRequests(ctx context.Context, targetID string, limit, offset int) ([]*User, int, error) {
	var total int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM follow_requests WHERE target_id = $1 AND status = $2
	`, targetID, FollowRequestPending).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.QueryContext(ctx, `
		SELECT u.id, u.username, u.email, u.display_name, u.avatar_url, u.bio,
		       u.location, u.website, u.birthday, u.is_verified, u.is_private, u.is_active,
		       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at
		FROM users u
		JOIN follow_requests fr ON u.id = fr.requester_id
		WHERE fr.target_id = $1 AND fr.status = $2 AND u.is_active = true
		ORDER BY fr.created_at DESC
		LIMIT $3 OFFSET $4
	`, targetID, FollowRequestPending, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanUsers(rows), total, nil
}

// ============================================================================
// 辅助方法
// ============================================================================

// scanUsers 扫描用户列表
func scanUsers(rows *sql.Rows) []*User {
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
