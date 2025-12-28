package repository

import "errors"

// 仓库层通用错误定义
var (
	ErrNotFound     = errors.New("记录不存在")
	ErrDuplicate    = errors.New("记录重复")
	ErrInvalidInput = errors.New("输入参数无效")
)
