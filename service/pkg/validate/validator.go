// Package validate 提供统一的参数验证封装
// 支持常用字段验证、自定义规则、gRPC 错误返回
package validate

import (
	"net/mail"
	"regexp"
	"strings"
	"unicode/utf8"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// 预编译正则表达式
var (
	// 用户名：3-20 字符，字母数字下划线
	usernameRegex = regexp.MustCompile(`^[a-zA-Z0-9_]{3,20}$`)
	// UUID 格式
	uuidRegex = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)
	// 手机号（中国大陆）
	phoneRegex = regexp.MustCompile(`^1[3-9]\d{9}$`)
	// URL 格式
	urlRegex = regexp.MustCompile(`^https?://[^\s/$.?#].[^\s]*$`)
)

// Error 验证错误
type Error struct {
	Field   string
	Message string
}

// Error 实现 error 接口
func (e *Error) Error() string {
	return e.Field + ": " + e.Message
}

// ToGRPC 转换为 gRPC 错误
func (e *Error) ToGRPC() error {
	return status.Errorf(codes.InvalidArgument, "%s: %s", e.Field, e.Message)
}

// Validator 验证器
type Validator struct {
	errors []*Error
}

// New 创建新的验证器
func New() *Validator {
	return &Validator{
		errors: make([]*Error, 0),
	}
}

// addError 添加验证错误
func (v *Validator) addError(field, message string) {
	v.errors = append(v.errors, &Error{
		Field:   field,
		Message: message,
	})
}

// HasErrors 检查是否有验证错误
func (v *Validator) HasErrors() bool {
	return len(v.errors) > 0
}

// Errors 返回所有验证错误
func (v *Validator) Errors() []*Error {
	return v.errors
}

// FirstError 返回第一个验证错误
func (v *Validator) FirstError() *Error {
	if len(v.errors) > 0 {
		return v.errors[0]
	}
	return nil
}

// ToGRPCError 转换为 gRPC 错误（返回第一个错误）
func (v *Validator) ToGRPCError() error {
	if !v.HasErrors() {
		return nil
	}
	return v.errors[0].ToGRPC()
}

// Required 验证必填字段
func (v *Validator) Required(field, value string) *Validator {
	if strings.TrimSpace(value) == "" {
		v.addError(field, "不能为空")
	}
	return v
}

// RequiredInt 验证必填整数（非零）
func (v *Validator) RequiredInt(field string, value int) *Validator {
	if value == 0 {
		v.addError(field, "不能为空")
	}
	return v
}

// RequiredInt64 验证必填 int64（非零）
func (v *Validator) RequiredInt64(field string, value int64) *Validator {
	if value == 0 {
		v.addError(field, "不能为空")
	}
	return v
}

// MinLength 验证最小长度
func (v *Validator) MinLength(field, value string, min int) *Validator {
	if utf8.RuneCountInString(value) < min {
		v.addError(field, "长度不能少于"+string(rune('0'+min))+"个字符")
	}
	return v
}

// MaxLength 验证最大长度
func (v *Validator) MaxLength(field, value string, max int) *Validator {
	if utf8.RuneCountInString(value) > max {
		v.addError(field, "长度不能超过"+string(rune('0'+max))+"个字符")
	}
	return v
}

// Length 验证长度范围
func (v *Validator) Length(field, value string, min, max int) *Validator {
	length := utf8.RuneCountInString(value)
	if length < min || length > max {
		v.addError(field, "长度必须在指定范围内")
	}
	return v
}

// Email 验证邮箱格式
func (v *Validator) Email(field, value string) *Validator {
	if value == "" {
		return v
	}
	_, err := mail.ParseAddress(value)
	if err != nil {
		v.addError(field, "邮箱格式无效")
	}
	return v
}

// Username 验证用户名格式
func (v *Validator) Username(field, value string) *Validator {
	if value == "" {
		return v
	}
	if !usernameRegex.MatchString(value) {
		v.addError(field, "用户名只能包含字母、数字和下划线，长度 3-20")
	}
	return v
}

