# Lesser 开发与集成手册

本手册详细介绍了如何运行、使用以及扩展基于 **Django (Ninja)** 和 **Flutter (Riverpod/Dio)** 的融合架构。

## 🏗️ 架构概览

- **后端**: Django 5.0 + Django Ninja (异步 API, 自动生成 Swagger 文档)。
- **前端**: Flutter (采用 Feature-First 结构) + Riverpod 2.0 (状态管理) + Dio (网络层) + Freezed (不可变模型)。
- **通信**: RESTful API / JSON。

---

## 🚀 快速启动

### 1. 后端 (Django)
```bash
cd backend/django
# 激活环境
source venv/bin/activate
# 安装依赖
pip install -r requirements.txt
# 数据库迁移
python manage.py migrate
# 启动服务
python manage.py runserver
python manage.py createsuperuser
```
- **API 文档**: [http://127.0.0.1:8000/api/docs](http://127.0.0.1:8000/api/docs)
- **管理后台**: [http://127.0.0.1:8000/admin/](http://127.0.0.1:8000/admin/) (需创建超级用户: `python manage.py createsuperuser`)

### 2. 前端 (Flutter)
```bash
cd frontend
# 安装依赖
flutter pub get
# 运行代码生成
flutter pub run build_runner build --delete-conflicting-outputs
# 启动应用
flutter run
```

---

## 🛠️ 如何开发

### 后端：添加新功能 (以 "评论" 为例)
1.  **定义模型**: 在 `social/models.py` 添加 `Comment` 类。
2.  **后台注册**: 在 `social/admin.py` 中注册该模型。
3.  **编写接口**: 在 `config/` 下创建新的 API 路由文件，并在 `config/api.py` 中挂载。
4.  **迁移数据库**: `makemigrations` & `migrate`。

### 前端：接入新接口
1.  **定义模型**: 在 `domain/models/` 创建 `.dart` 文件，使用 `@freezed` 定义数据结构。
2.  **创建仓库**: 在 `data/` 下创建仓库类，继承 `BaseRepository`，调用 `apiClient.dio`。
3.  **定义 Provider**: 在 `presentation/providers/` 使用 `@riverpod` 定义数据流。
4.  **生成代码**: 运行 `build_runner`。
5.  **UI 绑定**: 在 Widget 中使用 `ref.watch(provider)`。

---

## 📝 进阶技巧

- **代码生成**: 修改任何带有 `part 'filename.g.dart'` 或 `part 'filename.freezed.dart'` 的文件后，必须运行 `build_runner`。建议开启 watch 模式：`flutter pub run build_runner watch`。
- **网路调试**: 应用集成了 `LogInterceptor`，所有 API 请求都会在控制台打印詳細的 Curl 日志，方便定位问题。
- **跨域设置**: `settings.py` 中的 `CORS_ALLOW_ALL_ORIGINS = DEBUG` 确保了开发环境下前端可以轻松访问后端。

---

## 📂 关键目录说明

- `backend/django/config/`: 项目核心配置与 API 根路由。
- `backend/django/social/`: 社交核心业务逻辑 (Models/Admin)。
- `frontend/lib/core/network/`: API 客户端、拦截器及端点定义。
- `frontend/lib/features/`: 按功能组织的业务模块。
