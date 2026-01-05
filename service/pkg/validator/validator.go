// Package validator 提供统一的参数验证封装
// Deprecated: 请使用 github.com/funcdfs/lesser/pkg/validate 包
package validator

import (
	"regexp"

	"github.com/funcdfs/lesser/pkg/validate"
)

// ---- 类型别名（向后兼容）----

// ValidationError 验证错误
// Deprecated: 请使用 validate.Error
type ValidationError = validate.Error

// Validator 验证器
// Deprecated: 请使用 validate.Validator
type Validator = validate.Validator

// New 创建新的验证器
// Deprecated: 请使用 validate.New
var New = validate.New

// ---- 便捷函数别名 ----

// ValidateRequired 快速验证必填字段
// Deprecated: 请使用 validate.Required
var ValidateRequired = validate.Required

// ValidateEmail 快速验证邮箱
// Deprecated: 请使用 validate.Email
var ValidateEmail = validate.Email

// ValidateUUID 快速验证 UUID
// Deprecated: 请使用 validate.UUID
var ValidateUUID = validate.UUID

// ValidateUsername 快速验证用户名
// Deprecated: 请使用 validate.Username
var ValidateUsername = validate.Username

// ValidatePassword 快速验证密码
// Deprecated: 请使用 validate.Password
var ValidatePassword = validate.Password

// ValidatePagination 验证分页参数
// Deprecated: 请使用 validate.Pagination
var ValidatePagination = validate.Pagination

// ---- 保留原有正则表达式供外部使用 ----

var (
	// UsernameRegex 用户名：3-20 字符，字母数字下划线
	UsernameRegex = regexp.MustCompile(`^[a-zA-Z0-9_]{3,20}$`)
	// UUIDRegex UUID 格式
	UUIDRegex = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)
	// PhoneRegex 手机号（中国大陆）
	PhoneRegex = regexp.MustCompile(`^1[3-9]\d{9}$`)
	// URLRegex URL 格式
	URLRegex = regexp.MustCompile(`^https?://[^\s/$.?#].[^\s]*$`)
)
