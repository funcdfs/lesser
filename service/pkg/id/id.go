// Package id 提供 ID 生成工具
// 支持 UUID、雪花 ID、短 ID 等
package id

import (
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"

	"github.com/google/uuid"
)

// NewUUID 生成新的 UUID
func NewUUID() string {
	return uuid.New().String()
}

// NewUUIDWithoutDash 生成不带横线的 UUID
func NewUUIDWithoutDash() string {
	id := uuid.New()
	return hex.EncodeToString(id[:])
}

// ParseUUID 解析 UUID 字符串
func ParseUUID(s string) (uuid.UUID, error) {
	return uuid.Parse(s)
}

// IsValidUUID 验证 UUID 格式
func IsValidUUID(s string) bool {
	_, err := uuid.Parse(s)
	return err == nil
}

// NewShortID 生成短 ID（URL 安全的 base64）
func NewShortID(length int) (string, error) {
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return base64.URLEncoding.EncodeToString(bytes)[:length], nil
}

// MustShortID 生成短 ID，失败时 panic
func MustShortID(length int) string {
	id, err := NewShortID(length)
	if err != nil {
		panic(err)
	}
	return id
}
