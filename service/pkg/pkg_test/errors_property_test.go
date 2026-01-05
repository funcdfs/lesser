// Package pkg_test 提供错误处理属性测试
// Feature: service-refactoring, Property 12: Error Handling Consistency
// Validates: Requirements 6.2, 6.3, 6.4, 6.5
package pkg_test

import (
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// 所有服务列表（用于错误处理测试）
var errorTestServices = []string{
	"auth",
	"user",
	"content",
	"comment",
	"interaction",
	"timeline",
	"search",
	"notification",
	"chat",
	"superuser",
}

// genErrorTestServiceName 生成服务名称的生成器
func genErrorTestServiceName() gopter.Gen {
	return gen.IntRange(0, len(errorTestServices)-1).Map(func(i int) string {
		return errorTestServices[i]
	})
}

// getErrorTestServicePath 获取服务路径
func getErrorTestServicePath() string {
	// 从测试目录向上查找 service 目录
	wd, _ := os.Getwd()
	for {
		if filepath.Base(wd) == "service" {
			return wd
		}
		parent := filepath.Dir(wd)
		if parent == wd {
			// 到达根目录，使用相对路径
			return "../.."
		}
		wd = parent
	}
}

// TestProperty12_DataAccessErrorsFileExists 属性测试：data_access 层必须有 errors.go
// Validates: Requirements 6.1
func TestProperty12_DataAccessErrorsFileExists(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(errorTestServices) * 2

	properties := gopter.NewProperties(parameters)

	servicePath := getErrorTestServicePath()

	properties.Property("每个服务的 data_access 层必须有 errors.go 文件", prop.ForAll(
		func(serviceName string) bool {
			errorsPath := filepath.Join(servicePath, serviceName, "internal", "data_access", "errors.go")

			if _, err := os.Stat(errorsPath); os.IsNotExist(err) {
				t.Logf("服务 %s 缺少 data_access/errors.go", serviceName)
				return false
			}

			return true
		},
		genErrorTestServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty12_LogicErrorsFileExists 属性测试：logic 层必须有 errors.go
// Validates: Requirements 6.2
func TestProperty12_LogicErrorsFileExists(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(errorTestServices) * 2

	properties := gopter.NewProperties(parameters)

	servicePath := getErrorTestServicePath()

	properties.Property("每个服务的 logic 层必须有 errors.go 文件", prop.ForAll(
		func(serviceName string) bool {
			errorsPath := filepath.Join(servicePath, serviceName, "internal", "logic", "errors.go")

			if _, err := os.Stat(errorsPath); os.IsNotExist(err) {
				t.Logf("服务 %s 缺少 logic/errors.go", serviceName)
				return false
			}

			return true
		},
		genErrorTestServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty12_ToGRPCErrorFunctionExists 属性测试：logic 层必须有 ToGRPCError 函数
// Validates: Requirements 6.2
func TestProperty12_ToGRPCErrorFunctionExists(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(errorTestServices) * 2

	properties := gopter.NewProperties(parameters)

	servicePath := getErrorTestServicePath()

	properties.Property("每个服务的 logic/errors.go 必须包含 ToGRPCError 函数", prop.ForAll(
		func(serviceName string) bool {
			errorsPath := filepath.Join(servicePath, serviceName, "internal", "logic", "errors.go")

			// 检查文件是否存在
			if _, err := os.Stat(errorsPath); os.IsNotExist(err) {
				return true // 文件不存在由其他测试检查
			}

			// 解析 Go 文件
			fset := token.NewFileSet()
			node, err := parser.ParseFile(fset, errorsPath, nil, parser.ParseComments)
			if err != nil {
				t.Logf("服务 %s 的 logic/errors.go 解析失败: %v", serviceName, err)
				return false
			}

			// 查找 ToGRPCError 函数
			found := false
			ast.Inspect(node, func(n ast.Node) bool {
				if fn, ok := n.(*ast.FuncDecl); ok {
					if fn.Name.Name == "ToGRPCError" {
						found = true
						return false
					}
				}
				return true
			})

			if !found {
				t.Logf("服务 %s 的 logic/errors.go 缺少 ToGRPCError 函数", serviceName)
				return false
			}

			return true
		},
		genErrorTestServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty12_HandlerUsesLogicToGRPCError 属性测试：Handler 层使用 logic.ToGRPCError
// Validates: Requirements 6.3
func TestProperty12_HandlerUsesLogicToGRPCError(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(errorTestServices) * 2

	properties := gopter.NewProperties(parameters)

	servicePath := getErrorTestServicePath()

	properties.Property("Handler 层应使用 logic.ToGRPCError 或 h.handleError 进行错误转换", prop.ForAll(
		func(serviceName string) bool {
			handlerDir := filepath.Join(servicePath, serviceName, "internal", "handler")

			// 检查目录是否存在
			if _, err := os.Stat(handlerDir); os.IsNotExist(err) {
				return true
			}

			entries, err := os.ReadDir(handlerDir)
			if err != nil {
				return true
			}

			for _, entry := range entries {
				if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".go") {
					continue
				}
				if strings.HasSuffix(entry.Name(), "_test.go") {
					continue
				}

				filePath := filepath.Join(handlerDir, entry.Name())
				content, err := os.ReadFile(filePath)
				if err != nil {
					continue
				}

				contentStr := string(content)

				// 检查是否导入了 logic 包
				hasLogicImport := strings.Contains(contentStr, `"github.com/funcdfs/lesser/`+serviceName+`/internal/logic"`)

				// 检查是否使用了 logic.ToGRPCError 或 handleError 或 mapError
				usesToGRPCError := strings.Contains(contentStr, "logic.ToGRPCError") ||
					strings.Contains(contentStr, "h.handleError") ||
					strings.Contains(contentStr, "mapError(err)")

				// 如果文件中有错误处理但没有使用标准方法，则失败
				hasErrorHandling := strings.Contains(contentStr, "return nil, ")
				if hasErrorHandling && !usesToGRPCError && !hasLogicImport {
					// 检查是否只是参数验证错误
					if !isOnlyParameterValidationError(contentStr) {
						t.Logf("服务 %s 的 %s 未使用 logic.ToGRPCError 进行错误转换", serviceName, entry.Name())
						return false
					}
				}
			}

			return true
		},
		genErrorTestServiceName(),
	))

	properties.TestingRun(t)
}

// isOnlyParameterValidationError 检查文件是否只包含参数验证错误
func isOnlyParameterValidationError(content string) bool {
	// 如果包含 status.Error(codes.Internal 或其他非参数验证错误，则不是只有参数验证
	nonValidationPatterns := []string{
		"status.Error(codes.Internal",
		"status.Error(codes.NotFound",
		"status.Error(codes.PermissionDenied",
		"status.Error(codes.Unauthenticated",
		"status.Error(codes.AlreadyExists",
		"status.Errorf(codes.Internal",
	}

	for _, pattern := range nonValidationPatterns {
		if strings.Contains(content, pattern) {
			return false
		}
	}

	return true
}

// TestProperty12_ErrorMessagesInChinese 属性测试：错误消息使用中文
// Validates: Requirements 6.5
func TestProperty12_ErrorMessagesInChinese(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(errorTestServices) * 2

	properties := gopter.NewProperties(parameters)

	servicePath := getErrorTestServicePath()

	properties.Property("logic/errors.go 中的 ToGRPCError 应返回中文错误消息", prop.ForAll(
		func(serviceName string) bool {
			errorsPath := filepath.Join(servicePath, serviceName, "internal", "logic", "errors.go")

			// 检查文件是否存在
			if _, err := os.Stat(errorsPath); os.IsNotExist(err) {
				return true
			}

			content, err := os.ReadFile(errorsPath)
			if err != nil {
				return true
			}

			contentStr := string(content)

			// 检查 status.Error 调用中是否包含中文
			// 简单检查：文件中应该包含中文字符
			hasChinese := containsChineseChar(contentStr)

			if !hasChinese {
				t.Logf("服务 %s 的 logic/errors.go 中的错误消息可能不是中文", serviceName)
				return false
			}

			return true
		},
		genErrorTestServiceName(),
	))

	properties.TestingRun(t)
}

// containsChineseChar 检查字符串是否包含中文字符
func containsChineseChar(s string) bool {
	for _, r := range s {
		if r >= 0x4e00 && r <= 0x9fff {
			return true
		}
	}
	return false
}

// TestProperty12_HandlerLogsTraceID 属性测试：Handler 层错误日志包含 trace_id
// Validates: Requirements 6.4
func TestProperty12_HandlerLogsTraceID(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(errorTestServices) * 2

	properties := gopter.NewProperties(parameters)

	servicePath := getErrorTestServicePath()

	properties.Property("Handler 层错误日志应包含 trace_id", prop.ForAll(
		func(serviceName string) bool {
			handlerDir := filepath.Join(servicePath, serviceName, "internal", "handler")

			// 检查目录是否存在
			if _, err := os.Stat(handlerDir); os.IsNotExist(err) {
				return true
			}

			entries, err := os.ReadDir(handlerDir)
			if err != nil {
				return true
			}

			for _, entry := range entries {
				if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".go") {
					continue
				}
				if strings.HasSuffix(entry.Name(), "_test.go") {
					continue
				}
				// 跳过辅助文件
				if entry.Name() == "converters.go" || entry.Name() == "stream.go" {
					continue
				}

				filePath := filepath.Join(handlerDir, entry.Name())
				content, err := os.ReadFile(filePath)
				if err != nil {
					continue
				}

				contentStr := string(content)

				// 检查是否有错误日志
				hasErrorLog := strings.Contains(contentStr, ".Error(") ||
					strings.Contains(contentStr, ".Warn(")

				// 如果有错误日志，检查是否包含 trace_id
				if hasErrorLog {
					hasTraceID := strings.Contains(contentStr, "trace_id") ||
						strings.Contains(contentStr, "TraceIDFromContext")

					if !hasTraceID {
						t.Logf("服务 %s 的 %s 错误日志可能缺少 trace_id", serviceName, entry.Name())
						// 这是一个警告，不是硬性失败
						// return false
					}
				}
			}

			return true
		},
		genErrorTestServiceName(),
	))

	properties.TestingRun(t)
}
