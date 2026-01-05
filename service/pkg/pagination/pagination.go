// Package pagination 提供统一的分页处理
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/page 包
package pagination

import (
	"time"

	"github.com/funcdfs/lesser/pkg/page"
)

// 默认分页参数
const (
	DefaultPage     = page.DefaultPage
	DefaultPageSize = page.DefaultPageSize
	MaxPageSize     = page.MaxPageSize
)

// ---- 类型别名（向后兼容）----

// PageRequest 分页请求参数
// Deprecated: 请使用 page.Request
type PageRequest = page.Request

// PageResponse 分页响应
// Deprecated: 请使用 page.Response
type PageResponse = page.Response

// CursorRequest 游标分页请求
// Deprecated: 请使用 page.CursorRequest
type CursorRequest = page.CursorRequest

// CursorResponse 游标分页响应
// Deprecated: 请使用 page.CursorResponse
type CursorResponse = page.CursorResponse

// Cursor 游标数据
// Deprecated: 请使用 page.Cursor
type Cursor = page.Cursor

// SQLPagination SQL 分页参数
// Deprecated: 请使用 page.SQLPagination
type SQLPagination = page.SQLPagination

// ---- 函数别名 ----

// NewPageRequest 创建分页请求
// Deprecated: 请使用 page.NewRequest
var NewPageRequest = page.NewRequest

// NewPageResponse 创建分页响应
// Deprecated: 请使用 page.NewResponse
var NewPageResponse = page.NewResponse

// NewCursorRequest 创建游标分页请求
// Deprecated: 请使用 page.NewCursorRequest
var NewCursorRequest = page.NewCursorRequest

// NewCursorResponse 创建游标分页响应
// Deprecated: 请使用 page.NewCursorResponse
var NewCursorResponse = page.NewCursorResponse

// EncodeCursor 编码游标
// Deprecated: 请使用 page.EncodeCursor
var EncodeCursor = page.EncodeCursor

// DecodeCursor 解码游标
// Deprecated: 请使用 page.DecodeCursor
var DecodeCursor = page.DecodeCursor

// EncodeIDCursor 编码简单 ID 游标
// Deprecated: 请使用 page.EncodeIDCursor
func EncodeIDCursor(id string, createdAt time.Time) string {
	return page.EncodeIDCursor(id, createdAt)
}

// DecodeIDCursor 解码简单 ID 游标
// Deprecated: 请使用 page.DecodeIDCursor
func DecodeIDCursor(encoded string) (id string, createdAt time.Time, err error) {
	return page.DecodeIDCursor(encoded)
}

// BuildLimitOffset 构建 LIMIT OFFSET 子句
// Deprecated: 请使用 page.BuildLimitOffset
var BuildLimitOffset = page.BuildLimitOffset
