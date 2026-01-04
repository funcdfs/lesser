// Package handler 提供 gRPC 处理器
package handler

import (
	"context"
	"log/slog"

	"github.com/funcdfs/lesser/content/internal/data_access"
	"github.com/funcdfs/lesser/content/internal/logic"
	pb "github.com/funcdfs/lesser/content/gen_protos/content"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ContentHandler gRPC 处理器
type ContentHandler struct {
	pb.UnimplementedContentServiceServer
	contentService *logic.ContentService
	log            *slog.Logger
}

// NewContentHandler 创建处理器
func NewContentHandler(contentService *logic.ContentService, log *slog.Logger) *ContentHandler {
	if log == nil {
		log = slog.Default()
	}
	return &ContentHandler{
		contentService: contentService,
		log:            log.With(slog.String("component", "handler")),
	}
}

// CreateContent 创建内容
func (h *ContentHandler) CreateContent(ctx context.Context, req *pb.CreateContentRequest) (*pb.CreateContentResponse, error) {
	// 参数验证
	if req.AuthorId == "" {
		return nil, status.Error(codes.InvalidArgument, "author_id 不能为空")
	}
	if req.Type == pb.ContentType_CONTENT_TYPE_UNSPECIFIED {
		return nil, status.Error(codes.InvalidArgument, "type 不能为空")
	}

	h.log.Debug("创建内容",
		slog.String("author_id", req.AuthorId),
		slog.String("type", req.Type.String()),
	)

	// 转换媒体 URL
	mediaURLs := extractMediaURLs(req.Media)

	content, err := h.contentService.Create(
		req.AuthorId,
		data_access.ContentType(req.Type),
		req.Title, req.Text, req.Summary,
		mediaURLs, req.Tags,
		req.ReplyToId, req.QuoteId,
		req.IsDraft, req.CommentsDisabled,
	)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.CreateContentResponse{Content: contentToProto(content)}, nil
}

// GetContent 获取内容
func (h *ContentHandler) GetContent(ctx context.Context, req *pb.GetContentRequest) (*pb.GetContentResponse, error) {
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
	}

	content, err := h.contentService.Get(req.ContentId, req.ViewerId)
	if err != nil {
		return nil, mapError(err)
	}

	// TODO: 查询用户的点赞/收藏/转发状态
	return &pb.GetContentResponse{
		Content:      contentToProto(content),
		IsLiked:      false,
		IsBookmarked: false,
		IsReposted:   false,
	}, nil
}

// UpdateContent 更新内容
func (h *ContentHandler) UpdateContent(ctx context.Context, req *pb.UpdateContentRequest) (*pb.UpdateContentResponse, error) {
	if req.ContentId == "" || req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 和 user_id 不能为空")
	}

	h.log.Debug("更新内容",
		slog.String("content_id", req.ContentId),
		slog.String("user_id", req.UserId),
	)

	mediaURLs := extractMediaURLs(req.Media)

	content, err := h.contentService.Update(
		req.ContentId, req.UserId,
		req.Title, req.Text, req.Summary,
		mediaURLs, req.Tags,
		req.CommentsDisabled,
	)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.UpdateContentResponse{Content: contentToProto(content)}, nil
}

// DeleteContent 删除内容
func (h *ContentHandler) DeleteContent(ctx context.Context, req *pb.DeleteContentRequest) (*pb.DeleteContentResponse, error) {
	if req.ContentId == "" || req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 和 user_id 不能为空")
	}

	h.log.Debug("删除内容",
		slog.String("content_id", req.ContentId),
		slog.String("user_id", req.UserId),
	)

	if err := h.contentService.Delete(req.ContentId, req.UserId); err != nil {
		return nil, mapError(err)
	}

	return &pb.DeleteContentResponse{Success: true}, nil
}

