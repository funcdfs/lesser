// Package grpcclient 提供 gRPC 客户端连接池和拦截器
// 本文件包含 Remote Client 重试的属性测试
package grpcclient

import (
	"context"
	"testing"

	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// TestRemoteClientRetry 属性测试：Remote Client 重试
// Feature: service-refactoring, Property 11: Remote Client Retry
// Validates: Requirements 5.3
func TestRemoteClientRetry(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// 属性 1：可重试错误码应该被正确识别
	// 可重试的错误码：Unavailable, ResourceExhausted, Aborted, DeadlineExceeded
	properties.Property("可重试错误码被正确识别", prop.ForAll(
		func(codeInt int) bool {
			retryableCodes := []codes.Code{
				codes.Unavailable,
				codes.ResourceExhausted,
				codes.Aborted,
				codes.DeadlineExceeded,
			}

			// 选择一个可重试的错误码
			code := retryableCodes[codeInt%len(retryableCodes)]
			err := status.Error(code, "test error")

			return isRetryable(err)
		},
		gen.IntRange(0, 1000),
	))

	// 属性 2：不可重试错误码应该被正确识别
	properties.Property("不可重试错误码被正确识别", prop.ForAll(
		func(codeInt int) bool {
			nonRetryableCodes := []codes.Code{
				codes.OK,
				codes.Canceled,
				codes.Unknown,
				codes.InvalidArgument,
				codes.NotFound,
				codes.AlreadyExists,
				codes.PermissionDenied,
				codes.FailedPrecondition,
				codes.OutOfRange,
				codes.Unimplemented,
				codes.Internal,
				codes.DataLoss,
				codes.Unauthenticated,
			}

			// 选择一个不可重试的错误码
			code := nonRetryableCodes[codeInt%len(nonRetryableCodes)]
			err := status.Error(code, "test error")

			return !isRetryable(err)
		},
		gen.IntRange(0, 1000),
	))

	// 属性 3：nil 错误不应该被认为是可重试的
	properties.Property("nil 错误不可重试", prop.ForAll(
		func(_ int) bool {
			return !isRetryable(nil)
		},
		gen.Int(),
	))

	// 属性 4：非 gRPC 错误不应该被认为是可重试的
	properties.Property("非 gRPC 错误不可重试", prop.ForAll(
		func(_ int) bool {
			err := context.DeadlineExceeded // 这是一个非 gRPC 错误
			return !isRetryable(err)
		},
		gen.Int(),
	))

	// 属性 5：Unavailable 错误应该是可重试的
	properties.Property("Unavailable 错误可重试", prop.ForAll(
		func(msg string) bool {
			if msg == "" {
				msg = "service unavailable"
			}
			err := status.Error(codes.Unavailable, msg)
			return isRetryable(err)
		},
		gen.AnyString(),
	))

	// 属性 6：ResourceExhausted 错误应该是可重试的
	properties.Property("ResourceExhausted 错误可重试", prop.ForAll(
		func(msg string) bool {
			if msg == "" {
				msg = "resource exhausted"
			}
			err := status.Error(codes.ResourceExhausted, msg)
			return isRetryable(err)
		},
		gen.AnyString(),
	))

	// 属性 7：Aborted 错误应该是可重试的
	properties.Property("Aborted 错误可重试", prop.ForAll(
		func(msg string) bool {
			if msg == "" {
				msg = "aborted"
			}
			err := status.Error(codes.Aborted, msg)
			return isRetryable(err)
		},
		gen.AnyString(),
	))

	// 属性 8：DeadlineExceeded 错误应该是可重试的
	properties.Property("DeadlineExceeded 错误可重试", prop.ForAll(
		func(msg string) bool {
			if msg == "" {
				msg = "deadline exceeded"
			}
			err := status.Error(codes.DeadlineExceeded, msg)
			return isRetryable(err)
		},
		gen.AnyString(),
	))

	// 属性 9：InvalidArgument 错误不应该是可重试的
	properties.Property("InvalidArgument 错误不可重试", prop.ForAll(
		func(msg string) bool {
			if msg == "" {
				msg = "invalid argument"
			}
			err := status.Error(codes.InvalidArgument, msg)
			return !isRetryable(err)
		},
		gen.AnyString(),
	))

	// 属性 10：NotFound 错误不应该是可重试的
	properties.Property("NotFound 错误不可重试", prop.ForAll(
		func(msg string) bool {
			if msg == "" {
				msg = "not found"
			}
			err := status.Error(codes.NotFound, msg)
			return !isRetryable(err)
		},
		gen.AnyString(),
	))

	// 属性 11：PermissionDenied 错误不应该是可重试的
	properties.Property("PermissionDenied 错误不可重试", prop.ForAll(
		func(msg string) bool {
			if msg == "" {
				msg = "permission denied"
			}
			err := status.Error(codes.PermissionDenied, msg)
			return !isRetryable(err)
		},
		gen.AnyString(),
	))

	// 属性 12：Internal 错误不应该是可重试的
	properties.Property("Internal 错误不可重试", prop.ForAll(
		func(msg string) bool {
			if msg == "" {
				msg = "internal error"
			}
			err := status.Error(codes.Internal, msg)
			return !isRetryable(err)
		},
		gen.AnyString(),
	))

	properties.TestingRun(t)
}

// TestRetryableErrorCodes 属性测试：可重试错误码的完整性
func TestRetryableErrorCodes(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// 属性：所有 gRPC 错误码都应该有明确的可重试/不可重试分类
	properties.Property("所有 gRPC 错误码有明确分类", prop.ForAll(
		func(codeInt int) bool {
			// 所有可能的 gRPC 错误码
			allCodes := []codes.Code{
				codes.OK,
				codes.Canceled,
				codes.Unknown,
				codes.InvalidArgument,
				codes.DeadlineExceeded,
				codes.NotFound,
				codes.AlreadyExists,
				codes.PermissionDenied,
				codes.ResourceExhausted,
				codes.FailedPrecondition,
				codes.Aborted,
				codes.OutOfRange,
				codes.Unimplemented,
				codes.Internal,
				codes.Unavailable,
				codes.DataLoss,
				codes.Unauthenticated,
			}

			code := allCodes[codeInt%len(allCodes)]
			err := status.Error(code, "test error")

			// isRetryable 应该返回 true 或 false，不应该 panic
			result := isRetryable(err)
			_ = result // 只要不 panic 就算通过

			return true
		},
		gen.IntRange(0, 1000),
	))

	// 属性：可重试错误码集合是固定的
	properties.Property("可重试错误码集合固定", prop.ForAll(
		func(_ int) bool {
			// 验证可重试错误码集合
			retryableCodes := []codes.Code{
				codes.Unavailable,
				codes.ResourceExhausted,
				codes.Aborted,
				codes.DeadlineExceeded,
			}

			for _, code := range retryableCodes {
				err := status.Error(code, "test")
				if !isRetryable(err) {
					return false
				}
			}

			// 验证其他错误码不可重试
			nonRetryableCodes := []codes.Code{
				codes.OK,
				codes.Canceled,
				codes.Unknown,
				codes.InvalidArgument,
				codes.NotFound,
				codes.AlreadyExists,
				codes.PermissionDenied,
				codes.FailedPrecondition,
				codes.OutOfRange,
				codes.Unimplemented,
				codes.Internal,
				codes.DataLoss,
				codes.Unauthenticated,
			}

			for _, code := range nonRetryableCodes {
				err := status.Error(code, "test")
				if isRetryable(err) {
					return false
				}
			}

			return true
		},
		gen.Int(),
	))

	properties.TestingRun(t)
}

// TestIsRetryableConsistency 属性测试：isRetryable 函数的一致性
func TestIsRetryableConsistency(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// 属性：相同错误码的不同消息应该有相同的可重试性
	properties.Property("相同错误码不同消息可重试性一致", prop.ForAll(
		func(codeInt int, msg1, msg2 string) bool {
			allCodes := []codes.Code{
				codes.OK,
				codes.Canceled,
				codes.Unknown,
				codes.InvalidArgument,
				codes.DeadlineExceeded,
				codes.NotFound,
				codes.AlreadyExists,
				codes.PermissionDenied,
				codes.ResourceExhausted,
				codes.FailedPrecondition,
				codes.Aborted,
				codes.OutOfRange,
				codes.Unimplemented,
				codes.Internal,
				codes.Unavailable,
				codes.DataLoss,
				codes.Unauthenticated,
			}

			code := allCodes[codeInt%len(allCodes)]
			err1 := status.Error(code, msg1)
			err2 := status.Error(code, msg2)

			// 相同错误码应该有相同的可重试性
			return isRetryable(err1) == isRetryable(err2)
		},
		gen.IntRange(0, 1000),
		gen.AnyString(),
		gen.AnyString(),
	))

	// 属性：isRetryable 是幂等的
	properties.Property("isRetryable 幂等", prop.ForAll(
		func(codeInt int) bool {
			allCodes := []codes.Code{
				codes.Unavailable,
				codes.ResourceExhausted,
				codes.Aborted,
				codes.DeadlineExceeded,
				codes.InvalidArgument,
				codes.NotFound,
				codes.Internal,
			}

			code := allCodes[codeInt%len(allCodes)]
			err := status.Error(code, "test")

			// 多次调用应该返回相同结果
			result1 := isRetryable(err)
			result2 := isRetryable(err)
			result3 := isRetryable(err)

			return result1 == result2 && result2 == result3
		},
		gen.IntRange(0, 1000),
	))

	properties.TestingRun(t)
}
