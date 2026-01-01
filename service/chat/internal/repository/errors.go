package repository

import "errors"

var (
	ErrNotFound     = errors.New("记录不存在")
	ErrDuplicate    = errors.New("记录重复")
	ErrInvalidInput = errors.New("输入参数无效")
)
