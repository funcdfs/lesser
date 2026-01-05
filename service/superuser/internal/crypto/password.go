// Package crypto 密码哈希工具
// 复用 pkg/auth 中的 Argon2id 实现
package crypto

import (
	pkgAuth "github.com/funcdfs/lesser/pkg/auth"
)

// Argon2Params Argon2 参数（类型别名，保持向后兼容）
type Argon2Params = pkgAuth.Argon2Config

// DefaultArgon2Params 默认 Argon2 参数
var DefaultArgon2Params = &Argon2Params{
	Memory:      64 * 1024,
	Iterations:  3,
	Parallelism: 2,
	SaltLength:  16,
	KeyLength:   32,
}

// PasswordHasher 密码哈希器（封装 pkg/auth 实现）
type PasswordHasher struct {
	inner *pkgAuth.PasswordHasher
}

// NewPasswordHasher 创建密码哈希器
func NewPasswordHasher(params *Argon2Params) *PasswordHasher {
	if params == nil {
		params = DefaultArgon2Params
	}
	return &PasswordHasher{
		inner: pkgAuth.NewPasswordHasher(*params),
	}
}

// Hash 哈希密码
func (h *PasswordHasher) Hash(password string) (string, error) {
	return h.inner.Hash(password)
}

// Verify 验证密码
func (h *PasswordHasher) Verify(password, encodedHash string) (bool, error) {
	return h.inner.Verify(password, encodedHash)
}

// NeedsRehash 检查是否需要重新哈希
func (h *PasswordHasher) NeedsRehash(encodedHash string) bool {
	return h.inner.NeedsRehash(encodedHash)
}
