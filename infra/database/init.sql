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

-- ============================================================================
-- 3. 创建 Users 表 (User Service 使用)
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

-- 用户表索引
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_display_name ON users(display_name);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_users_is_private ON users(is_private);

-- Grant privileges
GRANT ALL PRIVILEGES ON TABLE users TO lesser_app;

-- ============================================================================
-- 4. 关注关系表
-- ============================================================================
CREATE TABLE IF NOT EXISTS follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- 防止重复关注
    CONSTRAINT unique_follow UNIQUE (follower_id, following_id),
    -- 防止自己关注自己
    CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

-- 关注关系索引
CREATE INDEX IF NOT EXISTS idx_follows_follower_id ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id ON follows(following_id);
CREATE INDEX IF NOT EXISTS idx_follows_created_at ON follows(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_follows_mutual ON follows(follower_id, following_id);

GRANT ALL PRIVILEGES ON TABLE follows TO lesser_app;

-- ============================================================================
-- 5. 屏蔽关系表
-- ============================================================================
-- block_type: 1=HIDE_POSTS(不看他), 2=HIDE_ME(不让他看我), 3=BLOCK(拉黑)
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

-- 屏蔽关系索引
CREATE INDEX IF NOT EXISTS idx_blocks_blocker_id ON blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocks_blocked_id ON blocks(blocked_id);
CREATE INDEX IF NOT EXISTS idx_blocks_type ON blocks(block_type);
CREATE INDEX IF NOT EXISTS idx_blocks_created_at ON blocks(created_at DESC);

GRANT ALL PRIVILEGES ON TABLE blocks TO lesser_app;

-- ============================================================================
-- 6. 用户隐私设置表
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

-- ============================================================================
-- 7. 用户通知设置表
-- ============================================================================
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

-- ============================================================================
-- 8. 关注请求表（私密账户审批用）
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

-- ============================================================================
-- 9. 触发器：自动更新 updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 用户表触发器
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 隐私设置表触发器
DROP TRIGGER IF EXISTS update_user_privacy_settings_updated_at ON user_privacy_settings;
CREATE TRIGGER update_user_privacy_settings_updated_at
    BEFORE UPDATE ON user_privacy_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 通知设置表触发器
DROP TRIGGER IF EXISTS update_user_notification_settings_updated_at ON user_notification_settings;
CREATE TRIGGER update_user_notification_settings_updated_at
    BEFORE UPDATE ON user_notification_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 关注请求表触发器
DROP TRIGGER IF EXISTS update_follow_requests_updated_at ON follow_requests;
CREATE TRIGGER update_follow_requests_updated_at
    BEFORE UPDATE ON follow_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 10. Contents 表 (Content Service 使用)
-- ============================================================================
-- 内容类型: 1=STORY(24h过期), 2=SHORT(短文本), 3=ARTICLE(长文章)
-- 内容状态: 1=DRAFT(草稿), 2=PUBLISHED(已发布), 3=ARCHIVED(已归档), 4=DELETED(已删除)
CREATE TABLE IF NOT EXISTS contents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type SMALLINT NOT NULL DEFAULT 2,
    status SMALLINT NOT NULL DEFAULT 2,
    
    -- 内容字段
    title VARCHAR(500),
    text TEXT NOT NULL DEFAULT '',
    summary TEXT,
    media_urls TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    
    -- 引用关系
    reply_to_id UUID REFERENCES contents(id) ON DELETE SET NULL,
    quote_id UUID REFERENCES contents(id) ON DELETE SET NULL,
    
    -- 统计数据
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    repost_count INTEGER DEFAULT 0,
    bookmark_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    
    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    published_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- 元数据
    is_pinned BOOLEAN DEFAULT false,
    comments_disabled BOOLEAN DEFAULT false,
    language VARCHAR(10),
    
    -- 约束
    CONSTRAINT valid_content_type CHECK (type IN (1, 2, 3)),
    CONSTRAINT valid_content_status CHECK (status IN (1, 2, 3, 4))
);

-- Contents 表索引
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

-- Contents 表触发器
DROP TRIGGER IF EXISTS update_contents_updated_at ON contents;
CREATE TRIGGER update_contents_updated_at
    BEFORE UPDATE ON contents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

