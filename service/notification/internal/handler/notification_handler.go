package handler

import (
	"context"

	"github.com/lesser/notification/internal/repository"
	"github.com/lesser/notification/internal/service"
	"github.com/lesser/notification/proto/common"
	pb "github.com/lesser/notification/proto/notification"
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
	limit, offset := 20, 0
	if req.Pagination != nil {
		limit = int(req.Pagination.Limit)
		offset = int(req.Pagination.Offset)
	}
	notifications, total, err := h.notifService.List(req.UserId, limit, offset)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.ListNotificationsResponse{
		Notifications: notificationsToProto(notifications),
		Pagination:    &common.Pagination{Limit: int32(limit), Offset: int32(offset), Total: int32(total)},
	}, nil
}

func (h *NotificationHandler) MarkAsRead(ctx context.Context, req *pb.MarkAsReadRequest) (*common.Empty, error) {
	if req.NotificationId == "" {
		return nil, status.Error(codes.InvalidArgument, "notification_id is required")
	}
	if err := h.notifService.MarkAsRead(req.NotificationId); err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &common.Empty{}, nil
}

func (h *NotificationHandler) MarkAllAsRead(ctx context.Context, req *pb.MarkAllAsReadRequest) (*pb.MarkAllAsReadResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}
	count, err := h.notifService.MarkAllAsRead(req.UserId)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.MarkAllAsReadResponse{MarkedCount: int32(count)}, nil
}

func (h *NotificationHandler) GetUnreadCount(ctx context.Context, req *pb.GetUnreadCountRequest) (*pb.GetUnreadCountResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}
	count, err := h.notifService.GetUnreadCount(req.UserId)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.GetUnreadCountResponse{Count: int32(count)}, nil
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
			Content:   n.Content,
			IsRead:    n.IsRead,
			CreatedAt: &common.Timestamp{Seconds: n.CreatedAt.Unix()},
		}
	}
	return result
}
