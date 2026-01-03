// Package timeutil 提供时间处理工具函数
// 支持时区转换、格式化、时间戳处理
package timeutil

import (
	"fmt"
	"time"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// 常用时区
var (
	UTC      = time.UTC
	Shanghai = mustLoadLocation("Asia/Shanghai")
)

// 常用时间格式
const (
	DateFormat     = "2006-01-02"
	TimeFormat     = "15:04:05"
	DateTimeFormat = "2006-01-02 15:04:05"
	ISO8601Format  = "2006-01-02T15:04:05Z07:00"
	RFC3339Format  = time.RFC3339
)

func mustLoadLocation(name string) *time.Location {
	loc, err := time.LoadLocation(name)
	if err != nil {
		panic(err)
	}
	return loc
}

// Now 返回当前 UTC 时间
func Now() time.Time {
	return time.Now().UTC()
}

// NowUnix 返回当前 Unix 时间戳（秒）
func NowUnix() int64 {
	return time.Now().Unix()
}

// NowUnixMilli 返回当前 Unix 时间戳（毫秒）
func NowUnixMilli() int64 {
	return time.Now().UnixMilli()
}

// NowUnixNano 返回当前 Unix 时间戳（纳秒）
func NowUnixNano() int64 {
	return time.Now().UnixNano()
}

// FromUnix 从 Unix 时间戳创建时间
func FromUnix(sec int64) time.Time {
	return time.Unix(sec, 0).UTC()
}

// FromUnixMilli 从毫秒时间戳创建时间
func FromUnixMilli(msec int64) time.Time {
	return time.UnixMilli(msec).UTC()
}

// FromUnixNano 从纳秒时间戳创建时间
func FromUnixNano(nsec int64) time.Time {
	return time.Unix(0, nsec).UTC()
}

// ToTimestamp 转换为 protobuf Timestamp
func ToTimestamp(t time.Time) *timestamppb.Timestamp {
	if t.IsZero() {
		return nil
	}
	return timestamppb.New(t)
}

// FromTimestamp 从 protobuf Timestamp 转换
func FromTimestamp(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

// ToTimestampPtr 转换为 protobuf Timestamp 指针（处理零值）
func ToTimestampPtr(t *time.Time) *timestamppb.Timestamp {
	if t == nil || t.IsZero() {
		return nil
	}
	return timestamppb.New(*t)
}

// Format 格式化时间
func Format(t time.Time, layout string) string {
	return t.Format(layout)
}

// FormatDate 格式化为日期
func FormatDate(t time.Time) string {
	return t.Format(DateFormat)
}

// FormatTime 格式化为时间
func FormatTime(t time.Time) string {
	return t.Format(TimeFormat)
}

// FormatDateTime 格式化为日期时间
func FormatDateTime(t time.Time) string {
	return t.Format(DateTimeFormat)
}

// FormatISO8601 格式化为 ISO8601
func FormatISO8601(t time.Time) string {
	return t.Format(ISO8601Format)
}

// Parse 解析时间字符串
func Parse(layout, value string) (time.Time, error) {
	return time.Parse(layout, value)
}

// ParseDate 解析日期字符串
func ParseDate(value string) (time.Time, error) {
	return time.Parse(DateFormat, value)
}

// ParseDateTime 解析日期时间字符串
func ParseDateTime(value string) (time.Time, error) {
	return time.Parse(DateTimeFormat, value)
}

// ParseInLocation 在指定时区解析时间
func ParseInLocation(layout, value string, loc *time.Location) (time.Time, error) {
	return time.ParseInLocation(layout, value, loc)
}

// InLocation 转换到指定时区
func InLocation(t time.Time, loc *time.Location) time.Time {
	return t.In(loc)
}

// InShanghai 转换到上海时区
func InShanghai(t time.Time) time.Time {
	return t.In(Shanghai)
}

// StartOfDay 获取当天开始时间
func StartOfDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
}

// EndOfDay 获取当天结束时间
func EndOfDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, 999999999, t.Location())
}

// StartOfWeek 获取本周开始时间（周一）
func StartOfWeek(t time.Time) time.Time {
	weekday := int(t.Weekday())
	if weekday == 0 {
		weekday = 7
	}
	return StartOfDay(t.AddDate(0, 0, -weekday+1))
}

// EndOfWeek 获取本周结束时间（周日）
func EndOfWeek(t time.Time) time.Time {
	return EndOfDay(StartOfWeek(t).AddDate(0, 0, 6))
}