GRANT ALL PRIVILEGES ON TABLE contents TO lesser_app;

-- ============================================================================
-- 11. Likes 表 (Feed Service 使用)
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

-- ============================================================================
-- 12. Bookmarks 表 (Feed Service 使用)
-- ============================================================================
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

-- ============================================================================
-- 13. Reposts 表 (Feed Service 使用)
-- ============================================================================
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
-- 日志
-- ============================================================================
DO $
BEGIN
    RAISE NOTICE 'User service tables initialization completed';
    RAISE NOTICE 'Content service tables initialization completed';
    RAISE NOTICE 'Feed service tables initialization completed';
END
$;

-- ============================================================================
-- 14. Feed 流优化索引
-- ============================================================================
-- 优化关注用户 Feed 流查询：按作者和发布时间排序
CREATE INDEX IF NOT EXISTS idx_contents_feed_timeline 
    ON contents(author_id, published_at DESC NULLS LAST, created_at DESC) 
    WHERE status = 2 AND (expires_at IS NULL OR expires_at > NOW());

-- 优化用户主页 Feed 查询：置顶优先，然后按发布时间
CREATE INDEX IF NOT EXISTS idx_contents_user_feed 
    ON contents(author_id, is_pinned DESC, published_at DESC NULLS LAST) 
    WHERE status = 2;

DO $
BEGIN
    RAISE NOTICE 'Feed timeline indexes created';
END
$;

-- ============================================================================
-- 15. Comments 表 (Comment Service 使用)
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

-- Comments 表索引
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author_id ON comments(author_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON comments(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_like_count ON comments(like_count DESC);
CREATE INDEX IF NOT EXISTS idx_comments_post_parent ON comments(post_id, parent_id) WHERE is_deleted = false;
-- 复合索引：支持热门排序
CREATE INDEX IF NOT EXISTS idx_comments_post_hot ON comments(post_id, like_count DESC, created_at DESC) WHERE is_deleted = false AND parent_id IS NULL;

-- Comments 表触发器
DROP TRIGGER IF EXISTS update_comments_updated_at ON comments;
CREATE TRIGGER update_comments_updated_at
    BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

GRANT ALL PRIVILEGES ON TABLE comments TO lesser_app;

-- ============================================================================
-- 16. Comment Likes 表 (评论点赞)
-- ============================================================================
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

DO $
BEGIN
    RAISE NOTICE 'Comments and Comment Likes tables created';
END
$;

-- ============================================================================
-- 17. Notifications 表 (Notification Service 使用)
-- ============================================================================
-- 通知类型: 1=LIKE, 2=COMMENT, 3=REPLY, 4=BOOKMARK, 5=MENTION, 6=FOLLOW, 7=REPOST
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
    
    -- 约束
    CONSTRAINT valid_notification_type CHECK (type IN (1, 2, 3, 4, 5, 6, 7))
);

-- Notifications 表索引
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_actor_id ON notifications(actor_id) WHERE actor_id IS NOT NULL;

GRANT ALL PRIVILEGES ON TABLE notifications TO lesser_app;

DO $
BEGIN
    RAISE NOTICE 'Notifications table created';
END
$;

-- ============================================================================
-- 18. User Bans 表 (Auth Service 使用)
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_bans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    banned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    operator_id UUID REFERENCES users(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Bans 表索引
CREATE INDEX IF NOT EXISTS idx_user_bans_user_id ON user_bans(user_id);
CREATE INDEX IF NOT EXISTS idx_user_bans_active ON user_bans(user_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_user_bans_expires ON user_bans(expires_at) WHERE expires_at IS NOT NULL AND is_active = true;
-- 唯一约束：每个用户只能有一条活跃的封禁记录
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_bans_user_active_unique ON user_bans(user_id) WHERE is_active = true;

-- User Bans 表触发器
DROP TRIGGER IF EXISTS update_user_bans_updated_at ON user_bans;
CREATE TRIGGER update_user_bans_updated_at
    BEFORE UPDATE ON user_bans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

GRANT ALL PRIVILEGES ON TABLE user_bans TO lesser_app;

DO $
BEGIN
    RAISE NOTICE 'User Bans table created';
END
$;
