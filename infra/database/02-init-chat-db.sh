#!/bin/bash
# ============================================================================
# Chat 数据库初始化脚本
# 在 PostgreSQL 容器启动时创建 lesser_chat_db 数据库
# ============================================================================

set -e

echo "Creating lesser_chat_db database..."

# 创建 chat 数据库
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE lesser_chat_db;
    GRANT ALL PRIVILEGES ON DATABASE lesser_chat_db TO $POSTGRES_USER;
EOSQL

echo "Initializing lesser_chat_db tables..."

# 在 chat 数据库中执行初始化 SQL
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "lesser_chat_db" -f /docker-entrypoint-initdb.d/init-chat.sql

echo "lesser_chat_db initialization completed!"
