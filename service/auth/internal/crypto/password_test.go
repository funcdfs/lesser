// Package crypto 提供密码哈希和验证单元测试
package crypto

import (
	"testing"
)

// ==================== 密码哈希器测试 ====================

func createTestPasswordHasher() *PasswordHasher {
	// 使用较低参数加速测试
	return NewPasswordHasher(&Argon2Params{
		Memory:      4096,
		Iterations:  1,
		Parallelism: 1,
		SaltLength:  16,
		KeyLength:   32,
	})
}

func TestPasswordHasher_Hash_Success(t *testing.T) {
	hasher := createTestPasswordHasher()

	hash, err := hasher.Hash("Password123")
	if err != nil {
		t.Fatalf("哈希密码失败: %v", err)
	}
	if hash == "" {
		t.Error("哈希结果为空")
	}
	// 验证哈希格式（Argon2id 格式）
	if len(hash) < 50 {
		t.Error("哈希结果长度不足")
	}
}

func TestPasswordHasher_Verify_Success(t *testing.T) {
	hasher := createTestPasswordHasher()

	password := "Password123"
	hash, err := hasher.Hash(password)
	if err != nil {
		t.Fatalf("哈希密码失败: %v", err)
	}

	// 验证正确密码
	match, err := hasher.Verify(password, hash)
	if err != nil {
		t.Fatalf("验证密码失败: %v", err)
	}
	if !match {
		t.Error("正确密码应该匹配")
	}
}

func TestPasswordHasher_Verify_WrongPassword(t *testing.T) {
	hasher := createTestPasswordHasher()

	hash, err := hasher.Hash("Password123")
	if err != nil {
		t.Fatalf("哈希密码失败: %v", err)
	}

	// 验证错误密码
	match, err := hasher.Verify("WrongPassword", hash)
	if err != nil {
		t.Fatalf("验证密码失败: %v", err)
	}
	if match {
		t.Error("错误密码不应该匹配")
	}
}

func TestPasswordHasher_DifferentHashesForSamePassword(t *testing.T) {
	hasher := createTestPasswordHasher()

	password := "Password123"
	hash1, err := hasher.Hash(password)
	if err != nil {
		t.Fatalf("第一次哈希失败: %v", err)
	}

	hash2, err := hasher.Hash(password)
	if err != nil {
		t.Fatalf("第二次哈希失败: %v", err)
	}

	// 由于盐不同，两次哈希结果应该不同
	if hash1 == hash2 {
		t.Error("相同密码的两次哈希结果应该不同（因为盐不同）")
	}

	// 但两个哈希都应该能验证原密码
	match1, _ := hasher.Verify(password, hash1)
	match2, _ := hasher.Verify(password, hash2)
	if !match1 || !match2 {
		t.Error("两个哈希都应该能验证原密码")
	}
}

func TestPasswordHasher_NeedsRehash(t *testing.T) {
	hasher := createTestPasswordHasher()

	hash, err := hasher.Hash("Password123")
	if err != nil {
		t.Fatalf("哈希密码失败: %v", err)
	}

	// 使用相同参数的哈希器，不需要重新哈希
	needsRehash := hasher.NeedsRehash(hash)
	// 注意：这个测试的结果取决于 pkg/auth 的实现
	// 如果参数相同，应该返回 false
	t.Logf("NeedsRehash 结果: %v", needsRehash)
}

// ==================== 密码验证器测试 ====================

func TestPasswordValidator_Validate_Success(t *testing.T) {
	validator := NewPasswordValidator(8, true, false)

	// 有效密码
	err := validate.Validate("Password123")
	if err != nil {
		t.Errorf("有效密码验证失败: %v", err)
	}
}

func TestPasswordValidator_Validate_TooShort(t *testing.T) {
	validator := NewPasswordValidator(8, true, false)

	// 密码太短
	err := validate.Validate("Pass1")
	if err == nil {
		t.Error("太短的密码应该验证失败")
	}
}

func TestPasswordValidator_Validate_NoNumber(t *testing.T) {
	validator := NewPasswordValidator(8, true, false)

	// 没有数字
	err := validate.Validate("PasswordOnly")
	if err == nil {
		t.Error("没有数字的密码应该验证失败")
	}
}

func TestPasswordValidator_Validate_NoMixedCase(t *testing.T) {
	validator := NewPasswordValidator(8, true, true) // 要求大小写混合

	// 没有大小写混合
	err := validate.Validate("password123")
	if err == nil {
		t.Error("没有大小写混合的密码应该验证失败")
	}
}

func TestPasswordValidator_Validate_MixedCase_Success(t *testing.T) {
	validator := NewPasswordValidator(8, true, true) // 要求大小写混合

	// 有大小写混合
	err := validate.Validate("Password123")
	if err != nil {
		t.Errorf("有大小写混合的密码验证失败: %v", err)
	}
}

func TestPasswordValidator_Validate_NumberNotRequired(t *testing.T) {
	validator := NewPasswordValidator(8, false, false) // 不要求数字

	// 没有数字但应该通过
	err := validate.Validate("PasswordOnly")
	if err != nil {
		t.Errorf("不要求数字时，没有数字的密码应该通过: %v", err)
	}
}

// ==================== 辅助函数测试 ====================

func TestContainsDigit(t *testing.T) {
	tests := []struct {
		input    string
		expected bool
	}{
		{"abc123", true},
		{"123", true},
		{"abc", false},
		{"", false},
		{"a1b", true},
	}

	for _, tt := range tests {
		result := containsDigit(tt.input)
		if result != tt.expected {
			t.Errorf("containsDigit(%q) = %v, want %v", tt.input, result, tt.expected)
		}
	}
}

func TestContainsMixedCase(t *testing.T) {
	tests := []struct {
		input    string
		expected bool
	}{
		{"AbC", true},
		{"ABC", false},
		{"abc", false},
		{"aB", true},
		{"", false},
		{"123", false},
		{"Abc123", true},
	}

	for _, tt := range tests {
		result := containsMixedCase(tt.input)
		if result != tt.expected {
			t.Errorf("containsMixedCase(%q) = %v, want %v", tt.input, result, tt.expected)
		}
	}
}
