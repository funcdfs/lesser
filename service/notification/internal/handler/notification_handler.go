// Package handler 提供通知服务的 gRPC 处理器
package handler

import (
	"context"

	"github.com/funcdfs/lesser/notification/internal/repository"
	"github.com/funcdfs/lesser/notification/internal/service"
	"github.com/funcdfs/lesser/pkg/proto/common"
	pb "github.com/funcdfs/lesser/notification/proto/notification"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// NotificationHandler 通知服务 gRPC 处理器
type NotificationHandler struct {
	pb.UnimplementedNotificationServiceServer
	notifService *service.NotificationService
}

// NewNotificationHandler 创建通知处理器实例
func NewNotificationHandler(notifService *service.NotificationService) *NotificationHandler {
	return &NotificationHandler{notifService: notifService}
}

// List 获取通知列表
func (h *NotificationHandler) List(ctx context.Context, req *pb.ListNotificationsRequest) (*pb.ListNotificationsResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	page, pageSize := int32(1), int32(20)
	if req.Pagination != nil {
		if req.Pagination.Page > 0 {
			page = req.Pagination.Page
		}
		if req.Pagination.PageSize > 0 {
			pageSize = req.Pagination.PageSize
		}
	}
	limit := int(pageSize)
	offset := int((page - 1) * pageSize)

	notifications, total, err := h.notifService.List(ctx, req.UserId, req.UnreadOnly, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &pb.ListNotificationsResponse{
		Notifications: notificationsToProto(notifications),
		Pagination:    &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// Read 标记单条通知为已读
func (h *NotificationHandler) Read(ctx context.Context, req *pb.ReadNotificationRequest) (*common.Empty, error) {
	if req.NotificationId == "" {
		return nil, status.Error(codes.InvalidArgument, "notification_id 不能为空")
	}
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	if err := h.notifService.MarkAsRead(ctx, req.NotificationId, req.UserId); err != nil {
		if err == repository.ErrNotificationNotFound {
			return nil, status.Error(codes.NotFound, "通知不存在")
		}
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

// ReadAll 标记所有通知为已读
func (h *NotificationHandler) ReadAll(ctx context.Context, req *pb.ReadAllNotificationsRequest) (*common.Empty, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	_, err := h.notifService.MarkAllAsRead(ctx, req.UserId)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

// GetUnreadCount 获取未读通知数量
func (h *NotificationHandler) GetUnreadCount(ctx context.Context, req *pb.GetUnreadCountRequest) (*pb.UnreadCountResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	count, err := h.notifService.GetUnreadCount(ctx, req.UserId)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.UnreadCountResponse{Count: int32(count)}, nil
}

// notificationsToProto 将通知实体转换为 Proto 消息
func notificationsToProto(notifications []*repository.Notification) []*pb.Notification {
	result := make([]*pb.Notification, len(notifications))
	for i, n := range notifications {
		result[i] = &pb.Notification{
			Id:         n.ID,
			UserId:     n.UserID,
			Type:       pb.NotificationType(n.Type),
			ActorId:    n.ActorID,
			TargetType: n.TargetType,
			TargetId:   n.TargetID,
			Message:    n.Message,
			IsRead:     n.IsRead,
			CreatedAt:  &common.Timestamp{Seconds: n.CreatedAt.Unix()},
		}
	}
	return result
}
