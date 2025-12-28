package service

import "errors"

// Service errors
var (
	ErrNotMember          = errors.New("user is not a member of this conversation")
	ErrNotAuthorized      = errors.New("user is not authorized to perform this action")
	ErrCannotAddToPrivate = errors.New("cannot add members to private conversations")
	ErrCacheNotAvailable  = errors.New("cache is not available")
	ErrInvalidInput       = errors.New("invalid input")
)