// UUID 验证 UUID 格式
func (v *Validator) UUID(field, value string) *Validator {
	if value == "" {
		return v
	}
	if !uuidRegex.MatchString(value) {
		v.addError(field, "ID 格式无效")
	}
	return v
}

// Phone 验证手机号格式
func (v *Validator) Phone(field, value string) *Validator {
	if value == "" {
		return v
	}
	if !phoneRegex.MatchString(value) {
		v.addError(field, "手机号格式无效")
	}
	return v
}

// URL 验证 URL 格式
func (v *Validator) URL(field, value string) *Validator {
	if value == "" {
		return v
	}
	if !urlRegex.MatchString(value) {
		v.addError(field, "URL 格式无效")
	}
	return v
}

// Min 验证最小值
func (v *Validator) Min(field string, value, min int) *Validator {
	if value < min {
		v.addError(field, "值不能小于最小值")
	}
	return v
}

// Max 验证最大值
func (v *Validator) Max(field string, value, max int) *Validator {
	if value > max {
		v.addError(field, "值不能大于最大值")
	}
	return v
}

// Range 验证数值范围
func (v *Validator) Range(field string, value, min, max int) *Validator {
	if value < min || value > max {
		v.addError(field, "值必须在指定范围内")
	}
	return v
}

// In 验证值是否在允许列表中
func (v *Validator) In(field, value string, allowed []string) *Validator {
	if value == "" {
		return v
	}
	for _, a := range allowed {
		if value == a {
			return v
		}
	}
	v.addError(field, "值不在允许范围内")
	return v
}

// Regex 验证正则表达式
func (v *Validator) Regex(field, value string, pattern *regexp.Regexp, message string) *Validator {
	if value == "" {
		return v
	}
	if !pattern.MatchString(value) {
		v.addError(field, message)
	}
	return v
}

// Custom 自定义验证
func (v *Validator) Custom(field string, valid bool, message string) *Validator {
	if !valid {
		v.addError(field, message)
	}
	return v
}

// Password 验证密码强度
func (v *Validator) Password(field, value string) *Validator {
	if value == "" {
		return v
	}
	if len(value) < 8 {
		v.addError(field, "密码长度不能少于 8 位")
		return v
	}
	if len(value) > 128 {
		v.addError(field, "密码长度不能超过 128 位")
		return v
	}
	return v
}

// ---- 便捷函数 ----

// Required 快速验证必填字段
func Required(field, value string) error {
	if strings.TrimSpace(value) == "" {
		return status.Errorf(codes.InvalidArgument, "%s 不能为空", field)
	}
	return nil
}

// Email 快速验证邮箱
func Email(field, value string) error {
	if value == "" {
		return nil
	}
	_, err := mail.ParseAddress(value)
	if err != nil {
		return status.Errorf(codes.InvalidArgument, "%s 邮箱格式无效", field)
	}
	return nil
}

// UUID 快速验证 UUID
func UUID(field, value string) error {
	if value == "" {
		return status.Errorf(codes.InvalidArgument, "%s 不能为空", field)
	}
	if !uuidRegex.MatchString(value) {
		return status.Errorf(codes.InvalidArgument, "%s ID 格式无效", field)
	}
	return nil
}

// Username 快速验证用户名
func Username(field, value string) error {
	if value == "" {
		return status.Errorf(codes.InvalidArgument, "%s 不能为空", field)
	}
	if !usernameRegex.MatchString(value) {
		return status.Errorf(codes.InvalidArgument, "%s 只能包含字母、数字和下划线，长度 3-20", field)
	}
	return nil
}

// Password 快速验证密码
func Password(field, value string) error {
	if value == "" {
		return status.Errorf(codes.InvalidArgument, "%s 不能为空", field)
	}
	if len(value) < 8 {
		return status.Errorf(codes.InvalidArgument, "%s 长度不能少于 8 位", field)
	}
	if len(value) > 128 {
		return status.Errorf(codes.InvalidArgument, "%s 长度不能超过 128 位", field)
	}
	return nil
}

// Pagination 验证分页参数
func Pagination(page, pageSize int32) (int32, int32) {
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}
	return page, pageSize
}