// StartOfMonth 获取本月开始时间
func StartOfMonth(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), 1, 0, 0, 0, 0, t.Location())
}

// EndOfMonth 获取本月结束时间
func EndOfMonth(t time.Time) time.Time {
	return StartOfMonth(t).AddDate(0, 1, 0).Add(-time.Nanosecond)
}

// StartOfYear 获取本年开始时间
func StartOfYear(t time.Time) time.Time {
	return time.Date(t.Year(), 1, 1, 0, 0, 0, 0, t.Location())
}

// EndOfYear 获取本年结束时间
func EndOfYear(t time.Time) time.Time {
	return time.Date(t.Year(), 12, 31, 23, 59, 59, 999999999, t.Location())
}

// AddDays 添加天数
func AddDays(t time.Time, days int) time.Time {
	return t.AddDate(0, 0, days)
}

// AddMonths 添加月数
func AddMonths(t time.Time, months int) time.Time {
	return t.AddDate(0, months, 0)
}

// AddYears 添加年数
func AddYears(t time.Time, years int) time.Time {
	return t.AddDate(years, 0, 0)
}

// DaysBetween 计算两个时间之间的天数
func DaysBetween(start, end time.Time) int {
	return int(end.Sub(start).Hours() / 24)
}

// IsToday 判断是否是今天
func IsToday(t time.Time) bool {
	now := Now()
	return t.Year() == now.Year() && t.YearDay() == now.YearDay()
}

// IsYesterday 判断是否是昨天
func IsYesterday(t time.Time) bool {
	yesterday := Now().AddDate(0, 0, -1)
	return t.Year() == yesterday.Year() && t.YearDay() == yesterday.YearDay()
}

// IsFuture 判断是否是未来时间
func IsFuture(t time.Time) bool {
	return t.After(Now())
}

// IsPast 判断是否是过去时间
func IsPast(t time.Time) bool {
	return t.Before(Now())
}

// IsWeekend 判断是否是周末
func IsWeekend(t time.Time) bool {
	weekday := t.Weekday()
	return weekday == time.Saturday || weekday == time.Sunday
}

// RelativeTime 返回相对时间描述
func RelativeTime(t time.Time) string {
	now := Now()
	diff := now.Sub(t)

	if diff < 0 {
		diff = -diff
		return formatFuture(diff)
	}

	return formatPast(diff)
}

func formatPast(diff time.Duration) string {
	switch {
	case diff < time.Minute:
		return "刚刚"
	case diff < time.Hour:
		return formatDuration(diff.Minutes(), "分钟前")
	case diff < 24*time.Hour:
		return formatDuration(diff.Hours(), "小时前")
	case diff < 7*24*time.Hour:
		return formatDuration(diff.Hours()/24, "天前")
	case diff < 30*24*time.Hour:
		return formatDuration(diff.Hours()/(24*7), "周前")
	case diff < 365*24*time.Hour:
		return formatDuration(diff.Hours()/(24*30), "个月前")
	default:
		return formatDuration(diff.Hours()/(24*365), "年前")
	}
}

func formatFuture(diff time.Duration) string {
	switch {
	case diff < time.Minute:
		return "马上"
	case diff < time.Hour:
		return formatDuration(diff.Minutes(), "分钟后")
	case diff < 24*time.Hour:
		return formatDuration(diff.Hours(), "小时后")
	case diff < 7*24*time.Hour:
		return formatDuration(diff.Hours()/24, "天后")
	case diff < 30*24*time.Hour:
		return formatDuration(diff.Hours()/(24*7), "周后")
	case diff < 365*24*time.Hour:
		return formatDuration(diff.Hours()/(24*30), "个月后")
	default:
		return formatDuration(diff.Hours()/(24*365), "年后")
	}
}

func formatDuration(value float64, unit string) string {
	return fmt.Sprintf("%d%s", int(value), unit)
}

// SleepUntil 休眠直到指定时间
func SleepUntil(t time.Time) {
	duration := time.Until(t)
	if duration > 0 {
		time.Sleep(duration)
	}
}

// Ticker 创建定时器
func Ticker(d time.Duration) *time.Ticker {
	return time.NewTicker(d)
}

// Timer 创建计时器
func Timer(d time.Duration) *time.Timer {
	return time.NewTimer(d)
}

// After 返回一个在指定时间后发送当前时间的 channel
func After(d time.Duration) <-chan time.Time {
	return time.After(d)
}
