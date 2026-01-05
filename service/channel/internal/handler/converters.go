// Package handler 类型转换工具
package handler

import (
	"time"

	pb "github.com/funcdfs/lesser/channel/gen_protos/channel"
	"github.com/funcdfs/lesser/channel/internal/data_access"
	"github.com/funcdfs/lesser/channel/internal/logic"
	common "github.com/funcdfs/lesser/pkg/gen_protos/common"
)

// channelToProto 将 Channel 实体转换为 proto 消息
func channelToProto(channel *data_access.Channel, isSubscribed, isAdmin, isOwner bool, pinnedPost *data_access.ChannelPost) *pb.Channel {
	if channel == nil {
		return nil
	}

	result := &pb.Channel{
		Id:              channel.ID,
		Name:            channel.Name,
		Description:     channel.Description,
		AvatarUrl:       channel.AvatarURL,
		OwnerId:         channel.OwnerID,
		SubscriberCount: channel.SubscriberCount,
		PostCount:       channel.PostCount,
		CreatedAt:       timestampToProto(channel.CreatedAt),
		UpdatedAt:       timestampToProto(channel.UpdatedAt),
		IsSubscribed:    isSubscribed,
		IsAdmin:         isAdmin,
		IsOwner:         isOwner,
	}

	if pinnedPost != nil {
		result.PinnedPost = postToProto(pinnedPost)
	}

	return result
}

// channelInfoToProto 将 ChannelInfo 转换为 proto 消息
func channelInfoToProto(info *logic.ChannelInfo) *pb.Channel {
	if info == nil {
		return nil
	}

	var pinnedPost *data_access.ChannelPost
	if info.PinnedPost != nil {
		pinnedPost = info.PinnedPost
	}

	return channelToProto(info.Channel, info.IsSubscribed, info.IsAdmin, info.IsOwner, pinnedPost)
}

// channelInfosToProto 将 ChannelInfo 列表转换为 proto 消息列表
func channelInfosToProto(infos []*logic.ChannelInfo) []*pb.Channel {
	if infos == nil {
		return nil
	}

	result := make([]*pb.Channel, 0, len(infos))
	for _, info := range infos {
		result = append(result, channelInfoToProto(info))
	}
	return result
}

// postToProto 将 ChannelPost 实体转换为 proto 消息
func postToProto(post *data_access.ChannelPost) *pb.ChannelPost {
	if post == nil {
		return nil
	}

	return &pb.ChannelPost{
		Id:        post.ID,
		ChannelId: post.ChannelID,
		AuthorId:  post.AuthorID,
		Content:   post.Content,
		MediaUrls: post.MediaURLs,
		ViewCount: post.ViewCount,
		CreatedAt: timestampToProto(post.CreatedAt),
	}
}

// postsToProto 将 ChannelPost 列表转换为 proto 消息列表
func postsToProto(posts []*data_access.ChannelPost) []*pb.ChannelPost {
	if posts == nil {
		return nil
	}

	result := make([]*pb.ChannelPost, 0, len(posts))
	for _, post := range posts {
		result = append(result, postToProto(post))
	}
	return result
}

// subscriberToProto 将 SubscriberInfo 转换为 proto 消息
func subscriberToProto(subscriber *logic.SubscriberInfo) *pb.Subscriber {
	if subscriber == nil {
		return nil
	}

	return &pb.Subscriber{
		UserId: subscriber.UserID,
	}
}

// subscribersToProto 将 SubscriberInfo 列表转换为 proto 消息列表
func subscribersToProto(subscribers []*logic.SubscriberInfo) []*pb.Subscriber {
	if subscribers == nil {
		return nil
	}

	result := make([]*pb.Subscriber, 0, len(subscribers))
	for _, subscriber := range subscribers {
		result = append(result, subscriberToProto(subscriber))
	}
	return result
}

// adminToProto 将 AdminInfo 转换为 proto 消息
func adminToProto(admin *logic.AdminInfo) *pb.Admin {
	if admin == nil {
		return nil
	}

	return &pb.Admin{
		UserId:  admin.UserID,
		IsOwner: admin.IsOwner,
	}
}

// adminsToProto 将 AdminInfo 列表转换为 proto 消息列表
func adminsToProto(admins []*logic.AdminInfo) []*pb.Admin {
	if admins == nil {
		return nil
	}

	result := make([]*pb.Admin, 0, len(admins))
	for _, admin := range admins {
		result = append(result, adminToProto(admin))
	}
	return result
}

// timestampToProto 将 time.Time 转换为 proto Timestamp
func timestampToProto(t time.Time) *common.Timestamp {
	if t.IsZero() {
		return nil
	}
	return &common.Timestamp{
		Seconds: t.Unix(),
		Nanos:   int32(t.Nanosecond()),
	}
}

// getPagination 获取分页参数，返回 limit 和 offset
func getPagination(pagination *common.Pagination) (limit, offset int) {
	limit = 20
	offset = 0

	if pagination != nil {
		if pagination.PageSize > 0 && pagination.PageSize <= 100 {
			limit = int(pagination.PageSize)
		}
		if pagination.Page > 0 {
			offset = (int(pagination.Page) - 1) * limit
		}
	}

	return limit, offset
}

// buildPaginationResponse 构建分页响应
func buildPaginationResponse(page, pageSize, total int) *common.Pagination {
	return &common.Pagination{
		Page:     int32(page),
		PageSize: int32(pageSize),
		Total:    int32(total),
	}
}

// calculatePage 根据 offset 和 limit 计算页码
func calculatePage(offset, limit int) int {
	if limit <= 0 {
		return 1
	}
	return (offset / limit) + 1
}
