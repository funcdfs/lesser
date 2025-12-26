FROM python:3.11-slim

WORKDIR /app

# 使用阿里云的 Debian 源（国内速度更快）
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's|security.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# 使用阿里云的 Python pip 源（国内速度更快）
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ --upgrade pip setuptools wheel

# 复制依赖文件
COPY pyproject.toml requirements.txt* ./
COPY . .

# 安装 Python 依赖
# 如果有 requirements.txt 则使用，否则使用 pyproject.toml
RUN if [ -f requirements.txt ]; then \
    pip install -i https://mirrors.aliyun.com/pypi/simple/ -r requirements.txt; \
    else \
    pip install -i https://mirrors.aliyun.com/pypi/simple/ -e .; \
    fi

# 暴露端口
EXPOSE 8000

# 启动命令（会被 docker-compose 覆盖）
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
