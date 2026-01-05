// Package page 提供统一的分页处理
// 支持偏移分页和游标分页
package page

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"time"
)

// 默认分页参数
const (
	DefaultPage     = 1
	DefaultPageSize = 20
	MaxPageSize     = 100
)

// Request 分页请求参数
type Request struct {
	Page     int32 `json:"page"`
	PageSize int32 `json:"page_size"`
}

// Response 分页响应
type Response struct {
	Page       int32 `json:"page"`
	PageSize   int32 `json:"page_size"`
	Total      int64 `json:"total"`
	TotalPages int32 `json:"total_pages"`
	HasMore    bool  `json:"has_more"`
}

// Normalize 规范化分页参数
func (p *Request) Normalize() {
	if p.Page <= 0 {
		p.Page = DefaultPage
	}
	if p.PageSize <= 0 {
		p.PageSize = DefaultPageSize
	}
	if p.PageSize > MaxPageSize {
		p.PageSize = MaxPageSize
	}
}

// Offset 计算偏移量
func (p *Request) Offset() int32 {
	return (p.Page - 1) * p.PageSize
}

// Limit 返回限制数量
func (p *Request) Limit() int32 {
	return p.PageSize
}

// NewRequest 创建分页请求
func NewRequest(page, pageSize int32) *Request {
	req := &Request{
		Page:     page,
		PageSize: pageSize,
	}
	req.Normalize()
	return req
}

// NewResponse 创建分页响应
func NewResponse(page, pageSize int32, total int64) *Response {
	totalPages := int32(total / int64(pageSize))
	if total%int64(pageSize) > 0 {
		totalPages++
	}

	return &Response{
		Page:       page,
		PageSize:   pageSize,
		Total:      total,
		TotalPages: totalPages,
		HasMore:    page < totalPages,
	}
}

// ---- 游标分页 ----

// CursorRequest 游标分页请求
type CursorRequest struct {
	Cursor string `json:"cursor"`
	Limit  int32  `json:"limit"`
}

// CursorResponse 游标分页响应
type CursorResponse struct {
	NextCursor string `json:"next_cursor,omitempty"`
	HasMore    bool   `json:"has_more"`
}

// Cursor 游标数据
type Cursor struct {
	ID        string    `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	Score     float64   `json:"score,omitempty"`
}

// Normalize 规范化游标分页参数
func (c *CursorRequest) Normalize() {
	if c.Limit <= 0 {
		c.Limit = DefaultPageSize
	}
	if c.Limit > MaxPageSize {
		c.Limit = MaxPageSize
	}
}

// GetLimit 返回限制数量
func (c *CursorRequest) GetLimit() int32 {
	return c.Limit
}

// NewCursorRequest 创建游标分页请求
func NewCursorRequest(cursor string, limit int32) *CursorRequest {
	req := &CursorRequest{
		Cursor: cursor,
		Limit:  limit,
	}
	req.Normalize()
	return req
}

// EncodeCursor 编码游标
func EncodeCursor(cursor *Cursor) (string, error) {
	data, err := json.Marshal(cursor)
	if err != nil {
		return "", fmt.Errorf("编码游标失败: %w", err)
	}
	return base64.URLEncoding.EncodeToString(data), nil
}

// DecodeCursor 解码游标
func DecodeCursor(encoded string) (*Cursor, error) {
	if encoded == "" {
		return nil, nil
	}

	data, err := base64.URLEncoding.DecodeString(encoded)
	if err != nil {
		return nil, fmt.Errorf("解码游标失败: %w", err)
	}

	var cursor Cursor
	if err := json.Unmarshal(data, &cursor); err != nil {
		return nil, fmt.Errorf("解析游标失败: %w", err)
	}

	return &cursor, nil
}

// EncodeIDCursor 编码简单 ID 游标
func EncodeIDCursor(id string, createdAt time.Time) string {
	cursor := &Cursor{
		ID:        id,
		CreatedAt: createdAt,
	}
	encoded, _ := EncodeCursor(cursor)
	return encoded
}

// DecodeIDCursor 解码简单 ID 游标
func DecodeIDCursor(encoded string) (id string, createdAt time.Time, err error) {
	cursor, err := DecodeCursor(encoded)
	if err != nil {
		return "", time.Time{}, err
	}
	if cursor == nil {
		return "", time.Time{}, nil
	}
	return cursor.ID, cursor.CreatedAt, nil
}

// NewCursorResponse 创建游标分页响应
func NewCursorResponse(nextCursor string, hasMore bool) *CursorResponse {
	return &CursorResponse{
		NextCursor: nextCursor,
		HasMore:    hasMore,
	}
}

// ---- Proto 分页转换 ----

// Pagination proto 分页接口（避免直接依赖 proto 包）
type Pagination interface {
	GetPage() int32
	GetPageSize() int32
}

// FromProto 从 proto 分页参数创建 Request
// 如果 pagination 为 nil，返回默认分页参数
func FromProto(pagination Pagination) *Request {
	if pagination == nil {
		return NewRequest(DefaultPage, DefaultPageSize)
	}
	return NewRequest(pagination.GetPage(), pagination.GetPageSize())
}

// ---- SQL 辅助 ----

// SQLPagination SQL 分页参数
type SQLPagination struct {
	Offset int32
	Limit  int32
}

// ToSQL 转换为 SQL 分页参数
func (p *Request) ToSQL() SQLPagination {
	return SQLPagination{
		Offset: p.Offset(),
		Limit:  p.Limit(),
	}
}

// BuildLimitOffset 构建 LIMIT OFFSET 子句
func BuildLimitOffset(page, pageSize int32) (limit, offset int32) {
	req := NewRequest(page, pageSize)
	return req.Limit(), req.Offset()
}
