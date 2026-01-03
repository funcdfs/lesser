// Package crypto 密码哈希工具
package crypto

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"fmt"
	"strings"

	"golang.org/x/crypto/argon2"
)

// Argon2Params Argon2 参数
type Argon2Params struct {
	Memory      uint32
	Iterations  uint32
	Parallelism uint8
	SaltLength  uint32
	KeyLength   uint32
}

// DefaultArgon2Params 默认 Argon2 参数
var DefaultArgon2Params = &Argon2Params{
	Memory:      64 * 1024,
	Iterations:  3,
	Parallelism: 2,
	SaltLength:  16,
	KeyLength:   32,
}

// PasswordHasher 密码哈希器
type PasswordHasher struct {
	params *Argon2Params
}

// NewPasswordHasher 创建密码哈希器
func NewPasswordHasher(params *Argon2Params) *PasswordHasher {
	if params == nil {
		params = DefaultArgon2Params
	}
	return &PasswordHasher{params: params}
}

// Hash 哈希密码
func (h *PasswordHasher) Hash(password string) (string, error) {
	// 生成随机盐
	salt := make([]byte, h.params.SaltLength)
	if _, err := rand.Read(salt); err != nil {
		return "", fmt.Errorf("生成盐失败: %w", err)
	}

	// 使用 Argon2id 哈希
	hash := argon2.IDKey(
		[]byte(password),
		salt,
		h.params.Iterations,
		h.params.Memory,
		h.params.Parallelism,
		h.params.KeyLength,
	)

	// 编码为字符串格式: $argon2id$v=19$m=65536,t=3,p=2$salt$hash
	b64Salt := base64.RawStdEncoding.EncodeToString(salt)
	b64Hash := base64.RawStdEncoding.EncodeToString(hash)

	encoded := fmt.Sprintf("$argon2id$v=%d$m=%d,t=%d,p=%d$%s$%s",
		argon2.Version, h.params.Memory, h.params.Iterations, h.params.Parallelism, b64Salt, b64Hash)

	return encoded, nil
}

// Verify 验证密码
func (h *PasswordHasher) Verify(password, encodedHash string) (bool, error) {
	// 解析哈希字符串
	params, salt, hash, err := h.decodeHash(encodedHash)
	if err != nil {
		return false, err
	}

	// 使用相同参数重新计算哈希
	otherHash := argon2.IDKey(
		[]byte(password),
		salt,
		params.Iterations,
		params.Memory,
		params.Parallelism,
		params.KeyLength,
	)

	// 常量时间比较
	return subtle.ConstantTimeCompare(hash, otherHash) == 1, nil
}

// decodeHash 解析哈希字符串
func (h *PasswordHasher) decodeHash(encodedHash string) (*Argon2Params, []byte, []byte, error) {
	parts := strings.Split(encodedHash, "$")
	if len(parts) != 6 {
		return nil, nil, nil, fmt.Errorf("无效的哈希格式")
	}

	if parts[1] != "argon2id" {
		return nil, nil, nil, fmt.Errorf("不支持的算法: %s", parts[1])
	}

	var version int
	if _, err := fmt.Sscanf(parts[2], "v=%d", &version); err != nil {
		return nil, nil, nil, fmt.Errorf("无效的版本: %w", err)
	}
	if version != argon2.Version {
		return nil, nil, nil, fmt.Errorf("不兼容的版本: %d", version)
	}

	params := &Argon2Params{}
	if _, err := fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &params.Memory, &params.Iterations, &params.Parallelism); err != nil {
		return nil, nil, nil, fmt.Errorf("无效的参数: %w", err)
	}

	salt, err := base64.RawStdEncoding.DecodeString(parts[4])
	if err != nil {
		return nil, nil, nil, fmt.Errorf("无效的盐: %w", err)
	}
	params.SaltLength = uint32(len(salt))

	hash, err := base64.RawStdEncoding.DecodeString(parts[5])
	if err != nil {
		return nil, nil, nil, fmt.Errorf("无效的哈希: %w", err)
	}
	params.KeyLength = uint32(len(hash))

	return params, salt, hash, nil
}
