---
inclusion: always
---

# 开发准则

> 详细规范见 `docs/开发准则.md`，UI 细节见 `docs/UI 细节.md`

## 核心原则

- 中文注释，中英混杂时前后加空格
- 优先使用官方库或热门库
- 最小化原则：只生成完成任务所需的代码
- 一致性原则：遵循现有代码风格

## 禁止行为

- ❌ 随意修改现有架构
- ❌ 不理解上下文就删代码
- ❌ 硬编码敏感信息
- ❌ 跳过错误处理
- ❌ 手动修改 gen_protos 目录

## 新增路由流程

1. Proto: `protos/<service>/<service>.proto`
2. 后端: `service/<service>/internal/handler/` + `logic/`
3. Gateway: `service/gateway/internal/router/`
4. Flutter: `lib/features/<module>/`

## gRPC 错误码

`OK` | `InvalidArgument` | `Unauthenticated` | `PermissionDenied` | `NotFound` | `Internal`

## CLI 工具

```bash
devlesser start [infra|service|flutter]
devlesser proto [go|dart]
devlesser test [service|full]
devlesser prod [start|stop|deploy]
```
