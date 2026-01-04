-- ============================================================================
-- PostgreSQL 数据库初始化脚本 (lesser_db)
-- ============================================================================
-- 架构说明:
--   - lesser_db (本文件): 核心服务 (用户、帖子、交互、评论、通知等)
--   - lesser_chat_db: Chat 服务 (由 02-init-chat-db.sh 创建)
-- ============================================================================

-- ============================================================================
-- Part 1: 扩展和 Schema
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";           -- 文本搜索优化
CREATE EXTENSION IF NOT EXISTS "vector";            -- pgvector 语义搜索
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements"; -- PgHero 性能监控

-- 业务 Schema
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS posts;
CREATE SCHEMA IF NOT EXISTS feeds;
CREATE SCHEMA IF NOT EXISTS notifications;
CREATE SCHEMA IF NOT EXISTS search;

-- ============================================================================
-- Part 2: 应用用户权限
-- ============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'lesser_app') THEN
        CREATE ROLE lesser_app WITH LOGIN PASSWORD 'lesser_app_password';
    END IF;
END
$$;

GRANT USAGE ON SCHEMA auth, posts, feeds, notifications, search TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA posts TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA feeds TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA notifications TO lesser_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA search TO lesser_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA posts GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA feeds GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA notifications GRANT ALL ON TABLES TO lesser_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA search GRANT ALL ON TABLES TO lesser_app;

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
-- Part 3: 通用触发器函数
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ============================================================================
-- Part 4: Users 表 (User Service)
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    bio TEXT DEFAULT '',
    avatar_url VARCHAR(500),
    location VARCHAR(100) DEFAULT '',
    website VARCHAR(255) DEFAULT '',
    birthday DATE,
    is_active BOOLEAN DEFAULT true,
    is_staff BOOLEAN DEFAULT false,
    is_superuser BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    is_private BOOLEAN DEFAULT false,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_display_name ON users(display_name);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_users_is_private ON users(is_private);

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

GRANT ALL PRIVILEGES ON TABLE users TO lesser_app;

-- ============================================================================
-- Part 5: 关注关系表
-- ============================================================================
CREATE TABLE IF NOT EXISTS follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_follow UNIQUE (follower_id, following_id),
    CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower_id ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id ON follows(following_id);
CREATE INDEX IF NOT EXISTS idx_follows_created_at ON follows(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_follows_mutual ON follows(follower_id, following_id);
GRANT ALL PRIVILEGES ON TABLE follows TO lesser_app;

-- ============================================================================
-- Part 6: 屏蔽关系表 (1=不看他, 2=不让他看我, 3=拉黑)
-- ============================================================================
CREATE TABLE IF NOT EXISTS blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    block_type SMALLINT NOT NULL DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_block UNIQUE (blocker_id, blocked_id),
    CONSTRAINT no_self_block CHECK (blocker_id != blocked_id),
    CONSTRAINT valid_block_type CHECK (block_type IN (1, 2, 3))
);

CREATE INDEX IF NOT EXISTS idx_blocks_blocker_id ON blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocks_blocked_id ON blocks(blocked_id);
CREATE INDEX IF NOT EXISTS idx_blocks_type ON blocks(block_type);
CREATE INDEX IF NOT EXISTS idx_blocks_created_at ON blocks(created_at DESC);
GRANT ALL PRIVILEGES ON TABLE blocks TO lesser_app;

-- ============================================================================
-- Part 7: 用户设置表
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_privacy_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    is_private_account BOOLEAN DEFAULT false,
    allow_message_from_anyone BOOLEAN DEFAULT true,
    show_online_status BOOLEAN DEFAULT true,
    show_last_seen BOOLEAN DEFAULT true,
    allow_tagging BOOLEAN DEFAULT true,
    show_activity_status BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
GRANT ALL PRIVILEGES ON TABLE user_privacy_settings TO lesser_app;

CREATE TABLE IF NOT EXISTS user_notification_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    push_enabled BOOLEAN DEFAULT true,
    email_enabled BOOLEAN DEFAULT true,
    notify_new_follower BOOLEAN DEFAULT true,
    notify_like BOOLEAN DEFAULT true,
    notify_comment BOOLEAN DEFAULT true,
    notify_mention BOOLEAN DEFAULT true,
    notify_repost BOOLEAN DEFAULT true,
    notify_message BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
