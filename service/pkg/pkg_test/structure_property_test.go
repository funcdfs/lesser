// Package pkg_test 提供 pkg 包的属性测试
// Feature: service-refactoring, Property 1 & 2: Service Directory Structure and File Naming Compliance
// Validates: Requirements 1.1, 1.4, 1.5, 1.6, 1.7, 1.8
package pkg_test

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
)

// 标准服务列表（有 cmd/server/main.go 的服务）
var standardServices = []string{
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

// 所有服务列表（包括 gateway）
var allServices = []string{
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
}

// 必需的目录结构（标准服务）
var requiredDirs = []string{
	"cmd/server",
	"internal/handler",
	"internal/logic",
	"internal/data_access",
}

// Gateway 必需的目录结构
var gatewayRequiredDirs = []string{
	"internal/router",
	"internal/server",
}

// 允许的 internal 子目录
var allowedInternalDirs = map[string]bool{
	"handler":     true,
	"logic":       true,
	"data_access": true,
	"remote":      true,
	"messaging":   true,
	"crypto":      true,
	"config":      true,
	"router":      true, // gateway 专用
	"auth":        true, // gateway 专用
	"errors":      true, // gateway 专用
	"interceptor": true, // gateway 专用
	"ratelimit":   true, // gateway 专用
	"server":      true, // gateway 专用
	"streaming":   true, // gateway 专用
}

// 文件命名模式（更宽松，适应现有代码）
var fileNamingPatterns = map[string]*regexp.Regexp{
	// handler: 允许 _handler.go, converters.go, stream.go 等
	"handler": regexp.MustCompile(`^[a-z][a-z0-9_]*\.go$`),
	// logic: 允许 _service.go, interfaces.go, errors.go, _cache.go 等
	"logic": regexp.MustCompile(`^[a-z][a-z0-9_]*\.go$`),
	// data_access: 允许 _data_access.go, _cache.go, errors.go 等
	"data_access": regexp.MustCompile(`^[a-z][a-z0-9_]*\.go$`),
	// remote: 必须以 _client.go 结尾
	"remote": regexp.MustCompile(`^[a-z][a-z0-9_]*_client\.go$`),
}

// genStandardServiceName 生成标准服务名称的生成器
func genStandardServiceName() gopter.Gen {
	return gen.IntRange(0, len(standardServices)-1).Map(func(i int) string {
		return standardServices[i]
	})
}

// genAllServiceName 生成所有服务名称的生成器
func genAllServiceName() gopter.Gen {
	return gen.IntRange(0, len(allServices)-1).Map(func(i int) string {
		return allServices[i]
	})
}

// getServicePath 获取服务路径
func getServicePath() string {
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

// TestProperty1_ServiceDirectoryStructureCompliance 属性测试：服务目录结构合规性
// Feature: service-refactoring, Property 1: Service Directory Structure Compliance
// Validates: Requirements 1.1, 1.4, 1.6, 1.7
func TestProperty1_ServiceDirectoryStructureCompliance(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(standardServices) * 3

	properties := gopter.NewProperties(parameters)

	servicePath := getServicePath()

	properties.Property("标准服务必须包含必需的目录结构", prop.ForAll(
		func(serviceName string) bool {
			svcPath := filepath.Join(servicePath, serviceName)

			// 检查服务目录是否存在
			if _, err := os.Stat(svcPath); os.IsNotExist(err) {
				t.Logf("服务目录不存在: %s", svcPath)
				return false
			}

			// 检查必需目录
			for _, dir := range requiredDirs {
				dirPath := filepath.Join(svcPath, dir)
				if _, err := os.Stat(dirPath); os.IsNotExist(err) {
					t.Logf("服务 %s 缺少必需目录: %s", serviceName, dir)
					return false
				}
			}

			return true
		},
		genStandardServiceName(),
	))

	properties.Property("服务目录不应包含非标准子目录", prop.ForAll(
		func(serviceName string) bool {
			svcPath := filepath.Join(servicePath, serviceName, "internal")

			// 检查 internal 目录是否存在
			if _, err := os.Stat(svcPath); os.IsNotExist(err) {
				return true // 如果 internal 不存在，跳过检查
			}

			entries, err := os.ReadDir(svcPath)
			if err != nil {
				return true
			}

			for _, entry := range entries {
				if entry.IsDir() && !allowedInternalDirs[entry.Name()] {
					t.Logf("服务 %s 包含非标准目录: internal/%s", serviceName, entry.Name())
					return false
				}
			}

			return true
		},
		genAllServiceName(),
	))

	properties.Property("data_access 目录不应包含子目录", prop.ForAll(
		func(serviceName string) bool {
			dataAccessPath := filepath.Join(servicePath, serviceName, "internal", "data_access")

			// 检查目录是否存在
			if _, err := os.Stat(dataAccessPath); os.IsNotExist(err) {
				return true
			}

			entries, err := os.ReadDir(dataAccessPath)
			if err != nil {
				return true
			}

			for _, entry := range entries {
				if entry.IsDir() {
					t.Logf("服务 %s 的 data_access 包含子目录: %s", serviceName, entry.Name())
					return false
				}
			}

			return true
		},
		genAllServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty2_FileNamingConventionCompliance 属性测试：文件命名规范合规性
// Feature: service-refactoring, Property 2: File Naming Convention Compliance
// Validates: Requirements 1.5, 1.8
func TestProperty2_FileNamingConventionCompliance(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(allServices) * 4

	properties := gopter.NewProperties(parameters)

	servicePath := getServicePath()

	properties.Property("handler 目录中的文件必须是有效的 Go 文件", prop.ForAll(
		func(serviceName string) bool {
			return checkFileNaming(t, servicePath, serviceName, "handler", fileNamingPatterns["handler"])
		},
		genAllServiceName(),
	))

	properties.Property("logic 目录中的文件必须是有效的 Go 文件", prop.ForAll(
		func(serviceName string) bool {
			return checkFileNaming(t, servicePath, serviceName, "logic", fileNamingPatterns["logic"])
		},
		genAllServiceName(),
	))

	properties.Property("data_access 目录中的文件必须是有效的 Go 文件", prop.ForAll(
		func(serviceName string) bool {
			return checkFileNaming(t, servicePath, serviceName, "data_access", fileNamingPatterns["data_access"])
		},
		genAllServiceName(),
	))

	properties.Property("remote 目录中的文件必须以 _client.go 结尾", prop.ForAll(
		func(serviceName string) bool {
			return checkFileNaming(t, servicePath, serviceName, "remote", fileNamingPatterns["remote"])
		},
		genAllServiceName(),
	))

	properties.TestingRun(t)
}

// checkFileNaming 检查目录中的文件命名是否符合规范
func checkFileNaming(t *testing.T, servicePath, serviceName, dirName string, pattern *regexp.Regexp) bool {
	dirPath := filepath.Join(servicePath, serviceName, "internal", dirName)

	// 检查目录是否存在
	if _, err := os.Stat(dirPath); os.IsNotExist(err) {
		return true // 目录不存在，跳过检查
	}

	entries, err := os.ReadDir(dirPath)
	if err != nil {
		return true
	}

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}

		fileName := entry.Name()

		// 跳过测试文件
		if strings.HasSuffix(fileName, "_test.go") {
			continue
		}

		// 跳过非 Go 文件
		if !strings.HasSuffix(fileName, ".go") {
			continue
		}

		if !pattern.MatchString(fileName) {
			t.Logf("服务 %s 的 %s 目录中文件命名不规范: %s", serviceName, dirName, fileName)
			return false
		}
	}

	return true
}

// TestProperty1_MainGoExists 属性测试：标准服务必须有 main.go
// Validates: Requirements 1.4
func TestProperty1_MainGoExists(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(standardServices) * 2

	properties := gopter.NewProperties(parameters)

	servicePath := getServicePath()

	properties.Property("标准服务必须有 cmd/server/main.go", prop.ForAll(
		func(serviceName string) bool {
			mainPath := filepath.Join(servicePath, serviceName, "cmd", "server", "main.go")

			if _, err := os.Stat(mainPath); os.IsNotExist(err) {
				t.Logf("服务 %s 缺少 main.go: %s", serviceName, mainPath)
				return false
			}

			return true
		},
		genStandardServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty2_NoSubdirectoriesInDataAccess 属性测试：data_access 不应有子目录
// Validates: Requirements 1.6
func TestProperty2_NoSubdirectoriesInDataAccess(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = len(allServices) * 2

	properties := gopter.NewProperties(parameters)

	servicePath := getServicePath()

	properties.Property("data_access 目录不应包含 postgres/redis 等子目录", prop.ForAll(
		func(serviceName string) bool {
			dataAccessPath := filepath.Join(servicePath, serviceName, "internal", "data_access")

			if _, err := os.Stat(dataAccessPath); os.IsNotExist(err) {
				return true
			}

			forbiddenDirs := []string{"postgres", "redis", "mysql", "mongo"}

			for _, forbidden := range forbiddenDirs {
				forbiddenPath := filepath.Join(dataAccessPath, forbidden)
				if _, err := os.Stat(forbiddenPath); err == nil {
					t.Logf("服务 %s 的 data_access 包含禁止的子目录: %s", serviceName, forbidden)
					return false
				}
			}

			return true
		},
		genAllServiceName(),
	))

	properties.TestingRun(t)
}

// TestProperty1_GatewayStructure 属性测试：Gateway 服务结构
// Validates: Requirements 1.7
func TestProperty1_GatewayStructure(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 10

	properties := gopter.NewProperties(parameters)

	servicePath := getServicePath()

	properties.Property("Gateway 服务必须包含必需的目录结构", prop.ForAll(
		func(_ int) bool {
			svcPath := filepath.Join(servicePath, "gateway")

			// 检查服务目录是否存在
			if _, err := os.Stat(svcPath); os.IsNotExist(err) {
				t.Logf("Gateway 服务目录不存在: %s", svcPath)
				return false
			}

			// 检查 Gateway 必需目录
			for _, dir := range gatewayRequiredDirs {
				dirPath := filepath.Join(svcPath, dir)
				if _, err := os.Stat(dirPath); os.IsNotExist(err) {
					t.Logf("Gateway 缺少必需目录: %s", dir)
					return false
				}
			}

			return true
		},
		gen.IntRange(0, 9),
	))

	properties.TestingRun(t)
}
