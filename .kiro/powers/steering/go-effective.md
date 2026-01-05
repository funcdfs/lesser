# Go 1.25 Effective Coding Patterns

> 基于 go.dev 官方文档整理的 Go 最佳实践指南

## 核心原则

Go 是一门新语言，直接翻译 C++ 或 Java 程序不会产生满意的结果。要写好 Go 代码，必须理解其特性和惯用法。

## 1. 格式化 (Formatting)

**让机器处理格式化问题**：使用 `gofmt`，不要手动调整。

```go
// gofmt 会自动对齐
type T struct {
    name    string // 对象名称
    value   int    // 值
}
```

关键点：
- 使用 Tab 缩进（gofmt 默认）
- Go 没有行长度限制
- 控制结构不需要括号：`if x > 0 { ... }`

## 2. 命名规范 (Naming)

### 包名 (Package Names)
- 小写、单词、无下划线：`bufio` 而非 `buf_io`
- 简短、简洁、有表现力
- 包名是导入的默认名称

```go
// 好的包名
package http
package json
package sync

// 避免
package httpUtils      // 不要用 mixedCaps
package http_utils     // 不要用下划线
```

### 导出名称
- 使用包结构避免重复：`bufio.Reader` 而非 `bufio.BufReader`
- 构造函数：如果类型是包唯一导出的，用 `New()`

```go
// ring 包只导出 Ring 类型
ring.New()  // 而非 ring.NewRing()
```

### Getter/Setter
- Getter 不加 `Get` 前缀：`Owner()` 而非 `GetOwner()`
- Setter 加 `Set` 前缀：`SetOwner()`

```go
owner := obj.Owner()
if owner != user {
    obj.SetOwner(user)
}
```

### 接口命名
- 单方法接口以 `-er` 结尾：`Reader`, `Writer`, `Formatter`
- 不要给方法起与标准接口冲突的名字

### MixedCaps
- 使用 `MixedCaps` 或 `mixedCaps`，不用下划线
- 首字母大写 = 导出，小写 = 未导出

## 3. 控制结构 (Control Structures)

### If 语句
```go
// 支持初始化语句
if err := file.Chmod(0664); err != nil {
    log.Print(err)
    return err
}

// 避免不必要的 else
f, err := os.Open(name)
if err != nil {
    return err
}
// 继续使用 f，不需要 else
codeUsing(f)
```

### For 循环
```go
// 三种形式
for init; condition; post { }  // C 风格
for condition { }              // while 风格
for { }                        // 无限循环

// range 遍历
for key, value := range oldMap {
    newMap[key] = value
}

// Go 1.22+ 整数范围
for i := range 10 {
    fmt.Println(i)  // 0 到 9
}

// 只需要 key
for key := range m {
    if key.expired() {
        delete(m, key)
    }
}

// 只需要 value，用 _ 忽略 key
for _, value := range array {
    sum += value
}
```

### Switch
```go
// 不需要 break，自动终止
switch {
case '0' <= c && c <= '9':
    return c - '0'
case 'a' <= c && c <= 'f':
    return c - 'a' + 10
}

// 多个 case 值
switch c {
case ' ', '?', '&', '=', '#', '+', '%':
    return true
}

// 类型 switch
switch t := t.(type) {
case bool:
    fmt.Printf("boolean %t\n", t)
case int:
    fmt.Printf("integer %d\n", t)
default:
    fmt.Printf("unexpected type %T\n", t)
}
```

## 4. 函数 (Functions)

### 多返回值
```go
func (file *File) Write(b []byte) (n int, err error)

// 命名返回值作为文档
func nextInt(b []byte, pos int) (value, nextPos int)
```

### Defer
```go
func Contents(filename string) (string, error) {
    f, err := os.Open(filename)
    if err != nil {
        return "", err
    }
    defer f.Close()  // 函数返回前执行
    
    // ... 读取文件
    return string(result), nil
}
```

defer 特点：
- LIFO 顺序执行（后进先出）
- 参数在 defer 时求值，不是执行时
- 可以修改命名返回值

## 5. 数据结构 (Data)

### new vs make
```go
// new(T) 返回 *T，零值初始化
p := new(SyncedBuffer)  // *SyncedBuffer

// make(T, args) 用于 slice, map, channel
s := make([]int, 10, 100)  // len=10, cap=100
m := make(map[string]int)
c := make(chan int, 10)    // 带缓冲
```

### 复合字面量
```go
// 结构体
return &File{fd: fd, name: name}

// 数组/切片
a := [...]string{Enone: "no error", Eio: "Eio"}
s := []string{"no error", "Eio"}

// Map
m := map[string]int{"mon": 0, "tue": 1}
```

### 切片
```go
// 切片共享底层数组
s1 := a[1:4]
s2 := s1[1:3]  // s2 和 s1 共享数组

// append 可能重新分配
s = append(s, elem1, elem2)
s = append(s, anotherSlice...)
```

### Map
```go
// 检查 key 是否存在
if seconds, ok := timeZone[tz]; ok {
    return seconds
}

// 删除
delete(timeZone, "PDT")
```

## 6. 方法 (Methods)

### 指针 vs 值接收者
```go
// 值接收者：不修改接收者
func (p Point) Distance() float64 {
    return math.Sqrt(p.x*p.x + p.y*p.y)
}

// 指针接收者：修改接收者或避免复制
func (p *Point) Scale(factor float64) {
    p.x *= factor
    p.y *= factor
}
```

