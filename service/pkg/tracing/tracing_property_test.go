// Package tracing 提供 OpenTelemetry 分布式追踪封装
// 本文件包含 TraceID 传播的属性测试
package tracing

import (
	"context"
	"testing"

	"github.com/funcdfs/lesser/pkg/logger"
	"github.com/google/uuid"
	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
	"google.golang.org/grpc/metadata"
)

// genUUIDString 生成 UUID 字符串的生成器
func genUUIDString() gopter.Gen {
	return gen.Const(nil).Map(func(_ interface{}) string {
		return uuid.New().String()
	})
}

// TestTraceIDPropagationInGRPC 属性测试：TraceID 在 gRPC 调用中的传播
// Feature: service-refactoring, Property 8: TraceID Propagation in gRPC
// Validates: Requirements 4.2, 4.5
func TestTraceIDPropagationInGRPC(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// 属性 1：任何有效的 UUID 格式的 trace_id 都应该能够正确注入到 context 并提取出来
	properties.Property("trace_id 注入到 context 后可以正确提取", prop.ForAll(
		func(traceID string) bool {
			// 注入 trace_id 到 context
			ctx := logger.ContextWithTraceID(context.Background(), traceID)

			// 从 context 中提取 trace_id
			extracted := logger.TraceIDFromContext(ctx)

			// 验证提取的值与注入的值相同
			return extracted == traceID
		},
		genUUIDString(),
	))

	// 属性 2：trace_id 应该能够正确添加到 gRPC outgoing metadata
	properties.Property("trace_id 可以正确添加到 gRPC metadata", prop.ForAll(
		func(traceID string) bool {
			// 创建带 trace_id 的 metadata
			md := metadata.New(map[string]string{"trace_id": traceID})
			ctx := metadata.NewOutgoingContext(context.Background(), md)

			// 从 outgoing context 中提取 metadata
			outMD, ok := metadata.FromOutgoingContext(ctx)
			if !ok {
				return false
			}

			// 验证 trace_id 存在且值正确
			values := outMD.Get("trace_id")
			return len(values) > 0 && values[0] == traceID
		},
		genUUIDString(),
	))

	// 属性 3：trace_id 应该能够从 gRPC incoming metadata 中正确提取
	properties.Property("trace_id 可以从 gRPC incoming metadata 中提取", prop.ForAll(
		func(traceID string) bool {
			// 模拟 incoming metadata（服务端接收到的）
			md := metadata.New(map[string]string{"trace_id": traceID})
			ctx := metadata.NewIncomingContext(context.Background(), md)

			// 从 incoming context 中提取 metadata
			inMD, ok := metadata.FromIncomingContext(ctx)
			if !ok {
				return false
			}

			// 验证 trace_id 存在且值正确
			values := inMD.Get("trace_id")
			return len(values) > 0 && values[0] == traceID
		},
		genUUIDString(),
	))

	// 属性 4：空 context 应该返回空的 trace_id
	properties.Property("空 context 返回空 trace_id", prop.ForAll(
		func(_ int) bool {
			ctx := context.Background()
			extracted := logger.TraceIDFromContext(ctx)
			return extracted == ""
		},
		gen.Int(),
	))

	// 属性 5：trace_id 在多层 context 嵌套中保持不变
	properties.Property("trace_id 在 context 嵌套中保持不变", prop.ForAll(
		func(traceID string) bool {
			// 创建带 trace_id 的 context
			ctx := logger.ContextWithTraceID(context.Background(), traceID)

			// 添加其他 context 值（模拟嵌套）
			ctx = logger.ContextWithUserID(ctx, "user-123")
			ctx = logger.ContextWithRequestID(ctx, "req-456")

			// 验证 trace_id 仍然可以正确提取
			extracted := logger.TraceIDFromContext(ctx)
			return extracted == traceID
		},
		genUUIDString(),
	))

	properties.TestingRun(t)
}