// ListContents 列表查询
func (h *ContentHandler) ListContents(ctx context.Context, req *pb.ListContentsRequest) (*pb.ListContentsResponse, error) {
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

	contents, total, err := h.contentService.List(
		req.AuthorId,
		data_access.ContentType(req.Type),
		data_access.ContentStatus(req.Status),
		req.Tags,
		limit, offset,
		req.OrderBy, req.Descending,
	)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.ListContentsResponse{
		Contents:   contentsToProto(contents),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// BatchGetContents 批量获取
func (h *ContentHandler) BatchGetContents(ctx context.Context, req *pb.BatchGetContentsRequest) (*pb.BatchGetContentsResponse, error) {
	if len(req.ContentIds) == 0 {
		return &pb.BatchGetContentsResponse{Contents: []*pb.Content{}}, nil
	}

	contents, err := h.contentService.BatchGet(req.ContentIds)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.BatchGetContentsResponse{Contents: contentsToProto(contents)}, nil
}

// GetUserDrafts 获取用户草稿
func (h *ContentHandler) GetUserDrafts(ctx context.Context, req *pb.GetUserDraftsRequest) (*pb.GetUserDraftsResponse, error) {
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

	drafts, total, err := h.contentService.GetUserDrafts(req.UserId, int(pageSize), int((page-1)*pageSize))
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.GetUserDraftsResponse{
		Drafts:     contentsToProto(drafts),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// PublishDraft 发布草稿
func (h *ContentHandler) PublishDraft(ctx context.Context, req *pb.PublishDraftRequest) (*pb.PublishDraftResponse, error) {
	if req.ContentId == "" || req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 和 user_id 不能为空")
	}

	h.log.Debug("发布草稿",
		slog.String("content_id", req.ContentId),
		slog.String("user_id", req.UserId),
	)

	content, err := h.contentService.PublishDraft(req.ContentId, req.UserId)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.PublishDraftResponse{Content: contentToProto(content)}, nil
}

// GetReplies 获取回复列表
func (h *ContentHandler) GetReplies(ctx context.Context, req *pb.GetRepliesRequest) (*pb.GetRepliesResponse, error) {
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
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

	replies, total, err := h.contentService.GetReplies(req.ContentId, int(pageSize), int((page-1)*pageSize))
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.GetRepliesResponse{
		Replies:    contentsToProto(replies),
		Pagination: &common.Pagination{Page: page, PageSize: pageSize, Total: int32(total)},
	}, nil
}

// GetUserStories 获取用户 Story
func (h *ContentHandler) GetUserStories(ctx context.Context, req *pb.GetUserStoriesRequest) (*pb.GetUserStoriesResponse, error) {
	if req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id 不能为空")
	}

	stories, err := h.contentService.GetUserStories(req.UserId)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.GetUserStoriesResponse{
		Stories:   contentsToProto(stories),
		HasUnseen: false, // TODO: 实现已读状态追踪
	}, nil
}

// PinContent 置顶内容
func (h *ContentHandler) PinContent(ctx context.Context, req *pb.PinContentRequest) (*pb.PinContentResponse, error) {
	if req.ContentId == "" || req.UserId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 和 user_id 不能为空")
	}

	h.log.Debug("置顶内容",
		slog.String("content_id", req.ContentId),
		slog.String("user_id", req.UserId),
		slog.Bool("pin", req.Pin),
	)

	if err := h.contentService.PinContent(req.ContentId, req.UserId, req.Pin); err != nil {
		return nil, mapError(err)
	}

	return &pb.PinContentResponse{Success: true}, nil
}

// ============================================================================
// 内部 API（供 Feed Service 调用）
// ============================================================================

// UpdateCounter 更新统计计数器
func (h *ContentHandler) UpdateCounter(ctx context.Context, req *pb.UpdateCounterRequest) (*pb.UpdateCounterResponse, error) {
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
	}
	if req.CounterType == pb.CounterType_COUNTER_TYPE_UNSPECIFIED {
		return nil, status.Error(codes.InvalidArgument, "counter_type 不能为空")
	}

	h.log.Debug("更新计数器",
		slog.String("content_id", req.ContentId),
		slog.String("counter_type", req.CounterType.String()),
		slog.Int("delta", int(req.Delta)),
	)

	newCount, err := h.contentService.UpdateCounter(
		req.ContentId,
		data_access.CounterType(req.CounterType),
		req.Delta,
	)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.UpdateCounterResponse{NewCount: newCount}, nil
}