规则：
- 值方法可以在指针和值上调用
- 指针方法只能在指针上调用（编译器会自动取地址）

## 7. 接口 (Interfaces)

### 隐式实现
```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

// 任何实现 Read 方法的类型都实现了 Reader
type MyReader struct{}
func (r MyReader) Read(p []byte) (n int, err error) { ... }
```

### 类型断言
```go
// 单值形式（失败会 panic）
str := value.(string)

// 双值形式（安全）
str, ok := value.(string)
if ok {
    fmt.Printf("string value is: %q\n", str)
}
```

### 空接口
```go
// interface{} 或 any 可以持有任何值
func Printf(format string, v ...interface{})
```

## 8. 并发 (Concurrency)

### 核心理念
> "不要通过共享内存来通信；通过通信来共享内存。"

### Goroutine
```go
go list.Sort()  // 并发执行

go func() {
    time.Sleep(delay)
    fmt.Println(message)
}()

// Go 1.25: 使用 WaitGroup.Go
var wg sync.WaitGroup
wg.Go(func() {
    // 并发任务
})
wg.Wait()
```

### Channel
```go
// 创建
ci := make(chan int)         // 无缓冲
cs := make(chan *File, 100)  // 有缓冲

// 发送和接收
c <- value    // 发送
value := <-c  // 接收

// 用于同步
c := make(chan int)
go func() {
    list.Sort()
    c <- 1  // 发送完成信号
}()
doSomethingForAWhile()
<-c  // 等待完成
```

### Select
```go
select {
case v := <-ch1:
    fmt.Println("received from ch1:", v)
case ch2 <- x:
    fmt.Println("sent to ch2")
default:
    fmt.Println("no communication")
}
```

## 9. 错误处理 (Errors)

### 基本模式
```go
f, err := os.Open(name)
if err != nil {
    return err
}
// 使用 f

// 添加上下文
if err != nil {
    return fmt.Errorf("opening %s: %w", name, err)
}
```

### 错误检查
```go
// 检查特定错误
if errors.Is(err, os.ErrNotExist) {
    // 文件不存在
}

// 提取错误类型
var pathErr *os.PathError
if errors.As(err, &pathErr) {
    fmt.Println("failed at path:", pathErr.Path)
}
```

### Panic 和 Recover
```go
// panic 用于不可恢复的错误
func init() {
    if user == "" {
        panic("no value for $USER")
    }
}

// recover 用于捕获 panic
func safelyDo(work *Work) {
    defer func() {
        if err := recover(); err != nil {
            log.Println("work failed:", err)
        }
    }()
    do(work)
}
```

## 10. 项目结构 (Project Structure)

### 标准布局
```
project/
├── cmd/                # 入口点
│   └── myapp/
│       └── main.go
├── internal/           # 私有代码（不可被外部导入）
│   ├── handler/        # gRPC 处理器
│   ├── logic/          # 业务逻辑
│   └── data_access/    # 数据访问
├── pkg/                # 公共库代码
├── go.mod
└── go.sum
```

### 模块管理
```go
// go.mod
module github.com/user/project

go 1.25

require (
    github.com/some/dependency v1.2.3
)
```

## 11. Go 1.25 新特性

### Container-aware GOMAXPROCS
```go
// 自动根据 cgroup CPU 限制调整
// 可通过 GODEBUG 禁用
// GODEBUG=containermaxprocs=0
// GODEBUG=updatemaxprocs=0
```

### sync.WaitGroup.Go
```go
var wg sync.WaitGroup
wg.Go(func() {
    // 自动 Add(1) 和 Done()
    doWork()
})
wg.Wait()
```

### testing/synctest
```go
import "testing/synctest"

func TestConcurrent(t *testing.T) {
    synctest.Test(t, func(t *testing.T) {
        // 虚拟化时间的并发测试
        synctest.Wait()  // 等待所有 goroutine 阻塞
    })
}
```

### Flight Recorder
```go
import "runtime/trace"

fr := trace.NewFlightRecorder()
fr.Start()
// ... 程序运行
// 发生重要事件时
fr.WriteTo(file)  // 快照最近几秒的 trace
```

## 12. 性能优化

### 内存分配
```go
// 使用 sync.Pool 复用对象
var bufPool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

buf := bufPool.Get().(*bytes.Buffer)
defer bufPool.Put(buf)
buf.Reset()
```

### 避免不必要的分配
```go
// 预分配切片
s := make([]int, 0, expectedSize)

// 使用 strings.Builder
var b strings.Builder
b.WriteString("hello")
b.WriteString(" world")
result := b.String()
```

### 并发优化
```go
// 使用带缓冲的 channel 减少阻塞
ch := make(chan *Request, 100)

// 限制并发数
sem := make(chan struct{}, maxConcurrent)
for _, item := range items {
    sem <- struct{}{}
    go func(item Item) {
        defer func() { <-sem }()
        process(item)
    }(item)
}
```

## 参考文档

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Language Specification](https://go.dev/ref/spec)
- [Go 1.25 Release Notes](https://go.dev/doc/go1.25)
- [Go Standard Library](https://pkg.go.dev/std)
- [Go Modules Reference](https://go.dev/ref/mod)
