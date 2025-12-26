# Docker 国内镜像源配置 - 完成步骤

## ✅ 已完成的步骤

你的本地 Docker 配置文件已成功更新：
- **位置**: `~/.docker/daemon.json`
- **备份**: `~/.docker/daemon.json.bak`（自动备份的原配置）

已配置的国内镜像源：
```
✓ https://docker.1ms.run           (稳定快速)
✓ https://dockerhub.azk8s.cn       (微软维护)
✓ https://reg-mirror.qiniu.com     (七牛云)
✓ https://mirror.ccs.tencentyun.com (腾讯维护)
```

## ⚠️ 需要完成的步骤

### 重启 Docker Desktop（必须）

因为 macOS 上的 Docker Desktop 以虚拟机运行，需要重启才能应用配置：

**方法 1：通过菜单栏（推荐）**
1. 点击菜单栏顶部的 Docker 🐳 图标
2. 选择 **Quit Docker Desktop**（如果是 Docker Desktop，可能显示为 Quit）
3. 等待 Docker 完全关闭（菜单栏图标会消失）
4. 再次点击菜单栏的 Docker 图标或 Spotlight 搜索 "Docker" 并打开

**方法 2：通过终端**
```bash
# 停止 Docker
osascript -e 'quit app "Docker"'

# 等待 3-5 秒后重启
sleep 5 && open /Applications/Docker.app
```

## 🔍 验证配置

重启 Docker 后，运行以下命令验证：

```bash
# 查看镜像源是否生效
docker info | grep -A 5 "Registry Mirrors"
```

如果输出包含你配置的镜像源地址（如 `docker.1ms.run`），说明配置成功。

### 预期输出示例：
```
 Registry Mirrors:
  https://docker.1ms.run/
  https://dockerhub.azk8s.cn/
  https://reg-mirror.qiniu.com/
  https://mirror.ccs.tencentyun.com/
```

## 🐳 Docker 容器内的 Linux 源

Dockerfile 已配置好了容器内的 Linux apt 源：

### Python Django 容器
```dockerfile
# Debian 官方源 → 阿里云镜像
sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources

# PyPI 源 → 阿里云 PyPI 镜像  
pip install -i https://mirrors.aliyun.com/pypi/simple/ ...
```

✅ **无需额外配置**，构建时会自动使用国内源

## 🚀 现在可以启动环境

配置完成后，运行：

```bash
cd /Users/w/F/make_money_idea/lesser
./dev.sh
```

预期速度提升：**5-10 倍** 🚀

## 📋 完整流程检查表

- [ ] 已运行 `setup-docker-mirrors.sh` 脚本
- [ ] Docker 配置文件 `~/.docker/daemon.json` 已更新
- [ ] **已重启 Docker Desktop**（关键步骤）
- [ ] 验证命令输出包含国内镜像源
- [ ] 运行 `./dev.sh` 启动环境

## ❓ 常见问题

### Q: 重启后仍然很慢？
A: 
1. 再次检查 `docker info | grep Registry` 是否显示镜像源
2. 尝试拉取测试镜像：`docker pull alpine:latest`
3. 如果还是慢，可能是镜像源本身的问题，尝试禁用某个源

### Q: 如何禁用某个镜像源？
A: 编辑 `~/.docker/daemon.json`，删除对应的 URL，然后重启 Docker

### Q: 能看到配置变化吗？
A: 运行 `docker pull` 时会看到速度差异，应该快很多

### Q: 如果要恢复原配置？
A: 
```bash
cp ~/.docker/daemon.json.bak ~/.docker/daemon.json
# 然后重启 Docker
```

## 📞 需要帮助？

如果配置仍有问题，请检查：
1. Docker Desktop 是否完全重启
2. 网络连接是否正常
3. 查看 Docker Desktop 的日志
