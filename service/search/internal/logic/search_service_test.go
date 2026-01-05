// Package logic 提供 Search Service 单元测试
package logic

import (
	"testing"
)

// ==================== 分页参数测试 ====================

func TestNormalizeLimit_DefaultValue(t *testing.T) {
	// 测试默认分页限制
	tests := []struct {
		name     string
		input    int
		expected int
	}{
		{"零值", 0, defaultLimit},
		{"负值", -1, defaultLimit},
		{"正常值", 10, 10},
		{"边界值", 20, 20},
		{"超过最大值", 200, maxLimit},
		{"最大值", 100, 100},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := normalizeLimit(tt.input)
			if result != tt.expected {
				t.Errorf("normalizeLimit(%d) = %d, 期望 %d", tt.input, result, tt.expected)
			}
		})
	}
}

// ==================== 常量测试 ====================

func TestConstants(t *testing.T) {
	if defaultLimit != 20 {
		t.Errorf("defaultLimit 应该为 20，但得到: %d", defaultLimit)
	}
	if maxLimit != 100 {
		t.Errorf("maxLimit 应该为 100，但得到: %d", maxLimit)
	}
}

// ==================== SearchService 创建测试 ====================

func TestNewSearchService_NilDataAccess(t *testing.T) {
	// 测试传入 nil 数据访问层
	svc := NewSearchService(nil)
	if svc == nil {
		t.Error("NewSearchService 不应该返回 nil")
	}
	if svc.da != nil {
		t.Error("数据访问层应该为 nil")
	}
}
