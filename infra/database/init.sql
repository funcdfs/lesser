-- ============================================================================
-- PostgreSQL Database Initialization Script
-- ============================================================================
-- 架构说明:
--   - lesser_db (默认): Django 核心服务 (用户、帖子、Feed 等)
--   - lesser_chat_db:   Go Chat 服务 (会话、消息)
-- 
-- 这种设计在一个 PostgreSQL 容器中创建两个独立数据库，
-- 既节省资源又保持服务间的数据隔离。
-- 未来 DAU 增长后可轻松拆分为独立的数据库服务器。
-- ============================================================================

-- ============================================================================
-- 1. 在默认数据库 (lesser_db) 中创建扩展和 Schema
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search optimization

-- Django 核心服务使用的 Schema
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS posts;
CREATE SCHEMA IF NOT EXISTS feeds;
CREATE SCHEMA IF NOT EXISTS notifications;
CREATE SCHEMA IF NOT EXISTS search;

-- ============================================================================
-- 2. 创建应用用户
-- ============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'lesser_app') THEN
        CREATE ROLE lesser_app WITH LOGIN PASSWORD 'lesser_app_password';
    END IF;
END
$$;

-- Grant privileges to application user on core schemas
GRANT USAGE ON SCHEMA auth, posts, feeds, notifications, search TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA posts TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA feeds TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA notifications TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA search TO lesser_app;

-- Grant default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA posts GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA feeds GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA notifications GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA search GRANT ALL ON TABLES TO lesser_app;

-- Grant sequence privileges
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA auth TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA posts TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA feeds TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA notifications TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA search TO lesser_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA posts GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA feeds GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA notifications GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA search GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;

-- ============================================================================
-- Logging
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Core database (lesser_db) initialization completed';
END
$$;