GRANT ALL PRIVILEGES ON TABLE user_notification_settings TO lesser_app;

DROP TRIGGER IF EXISTS update_user_privacy_settings_updated_at ON user_privacy_settings;
CREATE TRIGGER update_user_privacy_settings_updated_at
    BEFORE UPDATE ON user_privacy_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_notification_settings_updated_at ON user_notification_settings;
CREATE TRIGGER update_user_notification_settings_updated_at
    BEFORE UPDATE ON user_notification_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Part 8: 关注请求表（私密账户审批用）
-- ============================================================================
CREATE TABLE IF NOT EXISTS follow_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status SMALLINT NOT NULL DEFAULT 0,  -- 0=pending, 1=approved, 2=rejected
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_follow_request UNIQUE (requester_id, target_id),
    CONSTRAINT no_self_request CHECK (requester_id != target_id)
);

CREATE INDEX IF NOT EXISTS idx_follow_requests_target ON follow_requests(target_id, status);
CREATE INDEX IF NOT EXISTS idx_follow_requests_requester ON follow_requests(requester_id);
GRANT ALL PRIVILEGES ON TABLE follow_requests TO lesser_app;

DROP TRIGGER IF EXISTS update_follow_requests_updated_at ON follow_requests;
CREATE TRIGGER update_follow_requests_updated_at
    BEFORE UPDATE ON follow_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Part 9: Contents 表 (Content Service)
-- 类型: 1=STORY(24h过期), 2=SHORT(短文本), 3=ARTICLE(长文章)
-- 状态: 1=DRAFT, 2=PUBLISHED, 3=ARCHIVED, 4=DELETED
-- ============================================================================
CREATE TABLE IF NOT EXISTS contents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type SMALLINT NOT NULL DEFAULT 2,
    status SMALLINT NOT NULL DEFAULT 2,
    title VARCHAR(500),
    text TEXT NOT NULL DEFAULT '',
    summary TEXT,
    media_urls TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    reply_to_id UUID REFERENCES contents(id) ON DELETE SET NULL,
    quote_id UUID REFERENCES contents(id) ON DELETE SET NULL,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    repost_count INTEGER DEFAULT 0,
    bookmark_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    published_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    is_pinned BOOLEAN DEFAULT false,
    comments_disabled BOOLEAN DEFAULT false,
    language VARCHAR(10),
    CONSTRAINT valid_content_type CHECK (type IN (1, 2, 3)),
    CONSTRAINT valid_content_status CHECK (status IN (1, 2, 3, 4))
);

