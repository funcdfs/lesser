// Package repository 提供用户服务的数据访问层
package data_access

import (
	"context"
	"database/sql"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/google/uuid"
)

// BlockRepository 屏蔽关系数据仓库
type BlockRepository struct {
	db *sql.DB
}

// NewBlockRepository 创建屏蔽仓库实例
func NewBlockRepository(db *sql.DB) *BlockRepository {
	return &BlockRepository{db: db}
}

// ============================================================================
// 屏蔽操作
// ============================================================================

// Create 创建屏蔽关系
func (r *BlockRepository) Create(ctx context.Context, blockerID, blockedID string, blockType BlockType) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO blocks (id, blocker_id, blocked_id, block_type, created_at)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (blocker_id, blocked_id) DO UPDATE SET block_type = $4, created_at = $5
	`, uuid.New().String(), blockerID, blockedID, blockType, time.Now())
	return err
}

// Delete 删除屏蔽关系
func (r *BlockRepository) Delete(ctx context.Context, blockerID, blockedID string) error {
	_, err := r.db.ExecContext(ctx, `
		DELETE FROM blocks WHERE blocker_id = $1 AND blocked_id = $2
	`, blockerID, blockedID)
	return err
}

// UpdateType 更新屏蔽类型
func (r *BlockRepository) UpdateType(ctx context.Context, blockerID, blockedID string, blockType BlockType) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE blocks SET block_type = $1 WHERE blocker_id = $2 AND blocked_id = $3
	`, blockType, blockerID, blockedID)
	return err
}

// ============================================================================
// 查询方法
// ============================================================================

