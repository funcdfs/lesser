# API Gateway 使用指南：添加删减新功能

## 项目架构概述

当前项目采用API Gateway（Traefik）作为所有服务的统一入口，服务间通过gRPC进行通信。架构如下：

```
Flutter / 原生
   │ HTTPS / JSON
   ▼
API Gateway (Traefik)
   │ 路径分发
   ├─ /api/ → Django REST
   │          │ gRPC → Go Service / Python ML
   │          ▼
   │       Redis / PostgreSQL
   │
   ├─ /hot/ → Go Service REST/gRPC
   │          │
   │          ▼
   │       Redis / PostgreSQL
   │
   ├─ /feed/ → Rust Service REST/gRPC
   │          │
   │          ▼
   │       Redis / PostgreSQL
   │
   └─ / → 前端服务
```

## 一、添加新功能（服务）

### 1. 创建新的后端服务

以添加一个新的Python推荐服务为例：

```bash
# 创建服务目录
mkdir -p /Users/w/F/make_money_idea/lesser/backend/python_recommend

# 创建服务文件
cat > /Users/w/F/make_money_idea/lesser/backend/python_recommend/main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.get("/api/recommend/{user_id}")
async def get_recommendations(user_id: int):
    # 实现推荐逻辑
    return {"user_id": user_id, "recommendations": [1, 2, 3]}
EOF

# 创建Dockerfile
cat > /Users/w/F/make_money_idea/lesser/backend/python_recommend/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN pip install fastapi uvicorn

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8082"]
EOF
```

### 2. 在Docker Compose中添加服务

修改`/Users/w/F/make_money_idea/lesser/docker-compose.dev.yml`，添加新服务：

```yaml
# Python推荐服务
python_recommend:
  build: ./backend/python_recommend
  restart: unless-stopped
  depends_on:
    - redis
    - postgres
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8082/health"]
    interval: 10s
    timeout: 5s
    retries: 5
  networks:
    - gateway
  labels:
    - "traefik.enable=true"
    - "traefik.http.services.pythonRecommendService.loadbalancer.server.port=8082"
```

### 3. 在Traefik中配置路由

修改`/Users/w/F/make_money_idea/lesser/gateway/dynamic.yml`，添加新的服务和路由配置：

```yaml
# HTTP 服务配置
services:
  # 现有服务...
  
  # Python推荐服务
  pythonRecommendService:
    loadBalancer:
      servers:
        - url: "http://python_recommend:8082"

# 路由规则
routers:
  # 现有路由...
  
  # Python推荐服务路由
  pythonRecommendRouter:
    entryPoints:
      - websecure
    rule: "PathPrefix(`/recommend/`)"
    service: pythonRecommendService
    middlewares:
      - corsHeaders
      - compress
    tls:
      certResolver: myresolver
```

### 4. 重启服务

```bash
cd /Users/w/F/make_money_idea/lesser && docker-compose -f docker-compose.dev.yml up -d --build python_recommend
```

### 5. 验证新功能

访问`https://localhost/recommend/123`，应该能看到推荐服务的响应。

## 二、删除功能（服务）

### 1. 在Traefik中移除路由配置

修改`/Users/w/F/make_money_idea/lesser/gateway/dynamic.yml`，删除对应的服务和路由配置：

```yaml
# 删除以下部分（如果存在）：
# - pythonRecommendService 服务配置
# - pythonRecommendRouter 路由配置
```

### 2. 在Docker Compose中移除服务

修改`/Users/w/F/make_money_idea/lesser/docker-compose.dev.yml`，删除对应的服务配置：

```yaml
# 删除以下部分（如果存在）：
# python_recommend:
#   build: ./backend/python_recommend
#   ...
```

### 3. 停止并移除服务

```bash
cd /Users/w/F/make_money_idea/lesser && docker-compose -f docker-compose.dev.yml down python_recommend
```

### 4. 删除服务代码（可选）

```bash
rm -rf /Users/w/F/make_money_idea/lesser/backend/python_recommend
```

## 三、服务间使用gRPC通信

### 1. 定义gRPC协议

创建`.proto`文件定义服务接口：