CREATE INDEX IF NOT EXISTS idx_contents_author_id ON contents(author_id);
CREATE INDEX IF NOT EXISTS idx_contents_type ON contents(type);
CREATE INDEX IF NOT EXISTS idx_contents_status ON contents(status);
CREATE INDEX IF NOT EXISTS idx_contents_created_at ON contents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contents_published_at ON contents(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_contents_expires_at ON contents(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_contents_reply_to_id ON contents(reply_to_id) WHERE reply_to_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_contents_quote_id ON contents(quote_id) WHERE quote_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_contents_tags ON contents USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_contents_author_type ON contents(author_id, type);
CREATE INDEX IF NOT EXISTS idx_contents_author_status ON contents(author_id, status);
CREATE INDEX IF NOT EXISTS idx_contents_pinned ON contents(author_id, is_pinned) WHERE is_pinned = true;
-- 注意: 不能在索引谓词中使用 NOW()，因为它不是 IMMUTABLE 函数
-- 过期内容的过滤应该在查询时进行
CREATE INDEX IF NOT EXISTS idx_contents_feed_timeline ON contents(author_id, published_at DESC NULLS LAST, created_at DESC) WHERE status = 2;
CREATE INDEX IF NOT EXISTS idx_contents_user_feed ON contents(author_id, is_pinned DESC, published_at DESC NULLS LAST) WHERE status = 2;

DROP TRIGGER IF EXISTS update_contents_updated_at ON contents;
CREATE TRIGGER update_contents_updated_at
    BEFORE UPDATE ON contents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
GRANT ALL PRIVILEGES ON TABLE contents TO lesser_app;

-- ============================================================================
-- Part 10: 交互表 (Likes, Bookmarks, Reposts)
-- ============================================================================
CREATE TABLE IF NOT EXISTS likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content_id UUID NOT NULL REFERENCES contents(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_like UNIQUE (user_id, content_id)
);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_content_id ON likes(content_id);
CREATE INDEX IF NOT EXISTS idx_likes_created_at ON likes(created_at DESC);
GRANT ALL PRIVILEGES ON TABLE likes TO lesser_app;

CREATE TABLE IF NOT EXISTS bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content_id UUID NOT NULL REFERENCES contents(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_bookmark UNIQUE (user_id, content_id)
);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_content_id ON bookmarks(content_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at ON bookmarks(created_at DESC);
GRANT ALL PRIVILEGES ON TABLE bookmarks TO lesser_app;

CREATE TABLE IF NOT EXISTS reposts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content_id UUID NOT NULL REFERENCES contents(id) ON DELETE CASCADE,
    quote TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_repost UNIQUE (user_id, content_id)
);
CREATE INDEX IF NOT EXISTS idx_reposts_user_id ON reposts(user_id);
CREATE INDEX IF NOT EXISTS idx_reposts_content_id ON reposts(content_id);
CREATE INDEX IF NOT EXISTS idx_reposts_created_at ON reposts(created_at DESC);
GRANT ALL PRIVILEGES ON TABLE reposts TO lesser_app;

-- ============================================================================
-- Part 11: Comments 表 (Comment Service)
-- ============================================================================
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES contents(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    reply_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author_id ON comments(author_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON comments(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_like_count ON comments(like_count DESC);
CREATE INDEX IF NOT EXISTS idx_comments_post_parent ON comments(post_id, parent_id) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_comments_post_hot ON comments(post_id, like_count DESC, created_at DESC) WHERE is_deleted = false AND parent_id IS NULL;

DROP TRIGGER IF EXISTS update_comments_updated_at ON comments;
CREATE TRIGGER update_comments_updated_at
    BEFORE UPDATE ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
GRANT ALL PRIVILEGES ON TABLE comments TO lesser_app;

CREATE TABLE IF NOT EXISTS comment_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_comment_like UNIQUE (user_id, comment_id)
);
CREATE INDEX IF NOT EXISTS idx_comment_likes_user_id ON comment_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_comment_likes_comment_id ON comment_likes(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_likes_created_at ON comment_likes(created_at DESC);
GRANT ALL PRIVILEGES ON TABLE comment_likes TO lesser_app;

-- ============================================================================
-- Part 12: Notifications 表 (1=LIKE, 2=COMMENT, 3=REPLY, 4=BOOKMARK, 5=MENTION, 6=FOLLOW, 7=REPOST)
-- ============================================================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type SMALLINT NOT NULL,
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    target_type VARCHAR(50),
    target_id UUID,
    message TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_notification_type CHECK (type IN (1, 2, 3, 4, 5, 6, 7))
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_actor_id ON notifications(actor_id) WHERE actor_id IS NOT NULL;
GRANT ALL PRIVILEGES ON TABLE notifications TO lesser_app;

-- ============================================================================
-- Part 13: User Bans 表 (Auth Service)
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_bans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    banned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    operator_id UUID,  -- SuperUser ID，不设外键约束（SuperUser 是独立认证体系）
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_bans_user_id ON user_bans(user_id);
CREATE INDEX IF NOT EXISTS idx_user_bans_active ON user_bans(user_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_user_bans_expires ON user_bans(expires_at) WHERE expires_at IS NOT NULL AND is_active = true;
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_bans_user_active_unique ON user_bans(user_id) WHERE is_active = true;

DROP TRIGGER IF EXISTS update_user_bans_updated_at ON user_bans;
CREATE TRIGGER update_user_bans_updated_at
    BEFORE UPDATE ON user_bans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
GRANT ALL PRIVILEGES ON TABLE user_bans TO lesser_app;

-- ============================================================================
-- Part 14: Search Embeddings 表 (pgvector 语义搜索)
-- ============================================================================
CREATE TABLE IF NOT EXISTS content_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_id UUID NOT NULL REFERENCES contents(id) ON DELETE CASCADE,
    embedding vector(384),
    text_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_content_embedding UNIQUE (content_id)
);

CREATE TABLE IF NOT EXISTS comment_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    embedding vector(384),
    text_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_comment_embedding UNIQUE (comment_id)
);

CREATE TABLE IF NOT EXISTS user_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    embedding vector(384),
    text_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_user_embedding UNIQUE (user_id)
);

-- HNSW 向量索引
CREATE INDEX IF NOT EXISTS idx_content_embeddings_vector ON content_embeddings USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);
CREATE INDEX IF NOT EXISTS idx_comment_embeddings_vector ON comment_embeddings USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);
CREATE INDEX IF NOT EXISTS idx_user_embeddings_vector ON user_embeddings USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);