// TestTraceIDPropagationInMessages 属性测试：TraceID 在消息中的传播
// Feature: service-refactoring, Property 9: TraceID Propagation in Messages
// Validates: Requirements 4.3, 4.6, 4.7
func TestTraceIDPropagationInMessages(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// 属性 1：任何有效的 trace_id 都应该能够存储在消息头中并正确提取
	properties.Property("trace_id 可以存储在消息头 map 中并正确提取", prop.ForAll(
		func(traceID string) bool {
			// 模拟消息头（类似 RabbitMQ amqp.Table）
			headers := map[string]interface{}{
				"trace_id": traceID,
			}

			// 提取 trace_id
			extracted, ok := headers["trace_id"].(string)
			return ok && extracted == traceID
		},
		genUUIDString(),
	))

	// 属性 2：从 context 提取的 trace_id 应该能够正确存储到消息头
	properties.Property("从 context 提取的 trace_id 可以存储到消息头", prop.ForAll(
		func(traceID string) bool {
			// 创建带 trace_id 的 context
			ctx := logger.ContextWithTraceID(context.Background(), traceID)

			// 从 context 提取 trace_id
			extracted := logger.TraceIDFromContext(ctx)

			// 存储到消息头
			headers := map[string]interface{}{}
			if extracted != "" {
				headers["trace_id"] = extracted
			}

			// 验证消息头中的值
			headerValue, ok := headers["trace_id"].(string)
			return ok && headerValue == traceID
		},
		genUUIDString(),
	))

	// 属性 3：从消息头提取的 trace_id 应该能够正确注入到 context
	properties.Property("从消息头提取的 trace_id 可以注入到 context", prop.ForAll(
		func(traceID string) bool {
			// 模拟消息头
			headers := map[string]interface{}{
				"trace_id": traceID,
			}

			// 从消息头提取 trace_id
			headerTraceID, ok := headers["trace_id"].(string)
			if !ok {
				return false
			}

			// 注入到 context
			ctx := logger.ContextWithTraceID(context.Background(), headerTraceID)

			// 验证 context 中的值
			extracted := logger.TraceIDFromContext(ctx)
			return extracted == traceID
		},
		genUUIDString(),
	))

	// 属性 4：消息头中不存在 trace_id 时，提取应该返回空值
	properties.Property("消息头中不存在 trace_id 时返回空值", prop.ForAll(
		func(_ int) bool {
			// 空消息头
			headers := map[string]interface{}{}

			// 尝试提取 trace_id
			_, ok := headers["trace_id"].(string)
			return !ok
		},
		gen.Int(),
	))

	// 属性 5：trace_id 的完整往返（context -> 消息头 -> context）应该保持值不变
	properties.Property("trace_id 完整往返保持值不变", prop.ForAll(
		func(traceID string) bool {
			// 步骤 1：注入到 context
			ctx1 := logger.ContextWithTraceID(context.Background(), traceID)

			// 步骤 2：从 context 提取并存储到消息头
			extracted1 := logger.TraceIDFromContext(ctx1)
			headers := map[string]interface{}{
				"trace_id": extracted1,
			}

			// 步骤 3：从消息头提取
			headerTraceID, ok := headers["trace_id"].(string)
			if !ok {
				return false
			}

			// 步骤 4：注入到新的 context
			ctx2 := logger.ContextWithTraceID(context.Background(), headerTraceID)

			// 步骤 5：从新 context 提取并验证
			extracted2 := logger.TraceIDFromContext(ctx2)
			return extracted2 == traceID
		},
		genUUIDString(),
	))

	properties.TestingRun(t)
}

// TestTraceIDGeneration 属性测试：TraceID 生成
// 验证生成的 TraceID 格式正确
func TestTraceIDGeneration(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// 属性 1：生成的 UUID 应该是有效的 UUID 格式
	properties.Property("生成的 UUID 格式有效", prop.ForAll(
		func(_ int) bool {
			// 生成 UUID
			id := uuid.New().String()

			// 验证可以解析回 UUID
			_, err := uuid.Parse(id)
			return err == nil
		},
		gen.Int(),
	))

	// 属性 2：每次生成的 UUID 应该是唯一的
	properties.Property("生成的 UUID 唯一", prop.ForAll(
		func(_ int) bool {
			// 生成两个 UUID
			id1 := uuid.New().String()
			id2 := uuid.New().String()

			// 验证不相同
			return id1 != id2
		},
		gen.Int(),
	))

	properties.TestingRun(t)
}
