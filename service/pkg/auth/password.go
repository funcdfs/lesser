package auth

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"

	"golang.org/x/crypto/argon2"
)

// Argon2 参数配置
type Argon2Config struct {
	Memory      uint32 // 内存使用量（KB）
	Iterations  uint32 // 迭代次数
	Parallelism uint8  // 并行度
	SaltLength  uint32 // 盐长度
	KeyLength   uint32 // 密钥长度
}

// DefaultArgon2Config 默认 Argon2 配置
func DefaultArgon2Config() Argon2Config {
	return Argon2Config{
		Memory:      64 * 1024, // 64 MB
		Iterations:  3,
		Parallelism: 2,
		SaltLength:  16,
		KeyLength:   32,
	}
}

// 预定义错误
var (
	ErrInvalidHash         = errors.New("无效的密码哈希格式")
	ErrIncompatibleVersion = errors.New("不兼容的 argon2 版本")
)

// PasswordHasher 密码哈希器
type PasswordHasher struct {
	config Argon2Config
}

// NewPasswordHasher 创建密码哈希器
func NewPasswordHasher(config Argon2Config) *PasswordHasher {
	return &PasswordHasher{config: config}
}

// DefaultPasswordHasher 创建默认配置的密码哈希器
func DefaultPasswordHasher() *PasswordHasher {
	return NewPasswordHasher(DefaultArgon2Config())
}

// Hash 对密码进行哈希
func (h *PasswordHasher) Hash(password string) (string, error) {
	// 生成随机盐
	salt := make([]byte, h.config.SaltLength)
	if _, err := rand.Read(salt); err != nil {
		return "", fmt.Errorf("生成盐失败: %w", err)
	}

	// 使用 Argon2id 进行哈希
	hash := argon2.IDKey(
		[]byte(password),
		salt,
		h.config.Iterations,
		h.config.Memory,
		h.config.Parallelism,
		h.config.KeyLength,
	)

	// 编码为标准格式: $argon2id$v=19$m=65536,t=3,p=2$salt$hash
	b64Salt := base64.RawStdEncoding.EncodeToString(salt)
	b64Hash := base64.RawStdEncoding.EncodeToString(hash)

	encoded := fmt.Sprintf(
		"$argon2id$v=%d$m=%d,t=%d,p=%d$%s$%s",
		argon2.Version,
		h.config.Memory,
		h.config.Iterations,
		h.config.Parallelism,
		b64Salt,
		b64Hash,
	)

	return encoded, nil
}

// Verify 验证密码
func (h *PasswordHasher) Verify(password, encodedHash string) (bool, error) {
	// 解析哈希
	config, salt, hash, err := decodeHash(encodedHash)
	if err != nil {
		return false, err
	}

	// 使用相同参数重新计算哈希
	otherHash := argon2.IDKey(
		[]byte(password),
		salt,
		config.Iterations,
		config.Memory,
		config.Parallelism,
		config.KeyLength,
	)

	// 使用恒定时间比较防止时序攻击
	if subtle.ConstantTimeCompare(hash, otherHash) == 1 {
		return true, nil
	}

	return false, nil
}

// NeedsRehash 检查是否需要重新哈希（参数变更时）
func (h *PasswordHasher) NeedsRehash(encodedHash string) bool {
	config, _, _, err := decodeHash(encodedHash)
	if err != nil {
		return true
	}

	return config.Memory != h.config.Memory ||
		config.Iterations != h.config.Iterations ||
		config.Parallelism != h.config.Parallelism ||
		config.KeyLength != h.config.KeyLength
}

// decodeHash 解析哈希字符串
func decodeHash(encodedHash string) (config Argon2Config, salt, hash []byte, err error) {
	parts := strings.Split(encodedHash, "$")
	if len(parts) != 6 {
		return config, nil, nil, ErrInvalidHash
	}

	if parts[1] != "argon2id" {
		return config, nil, nil, ErrInvalidHash
	}

	var version int
	_, err = fmt.Sscanf(parts[2], "v=%d", &version)
	if err != nil {
		return config, nil, nil, ErrInvalidHash
	}
	if version != argon2.Version {
		return config, nil, nil, ErrIncompatibleVersion
	}

	_, err = fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &config.Memory, &config.Iterations, &config.Parallelism)
	if err != nil {
		return config, nil, nil, ErrInvalidHash
	}

	salt, err = base64.RawStdEncoding.DecodeString(parts[4])
	if err != nil {
		return config, nil, nil, ErrInvalidHash
	}
	config.SaltLength = uint32(len(salt))

	hash, err = base64.RawStdEncoding.DecodeString(parts[5])
	if err != nil {
		return config, nil, nil, ErrInvalidHash
	}
	config.KeyLength = uint32(len(hash))

	return config, salt, hash, nil
}

// ---- 便捷函数 ----

var defaultHasher = DefaultPasswordHasher()

// HashPassword 使用默认配置哈希密码
func HashPassword(password string) (string, error) {
	return defaultHasher.Hash(password)
}

// VerifyPassword 使用默认配置验证密码
func VerifyPassword(password, encodedHash string) (bool, error) {
	return defaultHasher.Verify(password, encodedHash)
}

// GenerateRandomString 生成随机字符串
func GenerateRandomString(length int) (string, error) {
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return base64.URLEncoding.EncodeToString(bytes)[:length], nil
}

// GenerateSecureToken 生成安全 Token（用于重置密码等）
func GenerateSecureToken() (string, error) {
	return GenerateRandomString(32)
}
