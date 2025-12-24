# Django 开发者指南

本指南汇总了 `lesser` 后端（Django）常用的本地开发、调试、测试及打包命令。

## 1. 本地开发与调试

### 1.1 环境启动
```bash
# 进入后端目录
cd backend/django

# 激活虚拟环境
source venv/bin/activate

# 启动开发服务器
python manage.py runserver
```

### 1.2 数据库迁移
```bash
# 生成迁移文件 (当你修改了 models.py)
python manage.py makemigrations

# 执行迁移同步数据库
python manage.py migrate

# 查看迁移状态
python manage.py showmigrations
```

### 1.3 交互式调试 (Shell)
```bash
# 启动增强版 Django Shell (支持 ORM 直接操作项目模型)
python manage.py shell
```

### 1.4 后台管理 (Admin)
- **管理地址**: `http://127.0.0.1:8000/admin/`
- **初始超级账号**: 
  - 用户名: `admin`
  - 密码: `admin123`
- **创建新超级用户**: `python manage.py createsuperuser`

---

## 2. API 与 文档

### 2.1 交互式 API 文档 (Django Ninja)
- **Swagger UI**: `http://127.0.0.1:8000/api/docs` (推荐，可直接测试接口)
- **Redoc**: `http://127.0.0.1:8000/api/redoc`

### 2.2 健康检查
```bash
curl http://127.0.0.1:8000/api/health
```

---

## 3. 代码质量控制 (Ruff)

```bash
# 代码检查 (Lint)
ruff check .

# 自动修复常见错误
ruff check . --fix

# 代码格式化 (Format)
ruff format .
```

---

## 4. 打包与生产环境准备

### 4.1 导出依赖项
```bash
# 更新 requirements.txt
pip freeze > requirements.txt
```

### 4.2 收集静态资源
```bash
# 部署前将所有静态文件收集到指定目录
python manage.py collectstatic
```

### 4.3 生产服务器模拟 (Gunicorn/Uvicorn)
```bash
# 使用 WSGI (同步)
gunicorn config.wsgi:application --bind 0.0.0.0:8000

# 使用 ASGI (异步, 推荐配 Django Ninja)
uvicorn config.api:api --host 0.0.0.0 --port 8000 --reload
# 或者启动整个 Django 应用
uvicorn config.asgi:application --host 0.0.0.0 --port 8000 --reload
```

---

## 5. 项目结构最佳实践
- `config/`: 核心配置文件（Settings, URLs, API Router）。
- `core/`: 存放通用的抽象模型、工具函数及应用的基础类。
- `requirements.txt`: 声明项目依赖。
- `.ruff.toml`: 代码风格约束配置。
