// Package convert 提供类型转换工具
// 支持安全的类型转换、指针转换
package convert

import (
	"strconv"
	"time"
)

// ---- 字符串转换 ----

// StringToInt 字符串转 int
func StringToInt(s string, defaultVal int) int {
	if v, err := strconv.Atoi(s); err == nil {
		return v
	}
	return defaultVal
}

// StringToInt32 字符串转 int32
func StringToInt32(s string, defaultVal int32) int32 {
	if v, err := strconv.ParseInt(s, 10, 32); err == nil {
		return int32(v)
	}
	return defaultVal
}

// StringToInt64 字符串转 int64
func StringToInt64(s string, defaultVal int64) int64 {
	if v, err := strconv.ParseInt(s, 10, 64); err == nil {
		return v
	}
	return defaultVal
}

// StringToFloat64 字符串转 float64
func StringToFloat64(s string, defaultVal float64) float64 {
	if v, err := strconv.ParseFloat(s, 64); err == nil {
		return v
	}
	return defaultVal
}

// StringToBool 字符串转 bool
func StringToBool(s string, defaultVal bool) bool {
	if v, err := strconv.ParseBool(s); err == nil {
		return v
	}
	return defaultVal
}

// IntToString int 转字符串
func IntToString(i int) string {
	return strconv.Itoa(i)
}

// Int32ToString int32 转字符串
func Int32ToString(i int32) string {
	return strconv.FormatInt(int64(i), 10)
}

// Int64ToString int64 转字符串
func Int64ToString(i int64) string {
	return strconv.FormatInt(i, 10)
}

// Float64ToString float64 转字符串
func Float64ToString(f float64) string {
	return strconv.FormatFloat(f, 'f', -1, 64)
}

// BoolToString bool 转字符串
func BoolToString(b bool) string {
	return strconv.FormatBool(b)
}


// ---- 指针转换 ----

// Ptr 返回值的指针
func Ptr[T any](v T) *T {
	return &v
}

// Val 返回指针的值，如果为 nil 返回零值
func Val[T any](p *T) T {
	if p == nil {
		var zero T
		return zero
	}
	return *p
}

// ValOr 返回指针的值，如果为 nil 返回默认值
func ValOr[T any](p *T, defaultVal T) T {
	if p == nil {
		return defaultVal
	}
	return *p
}

// StringPtr 字符串指针
func StringPtr(s string) *string {
	return &s
}

// StringVal 字符串指针值
func StringVal(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

// IntPtr int 指针
func IntPtr(i int) *int {
	return &i
}

// IntVal int 指针值
func IntVal(p *int) int {
	if p == nil {
		return 0
	}
	return *p
}

// Int32Ptr int32 指针
func Int32Ptr(i int32) *int32 {
	return &i
}

// Int32Val int32 指针值
func Int32Val(p *int32) int32 {
	if p == nil {
		return 0
	}
	return *p
}

// Int64Ptr int64 指针
func Int64Ptr(i int64) *int64 {
	return &i
}

// Int64Val int64 指针值
func Int64Val(p *int64) int64 {
	if p == nil {
		return 0
	}
	return *p
}

// BoolPtr bool 指针
func BoolPtr(b bool) *bool {
	return &b
}

// BoolVal bool 指针值
func BoolVal(p *bool) bool {
	if p == nil {
		return false
	}
	return *p
}

// TimePtr time.Time 指针
func TimePtr(t time.Time) *time.Time {
	return &t
}

// TimeVal time.Time 指针值
func TimeVal(p *time.Time) time.Time {
	if p == nil {
		return time.Time{}
	}
	return *p
}

// ---- 切片转换 ----

// Map 对切片中的每个元素应用函数
func Map[T, U any](slice []T, fn func(T) U) []U {
	result := make([]U, len(slice))
	for i, v := range slice {
		result[i] = fn(v)
	}
	return result
}

// Filter 过滤切片
func Filter[T any](slice []T, fn func(T) bool) []T {
	result := make([]T, 0)
	for _, v := range slice {
		if fn(v) {
			result = append(result, v)
		}
	}
	return result
}

// Reduce 归约切片
func Reduce[T, U any](slice []T, initial U, fn func(U, T) U) U {
	result := initial
	for _, v := range slice {
		result = fn(result, v)
	}
	return result
}

// Contains 检查切片是否包含元素
func Contains[T comparable](slice []T, elem T) bool {
	for _, v := range slice {
		if v == elem {
			return true
		}
	}
	return false
}

// Unique 去重
func Unique[T comparable](slice []T) []T {
	seen := make(map[T]struct{})
	result := make([]T, 0)
	for _, v := range slice {
		if _, ok := seen[v]; !ok {
			seen[v] = struct{}{}
			result = append(result, v)
		}
	}
	return result
}

// Chunk 分块
func Chunk[T any](slice []T, size int) [][]T {
	if size <= 0 {
		return nil
	}
	var chunks [][]T
	for i := 0; i < len(slice); i += size {
		end := i + size
		if end > len(slice) {
			end = len(slice)
		}
		chunks = append(chunks, slice[i:end])
	}
	return chunks
}

// First 获取第一个元素
func First[T any](slice []T) (T, bool) {
	if len(slice) == 0 {
		var zero T
		return zero, false
	}
	return slice[0], true
}

// Last 获取最后一个元素
func Last[T any](slice []T) (T, bool) {
	if len(slice) == 0 {
		var zero T
		return zero, false
	}
	return slice[len(slice)-1], true
}
