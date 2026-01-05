// Package handler 提供通知服务的 gRPC 处理器
// 负责协议对接、参数验证和响应转换
package handler

import (
	"context"

	pb "github.com/funcdfs/lesser/notification/gen_protos/notification"
	"github.com/funcdfs/lesser/notification/internal/data_access"
	"github.com/funcdfs/lesser/notification/internal/logic"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// NotificationHandler 通知服务 gRPC 处理器
// 实现 NotificationServiceServer 接口
type NotificationHandler struct {
	pb.UnimplementedNotificationServiceServer
	notifService *logic.NotificationService
	log          *log.Logger
}

// NewNotificationHandler 创建通知处理器实例
func NewNotificationHandler(notifService *logic.NotificationService, logger *log.Logger) *NotificationHandler {
	if logger == nil {
		logger = log.Global()
	}
	return &NotificationHandler{
		notifService: notifService,
		log:          logger.With(log.String("component", "handler")),
	}
}

// ============================================================================
// 通知查询
// ============================================================================

// List 获取通知列表
func (h *NotificationHandler) List(ctx context.Context, req *pb.ListNotificationsRequest) (*pb.ListNotificationsResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	// 解析分页参数
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
		h.log.Error("获取通知列表失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}

	return &pb.ListNotificationsResponse{
		Notifications: notificationsToProto(notifications),
		Pagination:    &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// GetUnreadCount 获取未读通知数量
func (h *NotificationHandler) GetUnreadCount(ctx context.Context, req *pb.GetUnreadCountRequest) (*pb.UnreadCountResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	count, err := h.notifService.GetUnreadCount(ctx, req.UserId)
	if err != nil {
		h.log.Error("获取未读通知数量失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}
	return &pb.UnreadCountResponse{Count: int32(count)}, nil
}

// ============================================================================
// 通知状态管理
// ============================================================================

// Read 标记单条通知为已读
func (h *NotificationHandler) Read(ctx context.Context, req *pb.ReadNotificationRequest) (*common.Empty, error) {
	if req.NotificationId == "" {
		return nil, status.Error(codes.InvalidArgument, "notification_id 不能为空")
	}
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	if err := h.notifService.MarkAsRead(ctx, req.NotificationId, req.UserId); err != nil {
		h.log.Error("标记通知已读失败",
			log.String("notification_id", req.NotificationId),
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
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
		h.log.Error("标记所有通知已读失败",
			log.String("user_id", req.UserId),
			log.String("trace_id", log.TraceIDFromContext(ctx)),
			log.Any("error", err),
		)
		return nil, logic.ToGRPCError(err)
	}
	return &common.Empty{}, nil
}

// ============================================================================
// 转换函数
// ============================================================================

// notificationsToProto 将通知实体列表转换为 Proto 消息
func notificationsToProto(notifications []*data_access.Notification) []*pb.Notification {
	if notifications == nil {
		return []*pb.Notification{}
	}
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