// CheckContentExists 检查内容是否存在
func (h *ContentHandler) CheckContentExists(ctx context.Context, req *pb.CheckContentExistsRequest) (*pb.CheckContentExistsResponse, error) {
	if req.ContentId == "" {
		return nil, status.Error(codes.InvalidArgument, "content_id 不能为空")
	}

	exists, commentsDisabled, err := h.contentService.CheckContentExists(req.ContentId)
	if err != nil {
		return nil, mapError(err)
	}

	return &pb.CheckContentExistsResponse{
		Exists:           exists,
		CommentsDisabled: commentsDisabled,
	}, nil
}

// ============================================================================
// 辅助函数
// ============================================================================

func contentToProto(c *data_access.Content) *pb.Content {
	if c == nil {
		return nil
	}

	content := &pb.Content{
		Id:               c.ID,
		AuthorId:         c.AuthorID,
		Type:             pb.ContentType(c.Type),
		Status:           pb.ContentStatus(c.Status),
		Title:            c.Title,
		Text:             c.Text,
		Summary:          c.Summary,
		Tags:             c.Tags,
		ReplyToId:        c.ReplyToID,
		QuoteId:          c.QuoteID,
		LikeCount:        c.LikeCount,
		CommentCount:     c.CommentCount,
		RepostCount:      c.RepostCount,
		BookmarkCount:    c.BookmarkCount,
		ViewCount:        c.ViewCount,
		CreatedAt:        &common.Timestamp{Seconds: c.CreatedAt.Unix()},
		UpdatedAt:        &common.Timestamp{Seconds: c.UpdatedAt.Unix()},
		IsPinned:         c.IsPinned,
		CommentsDisabled: c.CommentsDisabled,
		Language:         c.Language,
	}

	// 转换媒体 URL 为 Media 对象
	for _, url := range c.MediaURLs {
		content.Media = append(content.Media, &pb.Media{Url: url})
	}

	if c.PublishedAt != nil {
		content.PublishedAt = &common.Timestamp{Seconds: c.PublishedAt.Unix()}
	}
	if c.ExpiresAt != nil {
		content.ExpiresAt = &common.Timestamp{Seconds: c.ExpiresAt.Unix()}
	}

	return content
}

func contentsToProto(contents []*data_access.Content) []*pb.Content {
	result := make([]*pb.Content, len(contents))
	for i, c := range contents {
		result[i] = contentToProto(c)
	}
	return result
}

func extractMediaURLs(media []*pb.Media) []string {
	if len(media) == 0 {
		return nil
	}
	urls := make([]string, len(media))
	for i, m := range media {
		urls[i] = m.Url
	}
	return urls
}

func mapError(err error) error {
	switch err {
	case data_access.ErrContentNotFound:
		return status.Error(codes.NotFound, "内容不存在")
	case data_access.ErrUnauthorized, logic.ErrUnauthorized:
		return status.Error(codes.PermissionDenied, "无权限操作")
	case logic.ErrInvalidContent:
		return status.Error(codes.InvalidArgument, "内容无效")
	case logic.ErrContentTooLong:
		return status.Error(codes.InvalidArgument, "内容超出长度限制")
	case logic.ErrTitleRequired:
		return status.Error(codes.InvalidArgument, "标题不能为空")
	case logic.ErrTextRequired:
		return status.Error(codes.InvalidArgument, "正文不能为空")
	case logic.ErrCannotEditStory:
		return status.Error(codes.FailedPrecondition, "Story 不支持编辑")
	case logic.ErrNotDraft:
		return status.Error(codes.FailedPrecondition, "只能发布草稿状态的内容")
	case logic.ErrDraftNotAllowed:
		return status.Error(codes.InvalidArgument, "该内容类型不支持草稿")
	default:
		return status.Error(codes.Internal, err.Error())
	}
}
