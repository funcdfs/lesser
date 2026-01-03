package repository

import "errors"

var (
	// ErrNotFound 记录不存在
	ErrNotFound = errors.New("记录不存在")
	// ErrDuplicate 记录重复
	ErrDuplicate = errors.New("记录重复")
	// ErrInvalidInput 输入参数无效
	ErrInvalidInput = errors.New("输入参数无效")
)
