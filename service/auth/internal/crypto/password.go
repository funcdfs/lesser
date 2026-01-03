// Package crypto 提供密码哈希和验证功能
// 复用 pkg/auth 中的 Argon2id 实现
package crypto

import (
	"errors"
	"fmt"

	pkgAuth "github.com/funcdfs/lesser/pkg/auth"
)

// 错误定义（保持向后兼容）
var (
	ErrInvalidHash         = pkgAuth.ErrInvalidHash
	ErrIncompatibleVersion = pkgAuth.ErrIncompatibleVersion
	ErrPasswordTooShort    = errors.New("密码长度不足")
	ErrPasswordTooWeak     = errors.New("密码强度不足")
)

// Argon2Params Argon2id 参数配置
type Argon2Params = pkgAuth.Argon2Config

// DefaultParams 返回 OWASP 推荐的默认参数
func DefaultParams() *Argon2Params {
	cfg := pkgAuth.DefaultArgon2Config()
	// 使用 OWASP 推荐参数
	cfg.Memory = 19456 // 19 MiB
	cfg.Iterations = 2
	cfg.Parallelism = 1
	return &cfg
}

// PasswordHasher 密码哈希器（封装 pkg/auth 实现）
type PasswordHasher struct {
	inner *pkgAuth.PasswordHasher
}

// NewPasswordHasher 创建密码哈希器
func NewPasswordHasher(params *Argon2Params) *PasswordHasher {
	if params == nil {
		params = DefaultParams()
	}
	return &PasswordHasher{
		inner: pkgAuth.NewPasswordHasher(*params),
	}
}

// Hash 对密码进行哈希
func (h *PasswordHasher) Hash(password string) (string, error) {
	return h.inner.Hash(password)
}

// Verify 验证密码是否匹配
func (h *PasswordHasher) Verify(password, encodedHash string) (bool, error) {
	return h.inner.Verify(password, encodedHash)
}

// NeedsRehash 检查是否需要重新哈希
func (h *PasswordHasher) NeedsRehash(encodedHash string) bool {
	return h.inner.NeedsRehash(encodedHash)
}

// PasswordValidator 密码强度验证器
type PasswordValidator struct {
	MinLength   int
	RequireNum  bool
	RequireMix  bool
}

// NewPasswordValidator 创建密码验证器
func NewPasswordValidator(minLength int, requireNum, requireMix bool) *PasswordValidator {
	return &PasswordValidator{
		MinLength:   minLength,
		RequireNum:  requireNum,
		RequireMix:  requireMix,
	}
}

// Validate 验证密码强度
func (v *PasswordValidator) Validate(password string) error {
	if len(password) < v.MinLength {
		return fmt.Errorf("%w: 最少需要 %d 个字符", ErrPasswordTooShort, v.MinLength)
	}

	if v.RequireNum && !containsDigit(password) {
		return fmt.Errorf("%w: 需要包含数字", ErrPasswordTooWeak)
	}

	if v.RequireMix && !containsMixedCase(password) {
		return fmt.Errorf("%w: 需要包含大小写字母", ErrPasswordTooWeak)
	}

	return nil
}

// containsDigit 检查是否包含数字
func containsDigit(s string) bool {
	for _, c := range s {
		if c >= '0' && c <= '9' {
			return true
		}
	}
	return false
}

// containsMixedCase 检查是否包含大小写混合
func containsMixedCase(s string) bool {
	hasUpper, hasLower := false, false
	for _, c := range s {
		if c >= 'A' && c <= 'Z' {
			hasUpper = true
		}
		if c >= 'a' && c <= 'z' {
			hasLower = true
		}
		if hasUpper && hasLower {
			return true
		}
	}
	return false
}
