# Lesser 项目

一个高效的微服务架构开发平台。

## 🚀 快速开始

> ⚠️ **国内用户必读**：为加快构建速度，请先配置 Docker 国内镜像源，参考 [Docker 国内镜像源配置](./docs/DOCKER_CHINA_MIRRORS.md)

```bash
./dev.sh
```

一条命令启动完整的后端开发环境。

## 📚 文档

完整文档位于 `docs/` 目录：

- **[快速开始](./docs/快速开始.md)** - 5分钟快速入门
- **[快速开发指南](./docs/guides/01_快速开发.md)** - 日常开发速查表
- **[脚本使用指南](./docs/guides/02_脚本使用指南.md)** - 完整脚本文档
- **[文档索引](./docs/文档索引.md)** - 所有文档导航

## 🏗️ 项目结构

```
.
├── dev.sh                      # 主启动脚本
├── scripts/                    # 开发脚本（已组织）
│   ├── dev/                   # 环境管理脚本
│   ├── db/                    # 数据库工具
│   └── utils/                 # 工具函数
├── docs/                       # 项目文档
│   └── guides/                # 开发指南
├── backend/                    # 后端代码
│   ├── django_code/           # Django 应用
│   ├── go_service/            # Go 服务
│   ├── rust_service/          # Rust 服务
│   └── cpp_service/           # C++ 服务
├── frontend/                   # 前端代码（Flutter）
├── infra/                      # 基础设施配置
│   ├── docker-compose.yml      # 基础环境
│   └── docker-compose-apisix.yml # 完整环境（推荐）
└── docker/                     # Docker 数据卷
```

## 🔧 常用命令

| 命令 | 功能 |
|------|------|
| `./dev.sh` | 启动完整后端环境 |
| `./dev.sh logs` | 查看实时日志 |
| `./dev.sh logs django` | 查看 Django 日志 |
| `./dev.sh restart django` | 重启 Django |
| `./dev.sh stop` | 停止所有服务 |
| `./dev.sh help` | 显示帮助 |

## 📖 技术栈

- **后端**: Django 5.1+ (Python), Go, Rust, C++
- **前端**: Flutter with TDesign
- **数据库**: PostgreSQL 16
- **缓存**: Redis 8
- **网关**: APISIX 3.9
- **配置**: etcd 3.5
- **容器**: Docker & Docker Compose

## 🔗 快速链接

- [Django README](./backend/django_code/README.md) - 后端架构详解
- [Flutter 架构指南](./docs/Flutter分层架构指南.md) - 前端分层设计
- [项目重构计划](./docs/项目重构计划.md) - 改进方案
- [部署说明](./docs/部署说明.md) - 生产部署指南

---

**需要帮助？** 查看 [快速开始](./docs/快速开始.md) 或运行 `./dev.sh help`