CREATE INDEX IF NOT EXISTS idx_content_embeddings_content_id ON content_embeddings(content_id);
CREATE INDEX IF NOT EXISTS idx_comment_embeddings_comment_id ON comment_embeddings(comment_id);
CREATE INDEX IF NOT EXISTS idx_user_embeddings_user_id ON user_embeddings(user_id);

DROP TRIGGER IF EXISTS update_content_embeddings_updated_at ON content_embeddings;
CREATE TRIGGER update_content_embeddings_updated_at
    BEFORE UPDATE ON content_embeddings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_comment_embeddings_updated_at ON comment_embeddings;
CREATE TRIGGER update_comment_embeddings_updated_at
    BEFORE UPDATE ON comment_embeddings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_embeddings_updated_at ON user_embeddings;
CREATE TRIGGER update_user_embeddings_updated_at
    BEFORE UPDATE ON user_embeddings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

GRANT ALL PRIVILEGES ON TABLE content_embeddings TO lesser_app;
GRANT ALL PRIVILEGES ON TABLE comment_embeddings TO lesser_app;
GRANT ALL PRIVILEGES ON TABLE user_embeddings TO lesser_app;

-- ============================================================================
-- Part 15: SuperUser 表 (独立管理员系统)
-- ============================================================================
CREATE TABLE IF NOT EXISTS superusers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_login_ip VARCHAR(45),
    login_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_superusers_username ON superusers(username);
CREATE INDEX IF NOT EXISTS idx_superusers_email ON superusers(email);
CREATE INDEX IF NOT EXISTS idx_superusers_is_active ON superusers(is_active);

DROP TRIGGER IF EXISTS update_superusers_updated_at ON superusers;
CREATE TRIGGER update_superusers_updated_at
    BEFORE UPDATE ON superusers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
GRANT ALL PRIVILEGES ON TABLE superusers TO lesser_app;

