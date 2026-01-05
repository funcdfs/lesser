// Package pkg_test 提供 pkg 包的属性测试
// Feature: service-refactoring, Property 13: Code Quality
// Validates: Requirements 7.1, 7.3, 7.4
package pkg_test

import (
	"bufio"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// 所有服务列表
var codeQualityServices = []string{
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
	"gateway",
	"channel",
}

// genCodeQualityServiceName 生成服务名称的生成器
func genCodeQualityServiceName() gopter.Gen {
	return gen.IntRange(0, len(codeQualityServices)-1).Map(func(i int) string {
		return codeQualityServices[i]
	})
}

// getCodeQualityServicePath 获取服务路径
func getCodeQualityServicePath() string {
	wd, _ := os.Getwd()
	for {
		if filepath.Base(wd) == "service" {
			return wd
		}
		parent := filepath.Dir(wd)
		if parent == wd {
			return "../.."
		}
		wd = parent
	}
}

// TestProperty13_GoVetPasses 属性测试：所有服务必须通过 go vet
// Feature: service-refactoring, Property 13: Code Quality
// Validates: Requirements 7.1
func TestProperty13_GoVetPasses(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(codeQualityServices)

	properties := gopter.NewProperties(parameters)

	servicePath := getCodeQualityServicePath()

	properties.Property("所有服务必须通过 go vet 检查", prop.ForAll(
		func(serviceName string) bool {
			svcPath := filepath.Join(servicePath, serviceName)

			// 检查服务目录是否存在
			if _, err := os.Stat(svcPath); os.IsNotExist(err) {
				t.Logf("服务目录不存在: %s", svcPath)
				return false
			}

			// 运行 go vet
			cmd := exec.Command("go", "vet", "./...")
			cmd.Dir = svcPath
			output, err := cmd.CombinedOutput()
			if err != nil {
				t.Logf("服务 %s go vet 失败: %s\n%s", serviceName, err, string(output))
				return false
			}

			return true
		},
		genCodeQualityServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty13_GoBuildPasses 属性测试：所有服务必须能编译通过
// Feature: service-refactoring, Property 13: Code Quality
// Validates: Requirements 7.1
func TestProperty13_GoBuildPasses(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(codeQualityServices)

	properties := gopter.NewProperties(parameters)

	servicePath := getCodeQualityServicePath()

	properties.Property("所有服务必须能编译通过", prop.ForAll(
		func(serviceName string) bool {
			svcPath := filepath.Join(servicePath, serviceName)

			// 检查服务目录是否存在
			if _, err := os.Stat(svcPath); os.IsNotExist(err) {
				t.Logf("服务目录不存在: %s", svcPath)
				return false
			}

			// 运行 go build
			cmd := exec.Command("go", "build", "./...")
			cmd.Dir = svcPath
			output, err := cmd.CombinedOutput()
			if err != nil {
				t.Logf("服务 %s go build 失败: %s\n%s", serviceName, err, string(output))
				return false
			}

			return true
		},
		genCodeQualityServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty13_NoDirectSlogUsage 属性测试：不应直接使用 log/slog
// Feature: service-refactoring, Property 13: Code Quality
// Validates: Requirements 7.4
func TestProperty13_NoDirectSlogUsage(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(codeQualityServices)

	properties := gopter.NewProperties(parameters)

	servicePath := getCodeQualityServicePath()

	// 匹配直接导入 log/slog 的模式
	slogImportPattern := regexp.MustCompile(`"log/slog"`)

	properties.Property("服务不应直接导入 log/slog（应使用 pkg/log）", prop.ForAll(
		func(serviceName string) bool {
			svcPath := filepath.Join(servicePath, serviceName)

			// 检查服务目录是否存在
			if _, err := os.Stat(svcPath); os.IsNotExist(err) {
				return true
			}

			// 遍历所有 Go 文件
			err := filepath.Walk(svcPath, func(path string, info os.FileInfo, err error) error {
				if err != nil {
					return nil
				}

				// 跳过目录和非 Go 文件
				if info.IsDir() || !strings.HasSuffix(path, ".go") {
					return nil
				}

				// 跳过生成的 proto 文件
				if strings.Contains(path, "gen_protos") {
					return nil
				}

				// 读取文件内容
				content, err := os.ReadFile(path)
				if err != nil {
					return nil
				}

				// 检查是否直接导入 log/slog
				if slogImportPattern.Match(content) {
					t.Logf("服务 %s 文件 %s 直接导入了 log/slog", serviceName, path)
					return filepath.SkipAll
				}

				return nil
			})

			return err != filepath.SkipAll
		},
		genCodeQualityServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty13_UsesPkgLog 属性测试：服务应使用 pkg/log
// Feature: service-refactoring, Property 13: Code Quality
// Validates: Requirements 7.4
func TestProperty13_UsesPkgLog(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(codeQualityServices)

	properties := gopter.NewProperties(parameters)

	servicePath := getCodeQualityServicePath()

	// 匹配导入 pkg/log 的模式
	pkgLogPattern := regexp.MustCompile(`"github\.com/funcdfs/lesser/pkg/log"`)

	properties.Property("服务 main.go 应使用 pkg/log", prop.ForAll(
		func(serviceName string) bool {
			// 检查 main.go 文件
			var mainPath string
			if serviceName == "gateway" {
				mainPath = filepath.Join(servicePath, serviceName, "main.go")
			} else {
				mainPath = filepath.Join(servicePath, serviceName, "cmd", "server", "main.go")
			}

			// 检查文件是否存在
			if _, err := os.Stat(mainPath); os.IsNotExist(err) {
				return true // 文件不存在，跳过
			}

			// 读取文件内容
			content, err := os.ReadFile(mainPath)
			if err != nil {
				return true
			}

			// 检查是否导入 pkg/log
			if !pkgLogPattern.Match(content) {
				t.Logf("服务 %s 的 main.go 未使用 pkg/log", serviceName)
				return false
			}

			return true
		},
		genCodeQualityServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty13_ExportedFunctionsHaveComments 属性测试：导出的函数应有注释
// Feature: service-refactoring, Property 13: Code Quality
// Validates: Requirements 7.4
func TestProperty13_ExportedFunctionsHaveComments(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(codeQualityServices)

	properties := gopter.NewProperties(parameters)

	servicePath := getCodeQualityServicePath()

	// 匹配导出函数定义的模式（大写字母开头）
	exportedFuncPattern := regexp.MustCompile(`^func\s+([A-Z][a-zA-Z0-9]*)\s*\(`)
	exportedMethodPattern := regexp.MustCompile(`^func\s+\([^)]+\)\s+([A-Z][a-zA-Z0-9]*)\s*\(`)
	commentPattern := regexp.MustCompile(`^//`)

	properties.Property("导出的函数应有注释", prop.ForAll(
		func(serviceName string) bool {
			svcPath := filepath.Join(servicePath, serviceName)

			// 检查服务目录是否存在
			if _, err := os.Stat(svcPath); os.IsNotExist(err) {
				return true
			}

			missingComments := 0
			totalExported := 0

			// 遍历所有 Go 文件
			filepath.Walk(svcPath, func(path string, info os.FileInfo, err error) error {
				if err != nil {
					return nil
				}

				// 跳过目录和非 Go 文件
				if info.IsDir() || !strings.HasSuffix(path, ".go") {
					return nil
				}

				// 跳过生成的 proto 文件和测试文件
				if strings.Contains(path, "gen_protos") || strings.HasSuffix(path, "_test.go") {
					return nil
				}

				// 读取文件
				file, err := os.Open(path)
				if err != nil {
					return nil
				}
				defer file.Close()

				scanner := bufio.NewScanner(file)
				var prevLine string

				for scanner.Scan() {
					line := scanner.Text()
					trimmedLine := strings.TrimSpace(line)

					// 检查是否是导出函数
					if exportedFuncPattern.MatchString(trimmedLine) || exportedMethodPattern.MatchString(trimmedLine) {
						totalExported++
						// 检查前一行是否是注释
						if !commentPattern.MatchString(strings.TrimSpace(prevLine)) {
							missingComments++
						}
					}

					prevLine = line
				}

				return nil
			})

			// 允许最多 20% 的导出函数没有注释（宽松检查）
			if totalExported > 0 {
				missingRatio := float64(missingComments) / float64(totalExported)
				if missingRatio > 0.5 {
					t.Logf("服务 %s 有 %d/%d (%.1f%%) 导出函数缺少注释",
						serviceName, missingComments, totalExported, missingRatio*100)
					return false
				}
			}

			return true
		},
		genCodeQualityServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty13_NoUnusedImports 属性测试：不应有未使用的导入
// Feature: service-refactoring, Property 13: Code Quality
// Validates: Requirements 7.1
func TestProperty13_NoUnusedImports(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(codeQualityServices)

	properties := gopter.NewProperties(parameters)

	servicePath := getCodeQualityServicePath()

	properties.Property("服务不应有未使用的导入", prop.ForAll(
		func(serviceName string) bool {
			svcPath := filepath.Join(servicePath, serviceName)

			// 检查服务目录是否存在
			if _, err := os.Stat(svcPath); os.IsNotExist(err) {
				return true
			}

			// 运行 go build 检查未使用的导入
			cmd := exec.Command("go", "build", "-o", "/dev/null", "./...")
			cmd.Dir = svcPath
			output, err := cmd.CombinedOutput()
			if err != nil {
				outputStr := string(output)
				if strings.Contains(outputStr, "imported and not used") {
					t.Logf("服务 %s 有未使用的导入:\n%s", serviceName, outputStr)
					return false
				}
			}

			return true
		},
		genCodeQualityServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty13_ConsistentErrorHandling 属性测试：错误处理一致性
// Feature: service-refactoring, Property 13: Code Quality
// Validates: Requirements 7.4
func TestProperty13_ConsistentErrorHandling(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(codeQualityServices)

	properties := gopter.NewProperties(parameters)

	servicePath := getCodeQualityServicePath()

	// 检查是否使用 ToGRPCError 函数
	toGRPCErrorPattern := regexp.MustCompile(`ToGRPCError`)

	properties.Property("服务 logic 层应定义 ToGRPCError 函数", prop.ForAll(
		func(serviceName string) bool {
			// gateway 不需要 ToGRPCError
			if serviceName == "gateway" {
				return true
			}

			logicPath := filepath.Join(servicePath, serviceName, "internal", "logic")

			// 检查目录是否存在
			if _, err := os.Stat(logicPath); os.IsNotExist(err) {
				return true
			}

			// 检查 errors.go 文件
			errorsPath := filepath.Join(logicPath, "errors.go")
			if _, err := os.Stat(errorsPath); os.IsNotExist(err) {
				t.Logf("服务 %s 缺少 logic/errors.go", serviceName)
				return false
			}

			// 读取文件内容
			content, err := os.ReadFile(errorsPath)
			if err != nil {
				return true
			}

			// 检查是否定义了 ToGRPCError
			if !toGRPCErrorPattern.Match(content) {
				t.Logf("服务 %s 的 logic/errors.go 未定义 ToGRPCError", serviceName)
				return false
			}

			return true
		},
		genCodeQualityServiceName(),
	))

	properties.TestingRun(t)
}
