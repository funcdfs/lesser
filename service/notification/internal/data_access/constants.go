// Package data_access 提供通知服务的数据访问层
package data_access

// ============================================================================
// 通知类型常量
// 定义所有支持的通知类型，与 proto 定义保持一致
// ============================================================================

const (
	NotificationTypeLike     int32 = 1 // 点赞通知
	NotificationTypeComment  int32 = 2 // 评论通知
	NotificationTypeReply    int32 = 3 // 回复通知
	NotificationTypeBookmark int32 = 4 // 收藏通知
	NotificationTypeMention  int32 = 5 // @提及通知
	NotificationTypeFollow   int32 = 6 // 关注通知
	NotificationTypeRepost   int32 = 7 // 转发通知
)

// ============================================================================
// 目标类型常量
// 定义通知关联的目标类型
// ============================================================================

const (
	TargetTypeContent = "content" // 内容（帖子）
	TargetTypeComment = "comment" // 评论
	TargetTypeUser    = "user"    // 用户
)

// NotificationTypeNames 通知类型名称映射（用于日志和调试）
var NotificationTypeNames = map[int32]string{
	NotificationTypeLike:     "点赞",
	NotificationTypeComment:  "评论",
	NotificationTypeReply:    "回复",
	NotificationTypeBookmark: "收藏",
	NotificationTypeMention:  "@提及",
	NotificationTypeFollow:   "关注",
	NotificationTypeRepost:   "转发",
}

// GetNotificationTypeName 获取通知类型名称
func GetNotificationTypeName(notifType int32) string {
	if name, ok := NotificationTypeNames[notifType]; ok {
		return name
	}
	return "未知"
}
