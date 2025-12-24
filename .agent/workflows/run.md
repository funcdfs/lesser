---
description: 如何运行 Django 后端和 Flutter 前端
---

### 1. 运行 Django 后端
首先确保后端正在运行，以便前端可以调用 API。

```bash
cd backend/django
# 激活虚拟环境 (mac/linux)
source venv/bin/activate
# 安装依赖 (如果还没安装)
pip install -r requirements.txt
# 运行迁移
python manage.py migrate
# 启动服务
python manage.py runserver
```
> [!TIP]
> 运行后可以访问 [http://127.0.0.1:8000/api/docs](http://127.0.0.1:8000/api/docs) 查看交互式 API 文档。

---

### 2. 运行 Flutter 前端
在另一个终端窗口运行：

```bash
cd frontend
# 获取依赖
flutter pub get
# 运行代码生成 (如果修改了模型或 Provider)
flutter pub run build_runner build --delete-conflicting-outputs
# 启动应用
flutter run
```

---

### 3. 注意事项
- **API 地址**: 默认配置为 `127.0.0.1:8000`。如果在真机调试，请将 `lib/core/network/api_endpoints.dart` 中的 `baseUrl` 修改为你的电脑局域网 IP。
- **跨域 (CORS)**: 后端已配置 `django-cors-headers`，开发环境下会自动允许所有来源。