CREATE TABLE IF NOT EXISTS superuser_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    superuser_id UUID NOT NULL REFERENCES superusers(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    target_type VARCHAR(50),
    target_id UUID,
    details JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_superuser_audit_logs_superuser_id ON superuser_audit_logs(superuser_id);
CREATE INDEX IF NOT EXISTS idx_superuser_audit_logs_action ON superuser_audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_superuser_audit_logs_target ON superuser_audit_logs(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_superuser_audit_logs_created_at ON superuser_audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_superuser_audit_logs_details ON superuser_audit_logs USING GIN(details);
GRANT ALL PRIVILEGES ON TABLE superuser_audit_logs TO lesser_app;

CREATE TABLE IF NOT EXISTS superuser_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    superuser_id UUID NOT NULL REFERENCES superusers(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    revoked_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_superuser_sessions_superuser_id ON superuser_sessions(superuser_id);
CREATE INDEX IF NOT EXISTS idx_superuser_sessions_token_hash ON superuser_sessions(token_hash);
CREATE INDEX IF NOT EXISTS idx_superuser_sessions_expires_at ON superuser_sessions(expires_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_superuser_sessions_active ON superuser_sessions(token_hash) WHERE revoked_at IS NULL;
GRANT ALL PRIVILEGES ON TABLE superuser_sessions TO lesser_app;

-- ============================================================================
-- Part 16: Chat 表 (Chat Service - lesser_chat_db 中也会创建)
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) NOT NULL CHECK (type IN ('private', 'group', 'channel')),
    name VARCHAR(255),
    creator_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS chat_conversation_members (
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGSERIAL PRIMARY KEY,
    local_id INT NOT NULL DEFAULT 0,
    dialog_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    content TEXT,
    msg_type SMALLINT DEFAULT 0,
    entities JSONB,
    media_info JSONB,
    reply_to_id BIGINT,
    date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edit_date TIMESTAMP WITH TIME ZONE,
    is_outgoing BOOLEAN DEFAULT TRUE,
    is_unread BOOLEAN DEFAULT TRUE,
    flags INT DEFAULT 0,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_chat_conversations_creator ON chat_conversations(creator_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversation_members_user ON chat_conversation_members(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversation_members_conversation ON chat_conversation_members(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_dialog ON chat_messages(dialog_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_date ON chat_messages(date DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_local_id ON chat_messages(local_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_dialog_date ON chat_messages(dialog_id, date);
CREATE INDEX IF NOT EXISTS idx_chat_messages_reply ON chat_messages(reply_to_id) WHERE reply_to_id IS NOT NULL;

GRANT ALL PRIVILEGES ON TABLE chat_conversations TO lesser_app;
GRANT ALL PRIVILEGES ON TABLE chat_conversation_members TO lesser_app;
GRANT ALL PRIVILEGES ON TABLE chat_messages TO lesser_app;
GRANT USAGE, SELECT ON SEQUENCE chat_messages_id_seq TO lesser_app;

-- ============================================================================
-- Part 17: 默认测试用户 (开发环境)
-- 密码: password123 (bcrypt hash)
-- ============================================================================
DO $$
DECLARE
    test_user1_id UUID;
    test_user2_id UUID;
BEGIN
    -- 测试用户 1: alice
    IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'alice') THEN
        INSERT INTO users (username, email, password, display_name, bio, is_active, is_verified)
        VALUES (
            'alice',
            'alice@test.com',
            '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
            'Alice Test',
            '测试用户 Alice，用于开发调试',
            true,
            true
        ) RETURNING id INTO test_user1_id;
        RAISE NOTICE '创建测试用户: alice (id: %)', test_user1_id;
    ELSE
        RAISE NOTICE '测试用户 alice 已存在';
    END IF;

    -- 测试用户 2: bob
    IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'bob') THEN
        INSERT INTO users (username, email, password, display_name, bio, is_active, is_verified)
        VALUES (
            'bob',
            'bob@test.com',
            '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
            'Bob Test',
            '测试用户 Bob，用于开发调试',
            true,
            true
        ) RETURNING id INTO test_user2_id;
        RAISE NOTICE '创建测试用户: bob (id: %)', test_user2_id;
    ELSE
        RAISE NOTICE '测试用户 bob 已存在';
    END IF;
END
$$;

-- ============================================================================
-- Part 18: 默认超级管理员
-- 用户名: funcdfs, 密码: fw142857 (占位符，服务启动时更新)
-- ============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM superusers WHERE username = 'funcdfs') THEN
        INSERT INTO superusers (username, email, password, display_name, is_active)
        VALUES (
            'funcdfs',
            'funcdfs@gmail.com',
            '$placeholder$',
            'funcdfs',
            true
        );
        RAISE NOTICE '创建默认超级管理员: funcdfs';
    ELSE
        RAISE NOTICE '超级管理员 funcdfs 已存在';
    END IF;
END
$$;

-- ============================================================================
-- 初始化完成
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'PostgreSQL 数据库初始化完成';
    RAISE NOTICE '- 扩展: uuid-ossp, pg_trgm, vector, pg_stat_statements';
    RAISE NOTICE '- 测试用户: alice/password123, bob/password123';
    RAISE NOTICE '- 超级管理员: funcdfs/fw142857';
    RAISE NOTICE '========================================';
END
$$;