// Get 获取屏蔽关系
func (r *BlockRepository) Get(ctx context.Context, blockerID, blockedID string) (*Block, error) {
	block := &Block{}
	err := r.db.QueryRowContext(ctx, `
		SELECT id, blocker_id, blocked_id, block_type, created_at
		FROM blocks WHERE blocker_id = $1 AND blocked_id = $2
	`, blockerID, blockedID).Scan(
		&block.ID, &block.BlockerID, &block.BlockedID, &block.BlockType, &block.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return block, err
}

// Exists 检查屏蔽关系是否存在
func (r *BlockRepository) Exists(ctx context.Context, blockerID, blockedID string) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM blocks WHERE blocker_id = $1 AND blocked_id = $2)
	`, blockerID, blockedID).Scan(&exists)
	return exists, err
}

// GetBlockType 获取屏蔽类型
func (r *BlockRepository) GetBlockType(ctx context.Context, blockerID, blockedID string) (BlockType, error) {
	var blockType BlockType
	err := r.db.QueryRowContext(ctx, `
		SELECT block_type FROM blocks WHERE blocker_id = $1 AND blocked_id = $2
	`, blockerID, blockedID).Scan(&blockType)
	if err == sql.ErrNoRows {
		return BlockTypeUnspecified, nil
	}
	return blockType, err
}

// IsBlocking 检查是否屏蔽了某用户
func (r *BlockRepository) IsBlocking(ctx context.Context, blockerID, blockedID string) (bool, BlockType, error) {
	var blockType BlockType
	err := r.db.QueryRowContext(ctx, `
		SELECT block_type FROM blocks WHERE blocker_id = $1 AND blocked_id = $2
	`, blockerID, blockedID).Scan(&blockType)
	if err == sql.ErrNoRows {
		return false, BlockTypeUnspecified, nil
	}
	if err != nil {
		return false, BlockTypeUnspecified, err
	}
	return true, blockType, nil
}

// IsBlockedBy 检查是否被某用户屏蔽
func (r *BlockRepository) IsBlockedBy(ctx context.Context, userID, blockerID string) (bool, BlockType, error) {
	return r.IsBlocking(ctx, blockerID, userID)
}

// GetBidirectionalBlockStatus 获取双向屏蔽状态
func (r *BlockRepository) GetBidirectionalBlockStatus(ctx context.Context, userID, targetID string) (myBlockType, theirBlockType BlockType, err error) {
	// 我对他的屏蔽
	myBlockType, err = r.GetBlockType(ctx, userID, targetID)
	if err != nil {
		return
	}

	// 他对我的屏蔽
	theirBlockType, err = r.GetBlockType(ctx, targetID, userID)
	return
}

// ============================================================================
// 列表查询
// ============================================================================

// GetBlockList 获取屏蔽列表
func (r *BlockRepository) GetBlockList(ctx context.Context, userID string, blockType BlockType, limit, offset int) ([]*BlockedUser, int, error) {
	// 获取总数
	var total int
	if blockType == BlockTypeUnspecified {
		err := r.db.QueryRowContext(ctx, 
			"SELECT COUNT(*) FROM blocks WHERE blocker_id = $1", userID).Scan(&total)
		if err != nil {
			return nil, 0, err
		}
	} else {
		err := r.db.QueryRowContext(ctx, 
			"SELECT COUNT(*) FROM blocks WHERE blocker_id = $1 AND block_type = $2", 
			userID, blockType).Scan(&total)
		if err != nil {
			return nil, 0, err
		}
	}

	// 获取列表
	var rows *sql.Rows
	var err error
	if blockType == BlockTypeUnspecified {
		rows, err = r.db.QueryContext(ctx, `
			SELECT u.id, u.username, u.email, u.display_name, u.avatar_url, u.bio,
			       u.location, u.website, u.birthday, u.is_verified, u.is_private, u.is_active,
			       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at,
			       b.block_type, b.created_at as blocked_at
			FROM users u
			JOIN blocks b ON u.id = b.blocked_id
			WHERE b.blocker_id = $1
			ORDER BY b.created_at DESC
			LIMIT $2 OFFSET $3
		`, userID, limit, offset)
	} else {
		rows, err = r.db.QueryContext(ctx, `
			SELECT u.id, u.username, u.email, u.display_name, u.avatar_url, u.bio,
			       u.location, u.website, u.birthday, u.is_verified, u.is_private, u.is_active,
			       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at,
			       b.block_type, b.created_at as blocked_at
			FROM users u
			JOIN blocks b ON u.id = b.blocked_id
			WHERE b.blocker_id = $1 AND b.block_type = $2
			ORDER BY b.created_at DESC
			LIMIT $3 OFFSET $4
		`, userID, blockType, limit, offset)
	}
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var blockedUsers []*BlockedUser
	for rows.Next() {
		user := &User{}
		var displayName, avatarURL, bio, location, website sql.NullString
		var birthday sql.NullTime
		var bt BlockType
		var blockedAt time.Time

		if err := rows.Scan(
			&user.ID, &user.Username, &user.Email, &displayName, &avatarURL, &bio,
			&location, &website, &birthday, &user.IsVerified, &user.IsPrivate, &user.IsActive,
			&user.FollowersCount, &user.FollowingCount, &user.PostsCount,
			&user.CreatedAt, &user.UpdatedAt,
			&bt, &blockedAt,
		); err != nil {
			continue
		}

		user.DisplayName = db.StringFromNull(displayName)
		user.AvatarURL = db.StringFromNull(avatarURL)
		user.Bio = db.StringFromNull(bio)
		user.Location = db.StringFromNull(location)
		user.Website = db.StringFromNull(website)
		user.Birthday = birthday

		blockedUsers = append(blockedUsers, &BlockedUser{
			User:      user,
			BlockType: bt,
			BlockedAt: blockedAt,
		})
	}

	return blockedUsers, total, rows.Err()
}

// GetBlockedUserIDs 获取被屏蔽的用户 ID 列表
func (r *BlockRepository) GetBlockedUserIDs(ctx context.Context, userID string) ([]string, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT blocked_id FROM blocks WHERE blocker_id = $1
	`, userID)
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

// GetBlockerUserIDs 获取屏蔽了我的用户 ID 列表
func (r *BlockRepository) GetBlockerUserIDs(ctx context.Context, userID string) ([]string, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT blocker_id FROM blocks WHERE blocked_id = $1
	`, userID)
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
// 可见性检查
// ============================================================================

// CanViewContent 检查 viewer 是否能看到 target 的内容
// 返回 false 如果：target 拉黑了 viewer，或 target 设置了不让 viewer 看
func (r *BlockRepository) CanViewContent(ctx context.Context, viewerID, targetID string) (bool, error) {
	blockType, err := r.GetBlockType(ctx, targetID, viewerID)
	if err != nil {
		return false, err
	}
	// 如果 target 拉黑了 viewer 或设置了不让 viewer 看
	if blockType == BlockTypeBlock || blockType == BlockTypeHideMe {
		return false, nil
	}
	return true, nil
}

// CanSeeContent 检查 viewer 是否想看 target 的内容
// 返回 false 如果：viewer 设置了不看 target 的内容
func (r *BlockRepository) CanSeeContent(ctx context.Context, viewerID, targetID string) (bool, error) {
	blockType, err := r.GetBlockType(ctx, viewerID, targetID)
	if err != nil {
		return false, err
	}
	// 如果 viewer 设置了不看 target 或拉黑了 target
	if blockType == BlockTypeBlock || blockType == BlockTypeHidePosts {
		return false, nil
	}
	return true, nil
}

// ============================================================================
// 辅助方法
// ============================================================================
