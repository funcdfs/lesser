# Docker 国内镜像源配置指南

为了加速 Docker 镜像下载和减少流量消耗，建议在本地配置国内镜像源。

## macOS 配置方法

### 1. 打开 Docker Desktop 设置
- 点击菜单栏的 Docker 图标
- 选择 **Preferences** (或 **Settings**)

### 2. 进入 Docker Engine 配置
- 在左侧菜单找到 **Docker Engine**
- 在编辑框中找到 `"registry-mirrors"` 字段

### 3. 添加国内镜像源

将以下内容加入到 Docker Engine 配置中：

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://dockerhub.azk8s.cn",
    "https://reg-mirror.qiniu.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}
```

### 4. 应用配置
- 点击 **Apply & Restart** 按钮
- 等待 Docker 重启完成

## 验证配置

运行以下命令检查镜像源是否生效：

```bash
docker info | grep -A 5 "Registry Mirrors"
```

如果输出包含上面配置的镜像源地址，说明配置成功。

## Linux 配置方法

编辑 `/etc/docker/daemon.json`：

```bash
sudo nano /etc/docker/daemon.json
```

添加以下内容：

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://dockerhub.azk8s.cn",
    "https://reg-mirror.qiniu.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}
```

重启 Docker：

```bash
sudo systemctl restart docker
```

## 推荐的国内镜像源

| 源名称 | 地址 | 说明 |
|--------|------|------|
| 1ms | https://docker.1ms.run | 稳定快速 |
| Azure 中国 | https://dockerhub.azk8s.cn | 微软维护 |
| 七牛云 | https://reg-mirror.qiniu.com | 国内CDN |
| 腾讯云 | https://mirror.ccs.tencentyun.com | 腾讯维护 |

## Dockerfile 中的优化

本项目已经在 Dockerfile 中配置了：

1. **Debian 包源**：使用阿里云镜像源
   ```dockerfile
   RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources
   ```

2. **Python pip 源**：使用阿里云 PyPI 镜像
   ```dockerfile
   RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ ...
   ```

这样可以在容器构建时加快依赖安装速度。

## 性能对比

配置国内镜像源后，Docker 镜像拉取速度通常可以提升 **5-10 倍**。

## 常见问题

### Q: 配置后仍然很慢？
A: 
1. 确保 Docker 已完全重启
2. 尝试更换其他镜像源
3. 检查网络连接

### Q: 某些镜像拉取失败？
A: 
1. 该镜像可能在国内源不完整，尝试其他源
2. 或手动指定完整镜像路径：`docker pull docker.1ms.run/library/python:3.11-slim`

### Q: 如何判断镜像源是否可用？
A:
```bash
# 测试某个镜像源
docker pull docker.1ms.run/library/alpine:latest
```

