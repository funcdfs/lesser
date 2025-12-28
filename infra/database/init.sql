-- ============================================================================
-- PostgreSQL Database Initialization Script
-- ============================================================================
-- This script runs when the PostgreSQL container is first created
-- ============================================================================

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search optimization

-- ============================================================================
-- Create separate schemas for different services
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS posts;
CREATE SCHEMA IF NOT EXISTS feeds;
CREATE SCHEMA IF NOT EXISTS chat;
CREATE SCHEMA IF NOT EXISTS notifications;
CREATE SCHEMA IF NOT EXISTS search;

-- ============================================================================
-- Create application user with limited privileges (for services)
-- ============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'lesser_app') THEN
        CREATE ROLE lesser_app WITH LOGIN PASSWORD 'lesser_app_password';
    END IF;
END
$$;

-- Grant privileges to application user
GRANT USAGE ON SCHEMA auth, posts, feeds, chat, notifications, search TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA posts TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA feeds TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA chat TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA notifications TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA search TO lesser_app;

-- Grant default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA posts GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA feeds GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA chat GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA notifications GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA search GRANT ALL ON TABLES TO lesser_app;

-- Grant sequence privileges
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA auth TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA posts TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA feeds TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA chat TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA notifications TO lesser_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA search TO lesser_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA posts GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA feeds GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA chat GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA notifications GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA search GRANT USAGE, SELECT ON SEQUENCES TO lesser_app;

-- ============================================================================
-- Chat Service Tables (Go service will use these directly)
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) NOT NULL CHECK (type IN ('private', 'group', 'channel')),
    name VARCHAR(255),
    creator_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS chat.conversation_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES chat.conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS chat.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES chat.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for chat tables
CREATE INDEX IF NOT EXISTS idx_conversations_creator ON chat.conversations(creator_id);
CREATE INDEX IF NOT EXISTS idx_conversation_members_user ON chat.conversation_members(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_members_conversation ON chat.conversation_members(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON chat.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON chat.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON chat.messages(created_at DESC);

-- ============================================================================
-- Logging
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully';
END
$$;
