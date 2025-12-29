package repository

import (
	"errors"
	"testing"
)

func TestErrors(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want string
	}{
		{"ErrNotFound", ErrNotFound, "记录不存在"},
		{"ErrDuplicate", ErrDuplicate, "记录重复"},
		{"ErrInvalidInput", ErrInvalidInput, "输入参数无效"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.err.Error() != tt.want {
				t.Errorf("%s.Error() = %v, want %v", tt.name, tt.err.Error(), tt.want)
			}
		})
	}
}

func TestErrorsAreDistinct(t *testing.T) {
	if errors.Is(ErrNotFound, ErrDuplicate) {
		t.Error("ErrNotFound should not be ErrDuplicate")
	}
	if errors.Is(ErrNotFound, ErrInvalidInput) {
		t.Error("ErrNotFound should not be ErrInvalidInput")
	}
	if errors.Is(ErrDuplicate, ErrInvalidInput) {
		t.Error("ErrDuplicate should not be ErrInvalidInput")
	}
}
