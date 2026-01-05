// Package data_access 提供 Interaction 服务的数据访问层
package data_access

// LikeDataAccessInterface 点赞数据访问接口
type LikeDataAccessInterface interface {
	// Create 创建点赞记录，返回是否实际插入了新记录
	Create(userID, contentID string) (bool, error)
	// Delete 删除点赞记录，返回是否实际删除了记录
	Delete(userID, contentID string) (bool, error)
	// Exists 检查是否已点赞
	Exists(userID, contentID string) (bool, error)
	// BatchExists 批量检查是否已点赞
	BatchExists(userID string, contentIDs []string) (map[string]bool, error)
}

// BookmarkDataAccessInterface 收藏数据访问接口
type BookmarkDataAccessInterface interface {
	// Create 创建收藏记录，返回是否实际插入了新记录
	Create(userID, contentID string) (bool, error)
	// Delete 删除收藏记录，返回是否实际删除了记录
	Delete(userID, contentID string) (bool, error)
	// Exists 检查是否已收藏
	Exists(userID, contentID string) (bool, error)
	// BatchExists 批量检查是否已收藏
	BatchExists(userID string, contentIDs []string) (map[string]bool, error)
	// List 获取收藏列表
	List(userID string, limit, offset int) ([]*Bookmark, int, error)
}

// RepostDataAccessInterface 转发数据访问接口
type RepostDataAccessInterface interface {
	// Create 创建转发记录，返回创建的转发记录、是否实际插入了新记录
	Create(userID, contentID, quote string) (*Repost, bool, error)
	// Delete 删除转发记录，返回是否实际删除了记录
	Delete(userID, contentID string) (bool, error)
	// Exists 检查是否已转发
	Exists(userID, contentID string) (bool, error)
	// BatchExists 批量检查是否已转发
	BatchExists(userID string, contentIDs []string) (map[string]bool, error)
	// GetByUserAndContent 根据用户和内容获取转发记录
	GetByUserAndContent(userID, contentID string) (*Repost, error)
}
