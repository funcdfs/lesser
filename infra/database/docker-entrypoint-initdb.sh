#!/bin/bash
# ============================================================================
# PostgreSQL Multi-Database Initialization Script
# ============================================================================
# 在一个 PostgreSQL 容器中创建两个独立数据库:
#   - lesser_db:      Django 核心服务
#   - lesser_chat_db: Go Chat 服务
# ============================================================================

set -e

# 创建 Chat 数据库
echo "Creating lesser_chat_db database..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE lesser_chat_db OWNER $POSTGRES_USER'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'lesser_chat_db')\gexec
EOSQL

# 初始化 Chat 数据库
echo "Initializing lesser_chat_db..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "lesser_chat_db" -f /docker-entrypoint-initdb.d/02-init-chat.sql

echo "Multi-database initialization completed!"