```bash
mkdir -p /Users/w/F/make_money_idea/lesser/proto

cat > /Users/w/F/make_money_idea/lesser/proto/recommend.proto << 'EOF'
syntax = "proto3";

package recommend;

service RecommendService {
  rpc GetRecommendations (RecommendationRequest) returns (RecommendationResponse);
}

message RecommendationRequest {
  int32 user_id = 1;
  int32 limit = 2;
}

message RecommendationResponse {
  repeated int32 item_ids = 1;
  string message = 2;
}
EOF
```

### 2. 生成gRPC代码

#### Python服务端（推荐服务）：

```bash
cd /Users/w/F/make_money_idea/lesser/backend/python_recommend
pip install grpcio grpcio-tools
python -m grpc_tools.protoc -I../../proto --python_out=. --grpc_python_out=. ../../proto/recommend.proto
```

#### Python客户端（Django服务）：

```bash
cd /Users/w/F/make_money_idea/lesser/backend/django_code
pip install grpcio grpcio-tools
python -m grpc_tools.protoc -I../../proto --python_out=. --grpc_python_out=. ../../proto/recommend.proto
```

### 3. 实现gRPC服务端

修改推荐服务的`main.py`，添加gRPC支持：

```python
from concurrent import futures
import grpc
import recommend_pb2
import recommend_pb2_grpc
from fastapi import FastAPI

app = FastAPI()

# REST API部分
@app.get("/health")
async def health_check():
    return {"status": "ok"}

# gRPC服务实现
class RecommendServiceServicer(recommend_pb2_grpc.RecommendServiceServicer):
    def GetRecommendations(self, request, context):
        user_id = request.user_id
        limit = request.limit or 10
        # 实现推荐逻辑
        return recommend_pb2.RecommendationResponse(
            item_ids=[1, 2, 3, 4, 5],
            message=f"Recommendations for user {user_id}"
        )

# 启动gRPC服务器
def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    recommend_pb2_grpc.add_RecommendServiceServicer_to_server(
        RecommendServiceServicer(), server
    )
    server.add_insecure_port('[::]:50051')
    server.start()
    print("gRPC server started on port 50051")
    server.wait_for_termination()

# 启动FastAPI和gRPC服务器
if __name__ == "__main__":
    import threading
    import uvicorn
    
    # 在后台线程启动gRPC服务器
    grpc_thread = threading.Thread(target=serve)
    grpc_thread.daemon = True
    grpc_thread.start()
    
    # 启动FastAPI服务器
    uvicorn.run(app, host="0.0.0.0", port=8082)
```

### 4. 在Django中调用gRPC服务

在Django服务中创建gRPC客户端：

```python
# /Users/w/F/make_money_idea/lesser/backend/django_code/users/grpc_client.py
import grpc
import recommend_pb2
import recommend_pb2_grpc

def get_recommendations(user_id, limit=10):
    # 连接到gRPC服务
    with grpc.insecure_channel('python_recommend:50051') as channel:
        stub = recommend_pb2_grpc.RecommendServiceStub(channel)
        # 调用gRPC方法
        response = stub.GetRecommendations(
            recommend_pb2.RecommendationRequest(
                user_id=user_id,
                limit=limit
            )
        )
    return response
```

在Django视图中使用：

```python
# /Users/w/F/make_money_idea/lesser/backend/django_code/users/views.py
from django.http import JsonResponse
from django.views import View
from .grpc_client import get_recommendations

class RecommendationView(View):
    def get(self, request, user_id):
        try:
            # 调用gRPC服务
            response = get_recommendations(int(user_id))
            return JsonResponse({
                "user_id": user_id,
                "recommendations": list(response.item_ids),
                "message": response.message
            })
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)
```

## 四、最佳实践

1. **服务拆分原则**：
   - 按业务功能拆分服务
   - 每个服务负责单一职责
   - 服务间通过gRPC进行高效通信

2. **健康检查**：
   - 每个服务必须提供`/health`端点
   - 在Docker Compose中配置健康检查
   - Traefik会自动将不健康的服务从负载均衡中移除

3. **异步处理**：
   - Django端尽量使用Async Views (ASGI)调用gRPC
   - 对于非实时请求，使用Celery/Task Queue异步处理

4. **配置管理**：
   - 使用环境变量管理配置
   - 敏感配置使用`.env`文件，不要提交到版本控制

5. **监控和日志**：
   - Traefik提供访问日志，配置在`traefik.yml`中
   - 每个服务应输出详细的应用日志

通过以上方式，你可以灵活地使用API Gateway添加或删除新功能，同时保持服务间的高效通信。