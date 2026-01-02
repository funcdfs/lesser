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

type NotificationHandler struct {
	pb.UnimplementedNotificationServiceServer
	notifService *service.NotificationService
}

func NewNotificationHandler(notifService *service.NotificationService) *NotificationHandler {
	return &NotificationHandler{notifService: notifService}
}

func (h *NotificationHandler) List(ctx context.Context, req *pb.ListNotificationsRequest) (*pb.ListNotificationsResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
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

	notifications, total, err := h.notifService.List(req.UserId, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.ListNotificationsResponse{
		Notifications: notificationsToProto(notifications),
		Pagination:    &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

func (h *NotificationHandler) Read(ctx context.Context, req *pb.ReadNotificationRequest) (*common.Empty, error) {
	if req.NotificationId == "" {
		return nil, status.Error(codes.InvalidArgument, "notification_id is required")
	}
	if err := h.notifService.MarkAsRead(req.NotificationId); err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

func (h *NotificationHandler) ReadAll(ctx context.Context, req *pb.ReadAllNotificationsRequest) (*common.Empty, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}
	_, err := h.notifService.MarkAllAsRead(req.UserId)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

func (h *NotificationHandler) GetUnreadCount(ctx context.Context, req *pb.GetUnreadCountRequest) (*pb.UnreadCountResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}
	count, err := h.notifService.GetUnreadCount(req.UserId)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.UnreadCountResponse{Count: int32(count)}, nil
}

func notificationsToProto(notifications []*repository.Notification) []*pb.Notification {
	result := make([]*pb.Notification, len(notifications))
	for i, n := range notifications {
		result[i] = &pb.Notification{
			Id:        n.ID,
			UserId:    n.UserID,
			Type:      pb.NotificationType(n.Type),
			ActorId:   n.ActorID,
			TargetId:  n.TargetID,
			Message:   n.Content,
			IsRead:    n.IsRead,
			CreatedAt: &common.Timestamp{Seconds: n.CreatedAt.Unix()},
		}
	}
	return result
}
