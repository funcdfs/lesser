# 使用 Rust 官方镜像作为构建环境
FROM rust:latest AS builder

WORKDIR /app

# 复制 Cargo.toml
COPY Cargo.toml ./
# 创建一个虚拟的 main.rs 文件，用于下载依赖
RUN mkdir -p src && echo 'fn main() {}' > src/main.rs

# 下载依赖
RUN cargo build --release

# 复制真实的源代码
COPY src ./src

# 重新构建应用
RUN cargo build --release

# 使用轻量级的 Alpine 镜像作为运行环境
FROM alpine:latest

WORKDIR /app

# 复制构建好的应用
COPY --from=builder /app/target/release/rust_feed .

# 安装 curl 用于健康检查
RUN apk add --no-cache curl

# 暴露端口
EXPOSE 8081

# 运行应用
CMD ["./rust_feed"]