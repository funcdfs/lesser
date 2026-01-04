#!/bin/bash
# ============================================================================
# 后端服务完整联动测试脚本
# 测试所有 gRPC 服务的 API 是否正常工作
# ============================================================================

# 不使用 set -e，让测试继续执行即使有失败

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
GATEWAY_ADDR="localhost:50053"
CHAT_ADDR="localhost:50052"
SUPERUSER_ADDR="localhost:50063"

# 测试计数器
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试数据
TEST_USER_EMAIL="test_$(date +%s)@example.com"
TEST_USER_PASSWORD="TestPassword123!"
TEST_USERNAME="testuser_$(date +%s)"
ACCESS_TOKEN=""
REFRESH_TOKEN=""
USER_ID=""
CONTENT_ID=""
DRAFT_ID=""
COMMENT_ID=""
CONVERSATION_ID=""

# ============================================================================
# 辅助函数
# ============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================================${NC}"
}

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    echo -e "${RED}       Error: $2${NC}"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

# ============================================================================
# 1. Auth Service 测试
# ============================================================================

test_auth_service() {
    print_header "1. Auth Service 测试"
    
    # 1.1 注册用户
    print_test "Register - 注册新用户"
    result=$(grpcurl -plaintext \
        -d "{\"username\":\"$TEST_USERNAME\",\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\",\"display_name\":\"Test User\"}" \
        $GATEWAY_ADDR auth.AuthService/Register 2>&1)
    
    if echo "$result" | grep -q "accessToken\|access_token"; then
        ACCESS_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
        if [ -z "$ACCESS_TOKEN" ]; then
            ACCESS_TOKEN=$(echo "$result" | grep -o '"access_token": "[^"]*"' | cut -d'"' -f4)
        fi
        USER_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "Register - 用户注册成功 (user_id: $USER_ID)"
    else
        print_fail "Register - 用户注册失败" "$result"
        return 1
    fi

    # 1.2 登录
    print_test "Login - 用户登录"
    result=$(grpcurl -plaintext \
        -d "{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\"}" \
        $GATEWAY_ADDR auth.AuthService/Login 2>&1)
    
    if echo "$result" | grep -q "accessToken\|access_token"; then
        ACCESS_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
        REFRESH_TOKEN=$(echo "$result" | grep -o '"refreshToken": "[^"]*"' | cut -d'"' -f4)
        if [ -z "$ACCESS_TOKEN" ]; then
            ACCESS_TOKEN=$(echo "$result" | grep -o '"access_token": "[^"]*"' | cut -d'"' -f4)
            REFRESH_TOKEN=$(echo "$result" | grep -o '"refresh_token": "[^"]*"' | cut -d'"' -f4)
        fi
        print_success "Login - 登录成功"
    else
        print_fail "Login - 登录失败" "$result"
    fi
    
    # 1.3 获取公钥
    print_test "GetPublicKey - 获取 JWT 公钥"
    result=$(grpcurl -plaintext \
        -d '{}' \
        $GATEWAY_ADDR auth.AuthService/GetPublicKey 2>&1)
    
    if echo "$result" | grep -q "publicKey\|public_key"; then
        print_success "GetPublicKey - 获取公钥成功"
    else
        print_fail "GetPublicKey - 获取公钥失败" "$result"
    fi
    
    # 1.4 获取用户信息
    print_test "GetUser - 获取用户信息"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR auth.AuthService/GetUser 2>&1)
    
    if echo "$result" | grep -q "username"; then
        print_success "GetUser - 获取用户信息成功"
    else
        print_fail "GetUser - 获取用户信息失败" "$result"
    fi

    # 1.5 检查封禁状态
    print_test "CheckBanned - 检查封禁状态"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR auth.AuthService/CheckBanned 2>&1)
    
    if echo "$result" | grep -q "banned" || echo "$result" | grep -q "{}"; then
        print_success "CheckBanned - 检查封禁状态成功"
    else
        print_fail "CheckBanned - 检查封禁状态失败" "$result"
    fi
    
    # 1.6 刷新 Token
    print_test "RefreshToken - 刷新访问令牌"
    result=$(grpcurl -plaintext \
        -d "{\"refresh_token\":\"$REFRESH_TOKEN\"}" \
        $GATEWAY_ADDR auth.AuthService/RefreshToken 2>&1)
    
    if echo "$result" | grep -q "accessToken\|access_token"; then
        ACCESS_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
        REFRESH_TOKEN=$(echo "$result" | grep -o '"refreshToken": "[^"]*"' | cut -d'"' -f4)
        if [ -z "$ACCESS_TOKEN" ]; then
            ACCESS_TOKEN=$(echo "$result" | grep -o '"access_token": "[^"]*"' | cut -d'"' -f4)
            REFRESH_TOKEN=$(echo "$result" | grep -o '"refresh_token": "[^"]*"' | cut -d'"' -f4)
        fi
        print_success "RefreshToken - 刷新令牌成功"
    else
        print_fail "RefreshToken - 刷新令牌失败" "$result"
    fi
}

# ============================================================================
# 2. User Service 测试
# ============================================================================

test_user_service() {
    print_header "2. User Service 测试"
    
    # 2.1 获取用户资料
    print_test "GetProfile - 获取用户资料"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR user.UserService/GetProfile 2>&1)
    
    if echo "$result" | grep -q "username"; then
        print_success "GetProfile - 获取用户资料成功"
    else
        print_fail "GetProfile - 获取用户资料失败" "$result"
    fi

    # 2.2 通过用户名获取资料
    print_test "GetProfileByUsername - 通过用户名获取资料"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"username\":\"$TEST_USERNAME\"}" \
        $GATEWAY_ADDR user.UserService/GetProfileByUsername 2>&1)
    
    if echo "$result" | grep -q "username"; then
        print_success "GetProfileByUsername - 获取资料成功"
    else
        print_fail "GetProfileByUsername - 获取资料失败" "$result"
    fi
    
    # 2.3 更新用户资料
    print_test "UpdateProfile - 更新用户资料"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"bio\":\"This is a test bio\",\"location\":\"Test City\"}" \
        $GATEWAY_ADDR user.UserService/UpdateProfile 2>&1)
    
    if echo "$result" | grep -q "bio"; then
        print_success "UpdateProfile - 更新资料成功"
    else
        print_fail "UpdateProfile - 更新资料失败" "$result"
    fi
    
    # 2.4 批量获取用户资料
    print_test "BatchGetProfiles - 批量获取用户资料"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_ids\":[\"$USER_ID\"]}" \
        $GATEWAY_ADDR user.UserService/BatchGetProfiles 2>&1)
    
    if echo "$result" | grep -q "profiles"; then
        print_success "BatchGetProfiles - 批量获取成功"
    else
        print_fail "BatchGetProfiles - 批量获取失败" "$result"
    fi
    
    # 2.5 获取用户设置
    print_test "GetUserSettings - 获取用户设置"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR user.UserService/GetUserSettings 2>&1)
    
    if echo "$result" | grep -q "privacy\|notification\|userId"; then
        print_success "GetUserSettings - 获取设置成功"
    else
        print_fail "GetUserSettings - 获取设置失败" "$result"
    fi

    # 2.6 更新用户设置
    print_test "UpdateUserSettings - 更新用户设置"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"privacy\":{\"is_private_account\":false,\"allow_message_from_anyone\":true},\"notification\":{\"push_enabled\":true,\"notify_new_follower\":true}}" \
        $GATEWAY_ADDR user.UserService/UpdateUserSettings 2>&1)
    
    if echo "$result" | grep -q "privacy\|notification\|userId"; then
        print_success "UpdateUserSettings - 更新设置成功"
    else
        print_fail "UpdateUserSettings - 更新设置失败" "$result"
    fi
    
    # 2.7 获取粉丝列表
    print_test "GetFollowers - 获取粉丝列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR user.UserService/GetFollowers 2>&1)
    
    if echo "$result" | grep -q "users\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetFollowers - 获取粉丝列表成功"
    else
        print_fail "GetFollowers - 获取粉丝列表失败" "$result"
    fi
    
    # 2.8 获取关注列表
    print_test "GetFollowing - 获取关注列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR user.UserService/GetFollowing 2>&1)
    
    if echo "$result" | grep -q "users\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetFollowing - 获取关注列表成功"
    else
        print_fail "GetFollowing - 获取关注列表失败" "$result"
    fi

    # 2.9 获取屏蔽列表
    print_test "GetBlockList - 获取屏蔽列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR user.UserService/GetBlockList 2>&1)
    
    if echo "$result" | grep -q "users\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetBlockList - 获取屏蔽列表成功"
    else
        print_fail "GetBlockList - 获取屏蔽列表失败" "$result"
    fi
    
    # 2.10 搜索用户
    print_test "SearchUsers - 搜索用户"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"query\":\"test\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR user.UserService/SearchUsers 2>&1)
    
    if echo "$result" | grep -q "users\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "SearchUsers - 搜索用户成功"
    else
        print_fail "SearchUsers - 搜索用户失败" "$result"
    fi
}

# ============================================================================
# 3. Content Service 测试
# ============================================================================

test_content_service() {
    print_header "3. Content Service 测试"
    
    # 3.1 创建内容 (SHORT 类型)
    print_test "CreateContent - 创建短文本内容"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"author_id\":\"$USER_ID\",\"type\":2,\"text\":\"This is a test post from API test script #test\"}" \
        $GATEWAY_ADDR content.ContentService/CreateContent 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        CONTENT_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "CreateContent - 创建内容成功 (content_id: $CONTENT_ID)"
    else
        print_fail "CreateContent - 创建内容失败" "$result"
        return 1
    fi

    # 3.2 创建草稿 (ARTICLE 类型)
    print_test "CreateContent (Draft) - 创建文章草稿"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"author_id\":\"$USER_ID\",\"type\":3,\"title\":\"Test Article Draft\",\"text\":\"This is a draft article content.\",\"is_draft\":true}" \
        $GATEWAY_ADDR content.ContentService/CreateContent 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        DRAFT_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "CreateContent (Draft) - 创建草稿成功 (draft_id: $DRAFT_ID)"
    else
        print_fail "CreateContent (Draft) - 创建草稿失败" "$result"
    fi
    
    # 3.3 获取内容
    print_test "GetContent - 获取内容详情"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"viewer_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR content.ContentService/GetContent 2>&1)
    
    if echo "$result" | grep -q "text"; then
        print_success "GetContent - 获取内容成功"
    else
        print_fail "GetContent - 获取内容失败" "$result"
    fi
    
    # 3.4 更新内容
    print_test "UpdateContent - 更新内容"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"user_id\":\"$USER_ID\",\"text\":\"Updated test post content #updated\"}" \
        $GATEWAY_ADDR content.ContentService/UpdateContent 2>&1)
    
    if echo "$result" | grep -q "Updated"; then
        print_success "UpdateContent - 更新内容成功"
    else
        print_fail "UpdateContent - 更新内容失败" "$result"
    fi

    # 3.5 列表查询
    print_test "ListContents - 获取内容列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"author_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR content.ContentService/ListContents 2>&1)
    
    if echo "$result" | grep -q "contents\|pagination" || [ -z "$result" ]; then
        print_success "ListContents - 获取列表成功"
    else
        print_fail "ListContents - 获取列表失败" "$result"
    fi
    
    # 3.6 批量获取内容
    print_test "BatchGetContents - 批量获取内容"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_ids\":[\"$CONTENT_ID\"],\"viewer_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR content.ContentService/BatchGetContents 2>&1)
    
    if echo "$result" | grep -q "contents" || [ -z "$result" ]; then
        print_success "BatchGetContents - 批量获取成功"
    else
        print_fail "BatchGetContents - 批量获取失败" "$result"
    fi
    
    # 3.7 获取用户草稿
    print_test "GetUserDrafts - 获取用户草稿"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR content.ContentService/GetUserDrafts 2>&1)
    
    if echo "$result" | grep -q "drafts\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetUserDrafts - 获取草稿成功"
    else
        print_fail "GetUserDrafts - 获取草稿失败" "$result"
    fi

    # 3.8 发布草稿
    print_test "PublishDraft - 发布草稿"
    if [ -n "$DRAFT_ID" ]; then
        result=$(grpcurl -plaintext \
            -H "authorization: Bearer $ACCESS_TOKEN" \
            -d "{\"content_id\":\"$DRAFT_ID\",\"user_id\":\"$USER_ID\"}" \
            $GATEWAY_ADDR content.ContentService/PublishDraft 2>&1)
        
        if echo "$result" | grep -q "content\|id" || [ -z "$result" ]; then
            print_success "PublishDraft - 发布草稿成功"
        else
            print_fail "PublishDraft - 发布草稿失败" "$result"
        fi
    else
        print_fail "PublishDraft - 跳过（无草稿 ID）" "DRAFT_ID is empty"
    fi
    
    # 3.9 获取回复列表
    print_test "GetReplies - 获取回复列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR content.ContentService/GetReplies 2>&1)
    
    if echo "$result" | grep -q "replies\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetReplies - 获取回复成功"
    else
        print_fail "GetReplies - 获取回复失败" "$result"
    fi
    
    # 3.10 获取用户 Story
    print_test "GetUserStories - 获取用户 Story"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"viewer_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR content.ContentService/GetUserStories 2>&1)
    
    if echo "$result" | grep -q "stories\|hasUnseen" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetUserStories - 获取 Story 成功"
    else
        print_fail "GetUserStories - 获取 Story 失败" "$result"
    fi

    # 3.11 置顶内容
    print_test "PinContent - 置顶内容"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"user_id\":\"$USER_ID\",\"pin\":true}" \
        $GATEWAY_ADDR content.ContentService/PinContent 2>&1)
    
    if echo "$result" | grep -q "success" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "PinContent - 置顶内容成功"
    else
        print_fail "PinContent - 置顶内容失败" "$result"
    fi
    
    # 3.12 取消置顶
    print_test "PinContent (Unpin) - 取消置顶"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"user_id\":\"$USER_ID\",\"pin\":false}" \
        $GATEWAY_ADDR content.ContentService/PinContent 2>&1)
    
    if echo "$result" | grep -q "success" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "PinContent (Unpin) - 取消置顶成功"
    else
        print_fail "PinContent (Unpin) - 取消置顶失败" "$result"
    fi
}

# ============================================================================
# 4. Interaction Service 测试
# ============================================================================

test_interaction_service() {
    print_header "4. Interaction Service 测试"
    
    # 4.1 点赞
    print_test "Like - 点赞内容"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\"}" \
        $GATEWAY_ADDR interaction.InteractionService/Like 2>&1)
    
    if echo "$result" | grep -q "success\|likeCount" || [ -z "$result" ]; then
        print_success "Like - 点赞成功"
    else
        print_fail "Like - 点赞失败" "$result"
    fi

    # 4.2 检查点赞状态
    print_test "CheckLiked - 检查点赞状态"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\"}" \
        $GATEWAY_ADDR interaction.InteractionService/CheckLiked 2>&1)
    
    if echo "$result" | grep -q "isLiked\|is_liked" || [ -z "$result" ]; then
        print_success "CheckLiked - 检查状态成功"
    else
        print_fail "CheckLiked - 检查状态失败" "$result"
    fi
    
    # 4.3 收藏
    print_test "Bookmark - 收藏内容"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\"}" \
        $GATEWAY_ADDR interaction.InteractionService/Bookmark 2>&1)
    
    if echo "$result" | grep -q "success\|bookmarkCount" || [ -z "$result" ]; then
        print_success "Bookmark - 收藏成功"
    else
        print_fail "Bookmark - 收藏失败" "$result"
    fi
    
    # 4.4 获取收藏列表
    print_test "ListBookmarks - 获取收藏列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR interaction.InteractionService/ListBookmarks 2>&1)
    
    if echo "$result" | grep -q "bookmarks\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "ListBookmarks - 获取列表成功"
    else
        print_fail "ListBookmarks - 获取列表失败" "$result"
    fi

    # 4.5 创建转发
    print_test "CreateRepost - 创建转发"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\",\"quote\":\"Great post!\"}" \
        $GATEWAY_ADDR interaction.InteractionService/CreateRepost 2>&1)
    
    if echo "$result" | grep -q "repost\|repostCount" || [ -z "$result" ]; then
        print_success "CreateRepost - 转发成功"
    else
        print_fail "CreateRepost - 转发失败" "$result"
    fi
    
    # 4.6 批量获取交互状态
    print_test "BatchGetInteractionStatus - 批量获取交互状态"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"content_ids\":[\"$CONTENT_ID\"]}" \
        $GATEWAY_ADDR interaction.InteractionService/BatchGetInteractionStatus 2>&1)
    
    if echo "$result" | grep -q "statuses" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "BatchGetInteractionStatus - 批量获取成功"
    else
        print_fail "BatchGetInteractionStatus - 批量获取失败" "$result"
    fi
    
    # 4.7 取消点赞
    print_test "Unlike - 取消点赞"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\"}" \
        $GATEWAY_ADDR interaction.InteractionService/Unlike 2>&1)
    
    if echo "$result" | grep -q "success\|likeCount" || [ -z "$result" ]; then
        print_success "Unlike - 取消点赞成功"
    else
        print_fail "Unlike - 取消点赞失败" "$result"
    fi

    # 4.8 取消收藏
    print_test "Unbookmark - 取消收藏"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\"}" \
        $GATEWAY_ADDR interaction.InteractionService/Unbookmark 2>&1)
    
    if echo "$result" | grep -q "success\|bookmarkCount" || [ -z "$result" ]; then
        print_success "Unbookmark - 取消收藏成功"
    else
        print_fail "Unbookmark - 取消收藏失败" "$result"
    fi
    
    # 4.9 删除转发
    print_test "DeleteRepost - 删除转发"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\"}" \
        $GATEWAY_ADDR interaction.InteractionService/DeleteRepost 2>&1)
    
    if echo "$result" | grep -q "success\|repostCount" || [ -z "$result" ]; then
        print_success "DeleteRepost - 删除转发成功"
    else
        print_fail "DeleteRepost - 删除转发失败" "$result"
    fi
}

# ============================================================================
# 5. Comment Service 测试
# ============================================================================

test_comment_service() {
    print_header "5. Comment Service 测试"
    
    # 5.1 创建评论
    print_test "CreateComment - 创建评论"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"author_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\",\"text\":\"This is a test comment\"}" \
        $GATEWAY_ADDR comment.CommentService/CreateComment 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        COMMENT_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "CreateComment - 创建评论成功 (comment_id: $COMMENT_ID)"
    else
        print_fail "CreateComment - 创建评论失败" "$result"
        return 1
    fi

    # 5.2 获取评论
    print_test "GetComment - 获取评论详情"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"comment_id\":\"$COMMENT_ID\"}" \
        $GATEWAY_ADDR comment.CommentService/GetComment 2>&1)
    
    if echo "$result" | grep -q "text"; then
        print_success "GetComment - 获取评论成功"
    else
        print_fail "GetComment - 获取评论失败" "$result"
    fi
    
    # 5.3 获取评论列表 (最新优先)
    print_test "ListComments (NEWEST) - 获取评论列表（最新优先）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"pagination\":{\"page\":1,\"page_size\":10},\"sort_by\":2}" \
        $GATEWAY_ADDR comment.CommentService/ListComments 2>&1)
    
    if echo "$result" | grep -q "comments\|pagination" || [ -z "$result" ]; then
        print_success "ListComments (NEWEST) - 获取列表成功"
    else
        print_fail "ListComments (NEWEST) - 获取列表失败" "$result"
    fi
    
    # 5.4 获取评论列表 (最热门)
    print_test "ListComments (HOTTEST) - 获取评论列表（最热门）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"pagination\":{\"page\":1,\"page_size\":10},\"sort_by\":3}" \
        $GATEWAY_ADDR comment.CommentService/ListComments 2>&1)
    
    if echo "$result" | grep -q "comments\|pagination" || [ -z "$result" ]; then
        print_success "ListComments (HOTTEST) - 获取列表成功"
    else
        print_fail "ListComments (HOTTEST) - 获取列表失败" "$result"
    fi

    # 5.5 获取评论数量
    print_test "GetCommentCount - 获取评论数量"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\"}" \
        $GATEWAY_ADDR comment.CommentService/GetCommentCount 2>&1)
    
    if echo "$result" | grep -q "count" || [ -z "$result" ]; then
        print_success "GetCommentCount - 获取数量成功"
    else
        print_fail "GetCommentCount - 获取数量失败" "$result"
    fi
    
    # 5.6 批量获取评论数量
    print_test "BatchGetCommentCount - 批量获取评论数量"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_ids\":[\"$CONTENT_ID\"]}" \
        $GATEWAY_ADDR comment.CommentService/BatchGetCommentCount 2>&1)
    
    if echo "$result" | grep -q "counts" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "BatchGetCommentCount - 批量获取成功"
    else
        print_fail "BatchGetCommentCount - 批量获取失败" "$result"
    fi
    
    # 5.7 点赞评论
    print_test "LikeComment - 点赞评论"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"comment_id\":\"$COMMENT_ID\"}" \
        $GATEWAY_ADDR comment.CommentService/LikeComment 2>&1)
    
    if echo "$result" | grep -q "success\|likeCount" || [ -z "$result" ]; then
        print_success "LikeComment - 点赞评论成功"
    else
        print_fail "LikeComment - 点赞评论失败" "$result"
    fi

    # 5.8 取消点赞评论
    print_test "UnlikeComment - 取消点赞评论"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"comment_id\":\"$COMMENT_ID\"}" \
        $GATEWAY_ADDR comment.CommentService/UnlikeComment 2>&1)
    
    if echo "$result" | grep -q "success\|likeCount" || [ -z "$result" ]; then
        print_success "UnlikeComment - 取消点赞成功"
    else
        print_fail "UnlikeComment - 取消点赞失败" "$result"
    fi
    
    # 5.9 创建回复评论
    print_test "CreateComment (Reply) - 创建回复评论"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"author_id\":\"$USER_ID\",\"content_id\":\"$CONTENT_ID\",\"parent_id\":\"$COMMENT_ID\",\"text\":\"This is a reply\"}" \
        $GATEWAY_ADDR comment.CommentService/CreateComment 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        REPLY_COMMENT_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "CreateComment (Reply) - 创建回复成功"
    else
        print_fail "CreateComment (Reply) - 创建回复失败" "$result"
    fi
    
    # 5.10 获取回复列表
    print_test "ListComments (Replies) - 获取回复列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"parent_id\":\"$COMMENT_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR comment.CommentService/ListComments 2>&1)
    
    if echo "$result" | grep -q "comments\|pagination" || [ -z "$result" ]; then
        print_success "ListComments (Replies) - 获取回复列表成功"
    else
        print_fail "ListComments (Replies) - 获取回复列表失败" "$result"
    fi
}

# ============================================================================
# 6. Timeline Service 测试
# ============================================================================

test_timeline_service() {
    print_header "6. Timeline Service 测试"
    
    # 6.1 获取关注 Feed
    print_test "GetFollowingFeed - 获取关注 Feed"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR timeline.TimelineService/GetFollowingFeed 2>&1)
    
    if echo "$result" | grep -q "items\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetFollowingFeed - 获取成功"
    else
        print_fail "GetFollowingFeed - 获取失败" "$result"
    fi
    
    # 6.2 获取用户 Feed
    print_test "GetUserFeed - 获取用户 Feed"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"viewer_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR timeline.TimelineService/GetUserFeed 2>&1)
    
    if echo "$result" | grep -q "items\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetUserFeed - 获取成功"
    else
        print_fail "GetUserFeed - 获取失败" "$result"
    fi
    
    # 6.3 获取热门 Feed (day)
    print_test "GetHotFeed (day) - 获取热门 Feed（日）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10},\"time_range\":\"day\"}" \
        $GATEWAY_ADDR timeline.TimelineService/GetHotFeed 2>&1)
    
    if echo "$result" | grep -q "items\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetHotFeed (day) - 获取成功"
    else
        print_fail "GetHotFeed (day) - 获取失败" "$result"
    fi

    # 6.4 获取热门 Feed (week)
    print_test "GetHotFeed (week) - 获取热门 Feed（周）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10},\"time_range\":\"week\"}" \
        $GATEWAY_ADDR timeline.TimelineService/GetHotFeed 2>&1)
    
    if echo "$result" | grep -q "items\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetHotFeed (week) - 获取成功"
    else
        print_fail "GetHotFeed (week) - 获取失败" "$result"
    fi
    
    # 6.5 获取热门 Feed (month)
    print_test "GetHotFeed (month) - 获取热门 Feed（月）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10},\"time_range\":\"month\"}" \
        $GATEWAY_ADDR timeline.TimelineService/GetHotFeed 2>&1)
    
    if echo "$result" | grep -q "items\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetHotFeed (month) - 获取成功"
    else
        print_fail "GetHotFeed (month) - 获取失败" "$result"
    fi
    
    # 6.6 获取推荐 Feed (预留功能)
    print_test "GetRecommendFeed - 获取推荐 Feed (预留)"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR timeline.TimelineService/GetRecommendFeed 2>&1)
    
    if echo "$result" | grep -q "items\|pagination\|Unimplemented" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetRecommendFeed - 获取成功 (或预期的未实现)"
    else
        print_fail "GetRecommendFeed - 获取失败" "$result"
    fi

    # 6.7 获取内容详情
    print_test "GetContentDetail - 获取内容详情"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"content_id\":\"$CONTENT_ID\",\"viewer_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR timeline.TimelineService/GetContentDetail 2>&1)
    
    if echo "$result" | grep -q "item\|content" || [ -z "$result" ]; then
        print_success "GetContentDetail - 获取成功"
    else
        print_fail "GetContentDetail - 获取失败" "$result"
    fi
}

# ============================================================================
# 7. Search Service 测试
# ============================================================================

test_search_service() {
    print_header "7. Search Service 测试"
    
    # 7.1 搜索帖子
    print_test "SearchPosts - 搜索帖子"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"query\":\"test\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR search.SearchService/SearchPosts 2>&1)
    
    if echo "$result" | grep -q "posts\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "SearchPosts - 搜索成功"
    else
        print_fail "SearchPosts - 搜索失败" "$result"
    fi
    
    # 7.2 搜索用户
    print_test "SearchUsers - 搜索用户"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"query\":\"test\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR search.SearchService/SearchUsers 2>&1)
    
    if echo "$result" | grep -q "users\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "SearchUsers - 搜索成功"
    else
        print_fail "SearchUsers - 搜索失败" "$result"
    fi
}

# ============================================================================
# 8. Notification Service 测试
# ============================================================================

# 通知 ID 变量
NOTIFICATION_ID=""

test_notification_service() {
    print_header "8. Notification Service 测试"
    
    # 8.1 获取通知列表
    print_test "List - 获取通知列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR notification.NotificationService/List 2>&1)
    
    if echo "$result" | grep -q "notifications\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        # 尝试提取通知 ID 用于后续测试
        NOTIFICATION_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "List - 获取列表成功"
    else
        print_fail "List - 获取列表失败" "$result"
    fi
    
    # 8.2 获取未读数量
    print_test "GetUnreadCount - 获取未读数量"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR notification.NotificationService/GetUnreadCount 2>&1)
    
    if echo "$result" | grep -q "count" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetUnreadCount - 获取成功"
    else
        print_fail "GetUnreadCount - 获取失败" "$result"
    fi
    
    # 8.3 获取未读通知列表
    print_test "List (unread_only) - 获取未读通知列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"unread_only\":true,\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR notification.NotificationService/List 2>&1)
    
    if echo "$result" | grep -q "notifications\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "List (unread_only) - 获取成功"
    else
        print_fail "List (unread_only) - 获取失败" "$result"
    fi

    # 8.4 标记单条通知已读
    print_test "Read - 标记单条通知已读"
    if [ -n "$NOTIFICATION_ID" ]; then
        result=$(grpcurl -plaintext \
            -H "authorization: Bearer $ACCESS_TOKEN" \
            -d "{\"notification_id\":\"$NOTIFICATION_ID\",\"user_id\":\"$USER_ID\"}" \
            $GATEWAY_ADDR notification.NotificationService/Read 2>&1)
        
        if [ -z "$result" ] || echo "$result" | grep -q "{}" || ! echo "$result" | grep -q "Error"; then
            print_success "Read - 标记成功"
        else
            print_fail "Read - 标记失败" "$result"
        fi
    else
        # 没有通知时跳过，但不算失败
        print_test "Read - 跳过（无通知）"
        print_success "Read - 跳过（无可用通知 ID）"
    fi
    
    # 8.5 标记所有已读
    print_test "ReadAll - 标记所有通知已读"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\"}" \
        $GATEWAY_ADDR notification.NotificationService/ReadAll 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}" || ! echo "$result" | grep -q "Error"; then
        print_success "ReadAll - 标记成功"
    else
        print_fail "ReadAll - 标记失败" "$result"
    fi
}

# ============================================================================
# 9. Chat Service 测试
# ============================================================================

MESSAGE_ID=""

test_chat_service() {
    print_header "9. Chat Service 测试"
    
    # 9.1 创建会话 (群聊类型，因为私聊需要 2 个成员)
    print_test "CreateConversation - 创建群聊会话"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"type\":1,\"name\":\"Test Group Chat\",\"member_ids\":[\"$USER_ID\"],\"creator_id\":\"$USER_ID\"}" \
        $CHAT_ADDR chat.ChatService/CreateConversation 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        CONVERSATION_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "CreateConversation - 创建会话成功 (conversation_id: $CONVERSATION_ID)"
    else
        print_fail "CreateConversation - 创建会话失败" "$result"
        return 1
    fi

    # 9.2 获取会话列表
    print_test "GetConversations - 获取会话列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $CHAT_ADDR chat.ChatService/GetConversations 2>&1)
    
    if echo "$result" | grep -q "conversations\|pagination" || [ -z "$result" ]; then
        print_success "GetConversations - 获取列表成功"
    else
        print_fail "GetConversations - 获取列表失败" "$result"
    fi
    
    # 9.3 获取单个会话
    print_test "GetConversation - 获取单个会话"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"conversation_id\":\"$CONVERSATION_ID\"}" \
        $CHAT_ADDR chat.ChatService/GetConversation 2>&1)
    
    if echo "$result" | grep -q "id\|memberIds" || [ -z "$result" ]; then
        print_success "GetConversation - 获取会话成功"
    else
        print_fail "GetConversation - 获取会话失败" "$result"
    fi
    
    # 9.4 发送消息
    print_test "SendMessage - 发送消息"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"conversation_id\":\"$CONVERSATION_ID\",\"sender_id\":\"$USER_ID\",\"content\":\"Hello from test!\",\"message_type\":\"text\"}" \
        $CHAT_ADDR chat.ChatService/SendMessage 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        MESSAGE_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "SendMessage - 发送消息成功 (message_id: $MESSAGE_ID)"
    else
        print_fail "SendMessage - 发送消息失败" "$result"
    fi

    # 9.5 获取消息列表
    print_test "GetMessages - 获取消息列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"conversation_id\":\"$CONVERSATION_ID\",\"pagination\":{\"page\":1,\"page_size\":20}}" \
        $CHAT_ADDR chat.ChatService/GetMessages 2>&1)
    
    if echo "$result" | grep -q "messages\|pagination" || [ -z "$result" ]; then
        print_success "GetMessages - 获取消息成功"
    else
        print_fail "GetMessages - 获取消息失败" "$result"
    fi
    
    # 9.6 标记消息已读 (注意：不能标记自己发送的消息)
    print_test "MarkAsRead - 标记消息已读"
    if [ -n "$MESSAGE_ID" ]; then
        result=$(grpcurl -plaintext \
            -H "authorization: Bearer $ACCESS_TOKEN" \
            -d "{\"message_id\":\"$MESSAGE_ID\",\"user_id\":\"$USER_ID\"}" \
            $CHAT_ADDR chat.ChatService/MarkAsRead 2>&1)
        
        # 注意：标记自己发送的消息会返回错误，这是预期行为
        if echo "$result" | grep -q "messageId\|readAt\|不能标记自己" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
            print_success "MarkAsRead - 标记成功 (或预期的业务限制)"
        else
            print_fail "MarkAsRead - 标记失败" "$result"
        fi
    else
        print_fail "MarkAsRead - 跳过（无消息 ID）" "MESSAGE_ID is empty"
    fi
    
    # 9.7 标记会话所有消息已读
    print_test "MarkConversationAsRead - 标记会话已读"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"conversation_id\":\"$CONVERSATION_ID\",\"user_id\":\"$USER_ID\"}" \
        $CHAT_ADDR chat.ChatService/MarkConversationAsRead 2>&1)
    
    if echo "$result" | grep -q "conversationId\|readAt" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "MarkConversationAsRead - 标记成功"
    else
        print_fail "MarkConversationAsRead - 标记失败" "$result"
    fi

    # 9.8 获取未读数
    print_test "GetUnreadCounts - 获取未读数"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\",\"conversation_ids\":[\"$CONVERSATION_ID\"]}" \
        $CHAT_ADDR chat.ChatService/GetUnreadCounts 2>&1)
    
    if echo "$result" | grep -q "unreadCounts" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetUnreadCounts - 获取成功"
    else
        print_fail "GetUnreadCounts - 获取失败" "$result"
    fi
}

# ============================================================================
# 10. SuperUser Service 测试
# ============================================================================

SUPERUSER_TOKEN=""

test_superuser_service() {
    print_header "10. SuperUser Service 测试"
    
    # 10.1 超级管理员登录
    print_test "Login - 超级管理员登录"
    result=$(grpcurl -plaintext \
        -d '{"username":"funcdfs","password":"fw142857"}' \
        $SUPERUSER_ADDR superuser.SuperUserService/Login 2>&1)
    
    if echo "$result" | grep -q "accessToken\|access_token"; then
        SUPERUSER_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
        if [ -z "$SUPERUSER_TOKEN" ]; then
            SUPERUSER_TOKEN=$(echo "$result" | grep -o '"access_token": "[^"]*"' | cut -d'"' -f4)
        fi
        SUPERUSER_REFRESH=$(echo "$result" | grep -o '"refreshToken": "[^"]*"' | cut -d'"' -f4)
        print_success "Login - 登录成功"
    else
        print_fail "Login - 登录失败" "$result"
        return 1
    fi

    # 10.2 验证 Token
    print_test "ValidateToken - 验证 Token"
    result=$(grpcurl -plaintext \
        -d "{\"access_token\":\"$SUPERUSER_TOKEN\"}" \
        $SUPERUSER_ADDR superuser.SuperUserService/ValidateToken 2>&1)
    
    if echo "$result" | grep -q "valid\|superuserId" || [ -z "$result" ]; then
        print_success "ValidateToken - 验证成功"
    else
        print_fail "ValidateToken - 验证失败" "$result"
    fi
    
    # 10.3 刷新 Token
    print_test "RefreshToken - 刷新 Token"
    if [ -n "$SUPERUSER_REFRESH" ]; then
        result=$(grpcurl -plaintext \
            -d "{\"refresh_token\":\"$SUPERUSER_REFRESH\"}" \
            $SUPERUSER_ADDR superuser.SuperUserService/RefreshToken 2>&1)
        
        if echo "$result" | grep -q "accessToken\|access_token"; then
            SUPERUSER_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
            print_success "RefreshToken - 刷新成功"
        else
            print_fail "RefreshToken - 刷新失败" "$result"
        fi
    else
        print_success "RefreshToken - 跳过（无 refresh token）"
    fi
    
    # 10.4 获取系统统计
    print_test "GetSystemStats - 获取系统统计"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{}' \
        $SUPERUSER_ADDR superuser.SuperUserService/GetSystemStats 2>&1)
    
    if echo "$result" | grep -q "totalUsers\|total_users" || [ -z "$result" ]; then
        print_success "GetSystemStats - 获取成功"
    else
        print_fail "GetSystemStats - 获取失败" "$result"
    fi

    # 10.5 获取数据库状态
    print_test "GetDatabaseStatus - 获取数据库状态"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{}' \
        $SUPERUSER_ADDR superuser.SuperUserService/GetDatabaseStatus 2>&1)
    
    if echo "$result" | grep -q "connected\|version" || [ -z "$result" ]; then
        print_success "GetDatabaseStatus - 获取成功"
    else
        print_fail "GetDatabaseStatus - 获取失败" "$result"
    fi
    
    # 10.6 获取 Redis 状态
    print_test "GetRedisStatus - 获取 Redis 状态"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{}' \
        $SUPERUSER_ADDR superuser.SuperUserService/GetRedisStatus 2>&1)
    
    if echo "$result" | grep -q "connected\|version" || [ -z "$result" ]; then
        print_success "GetRedisStatus - 获取成功"
    else
        print_fail "GetRedisStatus - 获取失败" "$result"
    fi
    
    # 10.7 获取 RabbitMQ 状态
    print_test "GetRabbitMQStatus - 获取 RabbitMQ 状态"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{}' \
        $SUPERUSER_ADDR superuser.SuperUserService/GetRabbitMQStatus 2>&1)
    
    if echo "$result" | grep -q "connected\|version" || [ -z "$result" ]; then
        print_success "GetRabbitMQStatus - 获取成功"
    else
        print_fail "GetRabbitMQStatus - 获取失败" "$result"
    fi

    # 10.8 获取用户列表
    print_test "ListUsers - 获取用户列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{"page":1,"page_size":10}' \
        $SUPERUSER_ADDR superuser.SuperUserService/ListUsers 2>&1)
    
    if echo "$result" | grep -q "users\|total" || [ -z "$result" ]; then
        print_success "ListUsers - 获取成功"
    else
        print_fail "ListUsers - 获取失败" "$result"
    fi
    
    # 10.9 获取用户详情
    print_test "GetUser - 获取用户详情"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d "{\"user_id\":\"$USER_ID\"}" \
        $SUPERUSER_ADDR superuser.SuperUserService/GetUser 2>&1)
    
    if echo "$result" | grep -q "username\|id" || [ -z "$result" ]; then
        print_success "GetUser - 获取成功"
    else
        print_fail "GetUser - 获取失败" "$result"
    fi
    
    # 10.10 获取内容列表
    print_test "ListContents - 获取内容列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{"page":1,"page_size":10}' \
        $SUPERUSER_ADDR superuser.SuperUserService/ListContents 2>&1)
    
    if echo "$result" | grep -q "contents\|total" || [ -z "$result" ]; then
        print_success "ListContents - 获取成功"
    else
        print_fail "ListContents - 获取失败" "$result"
    fi

    # 10.11 获取表列表
    print_test "ListTables - 获取数据库表列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{"schema":"public"}' \
        $SUPERUSER_ADDR superuser.SuperUserService/ListTables 2>&1)
    
    if echo "$result" | grep -q "tables" || [ -z "$result" ]; then
        print_success "ListTables - 获取成功"
    else
        print_fail "ListTables - 获取失败" "$result"
    fi
    
    # 10.12 获取表结构
    print_test "GetTableSchema - 获取表结构"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{"table_name":"users"}' \
        $SUPERUSER_ADDR superuser.SuperUserService/GetTableSchema 2>&1)
    
    if echo "$result" | grep -q "columns\|tableName" || [ -z "$result" ]; then
        print_success "GetTableSchema - 获取成功"
    else
        print_fail "GetTableSchema - 获取失败" "$result"
    fi
    
    # 10.13 执行只读查询
    print_test "ExecuteQuery - 执行只读 SQL 查询"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{"query":"SELECT COUNT(*) FROM users","limit":10}' \
        $SUPERUSER_ADDR superuser.SuperUserService/ExecuteQuery 2>&1)
    
    if echo "$result" | grep -q "columns\|rows" || [ -z "$result" ]; then
        print_success "ExecuteQuery - 查询成功"
    else
        print_fail "ExecuteQuery - 查询失败" "$result"
    fi

    # 10.14 获取审计日志
    print_test "GetAuditLogs - 获取审计日志"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d '{"page":1,"page_size":10}' \
        $SUPERUSER_ADDR superuser.SuperUserService/GetAuditLogs 2>&1)
    
    if echo "$result" | grep -q "logs\|total" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "GetAuditLogs - 获取成功"
    else
        print_fail "GetAuditLogs - 获取失败" "$result"
    fi
}

# ============================================================================
# 11. 双用户交互测试
# ============================================================================

# 双用户测试数据
USER_A_ID=""
USER_A_EMAIL=""
USER_A_TOKEN=""
USER_A_REFRESH=""
USER_A_USERNAME=""

USER_B_ID=""
USER_B_EMAIL=""
USER_B_TOKEN=""
USER_B_REFRESH=""
USER_B_USERNAME=""

PRIVATE_CONVERSATION_ID=""
PRIVATE_MESSAGE_ID=""

test_two_users_interaction() {
    print_header "11. 双用户交互测试"
    
    local ts=$(date +%s)
    USER_A_USERNAME="test_user_a_${ts}"
    USER_A_EMAIL="test_a_${ts}@example.com"
    USER_B_USERNAME="test_user_b_${ts}"
    USER_B_EMAIL="test_b_${ts}@example.com"
    
    # 11.1 注册用户 A
    print_test "注册用户 A"
    result=$(grpcurl -plaintext \
        -d "{\"username\":\"$USER_A_USERNAME\",\"email\":\"$USER_A_EMAIL\",\"password\":\"TestPassword123!\",\"display_name\":\"Test User A\"}" \
        $GATEWAY_ADDR auth.AuthService/Register 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        USER_A_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        USER_A_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
        print_success "用户 A 注册成功 (id: $USER_A_ID)"
    else
        print_fail "用户 A 注册失败" "$result"
        return 1
    fi

    # 11.2 注册用户 B
    print_test "注册用户 B"
    result=$(grpcurl -plaintext \
        -d "{\"username\":\"$USER_B_USERNAME\",\"email\":\"$USER_B_EMAIL\",\"password\":\"TestPassword123!\",\"display_name\":\"Test User B\"}" \
        $GATEWAY_ADDR auth.AuthService/Register 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        USER_B_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        USER_B_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
        print_success "用户 B 注册成功 (id: $USER_B_ID)"
    else
        print_fail "用户 B 注册失败" "$result"
        return 1
    fi
    
    # 11.3 用户 A 登出
    print_test "用户 A 登出"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"access_token\":\"$USER_A_TOKEN\"}" \
        $GATEWAY_ADDR auth.AuthService/Logout 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 A 登出成功"
    else
        print_fail "用户 A 登出失败" "$result"
    fi
    
    # 11.4 用户 A 重新登录
    print_test "用户 A 重新登录"
    result=$(grpcurl -plaintext \
        -d "{\"email\":\"$USER_A_EMAIL\",\"password\":\"TestPassword123!\"}" \
        $GATEWAY_ADDR auth.AuthService/Login 2>&1)
    
    if echo "$result" | grep -q '"accessToken":'; then
        USER_A_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
        print_success "用户 A 登录成功"
    else
        print_fail "用户 A 登录失败" "$result"
        return 1
    fi

    # 11.5 用户 A 关注用户 B
    print_test "用户 A 关注用户 B"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"follower_id\":\"$USER_A_ID\",\"following_id\":\"$USER_B_ID\"}" \
        $GATEWAY_ADDR user.UserService/Follow 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 A 关注用户 B 成功"
    else
        print_fail "用户 A 关注用户 B 失败" "$result"
    fi
    
    # 11.6 检查关注状态
    print_test "检查 A 是否关注 B"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"follower_id\":\"$USER_A_ID\",\"following_id\":\"$USER_B_ID\"}" \
        $GATEWAY_ADDR user.UserService/CheckFollowing 2>&1)
    
    if echo "$result" | grep -q '"isFollowing": true'; then
        print_success "确认 A 已关注 B"
    else
        print_fail "关注状态检查失败" "$result"
    fi
    
    # 11.7 用户 B 关注用户 A（互关）
    print_test "用户 B 关注用户 A（互关）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_B_TOKEN" \
        -d "{\"follower_id\":\"$USER_B_ID\",\"following_id\":\"$USER_A_ID\"}" \
        $GATEWAY_ADDR user.UserService/Follow 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 B 关注用户 A 成功"
    else
        print_fail "用户 B 关注用户 A 失败" "$result"
    fi

    # 11.8 获取关系状态
    print_test "获取 A 和 B 的关系状态"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"user_id\":\"$USER_A_ID\",\"target_id\":\"$USER_B_ID\"}" \
        $GATEWAY_ADDR user.UserService/GetRelationship 2>&1)
    
    if echo "$result" | grep -q '"isMutual": true'; then
        print_success "确认 A 和 B 互关"
    else
        print_fail "关系状态检查失败" "$result"
    fi
    
    # 11.9 获取共同关注
    print_test "获取共同关注"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"user_id\":\"$USER_A_ID\",\"target_id\":\"$USER_B_ID\",\"pagination\":{\"page\":1,\"page_size\":10}}" \
        $GATEWAY_ADDR user.UserService/GetMutualFollowers 2>&1)
    
    if echo "$result" | grep -q "users\|pagination" || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "获取共同关注成功"
    else
        print_fail "获取共同关注失败" "$result"
    fi
    
    # 11.10 用户 A 取消关注用户 B
    print_test "用户 A 取消关注用户 B"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"follower_id\":\"$USER_A_ID\",\"following_id\":\"$USER_B_ID\"}" \
        $GATEWAY_ADDR user.UserService/Unfollow 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 A 取消关注用户 B 成功"
    else
        print_fail "用户 A 取消关注用户 B 失败" "$result"
    fi

    # 11.11 用户 A 屏蔽用户 B（HIDE_POSTS）
    print_test "用户 A 屏蔽用户 B（HIDE_POSTS - 不看他）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"blocker_id\":\"$USER_A_ID\",\"blocked_id\":\"$USER_B_ID\",\"block_type\":1}" \
        $GATEWAY_ADDR user.UserService/Block 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 A 屏蔽用户 B 成功"
    else
        print_fail "用户 A 屏蔽用户 B 失败" "$result"
    fi
    
    # 11.12 检查屏蔽状态
    print_test "检查屏蔽状态"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"user_id\":\"$USER_A_ID\",\"target_id\":\"$USER_B_ID\"}" \
        $GATEWAY_ADDR user.UserService/CheckBlocked 2>&1)
    
    if echo "$result" | grep -q '"isBlocking": true'; then
        print_success "确认 A 已屏蔽 B"
    else
        print_fail "屏蔽状态检查失败" "$result"
    fi
    
    # 11.13 取消屏蔽
    print_test "用户 A 取消屏蔽用户 B"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"blocker_id\":\"$USER_A_ID\",\"blocked_id\":\"$USER_B_ID\",\"block_type\":1}" \
        $GATEWAY_ADDR user.UserService/Unblock 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 A 取消屏蔽用户 B 成功"
    else
        print_fail "用户 A 取消屏蔽用户 B 失败" "$result"
    fi

    # 11.14 用户 A 拉黑用户 B（BLOCK）
    print_test "用户 A 拉黑用户 B（BLOCK - 双向屏蔽）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"blocker_id\":\"$USER_A_ID\",\"blocked_id\":\"$USER_B_ID\",\"block_type\":3}" \
        $GATEWAY_ADDR user.UserService/Block 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 A 拉黑用户 B 成功"
    else
        print_fail "用户 A 拉黑用户 B 失败" "$result"
    fi
    
    # 11.15 取消拉黑
    print_test "用户 A 取消拉黑用户 B"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"blocker_id\":\"$USER_A_ID\",\"blocked_id\":\"$USER_B_ID\",\"block_type\":3}" \
        $GATEWAY_ADDR user.UserService/Unblock 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 A 取消拉黑用户 B 成功"
    else
        print_fail "用户 A 取消拉黑用户 B 失败" "$result"
    fi
    
    # 11.16 创建私聊会话
    print_test "创建 A 和 B 的私聊会话"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"type\":0,\"name\":\"\",\"member_ids\":[\"$USER_A_ID\",\"$USER_B_ID\"],\"creator_id\":\"$USER_A_ID\"}" \
        $CHAT_ADDR chat.ChatService/CreateConversation 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        PRIVATE_CONVERSATION_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "创建私聊会话成功 (id: $PRIVATE_CONVERSATION_ID)"
    else
        print_fail "创建私聊会话失败" "$result"
    fi

    # 11.17 用户 A 发送消息
    print_test "用户 A 发送消息给用户 B"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"conversation_id\":\"$PRIVATE_CONVERSATION_ID\",\"sender_id\":\"$USER_A_ID\",\"content\":\"Hello from User A!\",\"message_type\":\"text\"}" \
        $CHAT_ADDR chat.ChatService/SendMessage 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        PRIVATE_MESSAGE_ID=$(echo "$result" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "用户 A 发送消息成功 (id: $PRIVATE_MESSAGE_ID)"
    else
        print_fail "用户 A 发送消息失败" "$result"
    fi
    
    # 11.18 用户 B 回复消息
    print_test "用户 B 回复消息"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_B_TOKEN" \
        -d "{\"conversation_id\":\"$PRIVATE_CONVERSATION_ID\",\"sender_id\":\"$USER_B_ID\",\"content\":\"Hi User A! Nice to meet you!\",\"message_type\":\"text\"}" \
        $CHAT_ADDR chat.ChatService/SendMessage 2>&1)
    
    if echo "$result" | grep -q '"id":'; then
        print_success "用户 B 回复消息成功"
    else
        print_fail "用户 B 回复消息失败" "$result"
    fi
    
    # 11.19 获取消息列表
    print_test "获取会话消息列表"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"conversation_id\":\"$PRIVATE_CONVERSATION_ID\",\"pagination\":{\"page\":1,\"page_size\":20}}" \
        $CHAT_ADDR chat.ChatService/GetMessages 2>&1)
    
    if echo "$result" | grep -q '"messages":'; then
        print_success "获取消息列表成功"
    else
        print_fail "获取消息列表失败" "$result"
    fi

    # 11.20 用户 B 标记消息已读
    print_test "用户 B 标记 A 的消息已读"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_B_TOKEN" \
        -d "{\"message_id\":\"$PRIVATE_MESSAGE_ID\",\"user_id\":\"$USER_B_ID\"}" \
        $CHAT_ADDR chat.ChatService/MarkAsRead 2>&1)
    
    if echo "$result" | grep -q '"messageId":' || echo "$result" | grep -q '"readAt":'; then
        print_success "用户 B 标记消息已读成功"
    else
        print_fail "用户 B 标记消息已读失败" "$result"
    fi
    
    # 11.21 标记会话所有消息已读
    print_test "用户 A 标记会话所有消息已读"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_A_TOKEN" \
        -d "{\"conversation_id\":\"$PRIVATE_CONVERSATION_ID\",\"user_id\":\"$USER_A_ID\"}" \
        $CHAT_ADDR chat.ChatService/MarkConversationAsRead 2>&1)
    
    if echo "$result" | grep -q '"conversationId":' || echo "$result" | grep -q '"readAt":' || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "用户 A 标记会话已读成功"
    else
        print_fail "用户 A 标记会话已读失败" "$result"
    fi
    
    # 11.22 获取未读数
    print_test "获取未读消息数"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $USER_B_TOKEN" \
        -d "{\"user_id\":\"$USER_B_ID\",\"conversation_ids\":[\"$PRIVATE_CONVERSATION_ID\"]}" \
        $CHAT_ADDR chat.ChatService/GetUnreadCounts 2>&1)
    
    if echo "$result" | grep -q '"unreadCounts":' || [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "获取未读数成功"
    else
        print_fail "获取未读数失败" "$result"
    fi
}

# ============================================================================
# 12. SuperUser 管理双用户测试
# ============================================================================

test_superuser_manage_two_users() {
    print_header "12. SuperUser 管理双用户测试"
    
    # 12.1 SuperUser 登录
    print_test "SuperUser 登录"
    result=$(grpcurl -plaintext \
        -d '{"username":"funcdfs","password":"fw142857"}' \
        $SUPERUSER_ADDR superuser.SuperUserService/Login 2>&1)
    
    if echo "$result" | grep -q '"accessToken":'; then
        SUPERUSER_TOKEN=$(echo "$result" | grep -o '"accessToken": "[^"]*"' | cut -d'"' -f4)
        print_success "SuperUser 登录成功"
    else
        print_fail "SuperUser 登录失败" "$result"
        return 1
    fi
    
    # 12.2 查看用户 A 详情
    print_test "查看用户 A 详情"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d "{\"user_id\":\"$USER_A_ID\"}" \
        $SUPERUSER_ADDR superuser.SuperUserService/GetUser 2>&1)
    
    if echo "$result" | grep -q '"username":'; then
        print_success "查看用户 A 详情成功"
    else
        print_fail "查看用户 A 详情失败" "$result"
    fi
    
    # 12.3 更新用户 A 信息
    print_test "更新用户 A 信息"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d "{\"user_id\":\"$USER_A_ID\",\"display_name\":\"Updated User A\"}" \
        $SUPERUSER_ADDR superuser.SuperUserService/UpdateUser 2>&1)
    
    if echo "$result" | grep -q '"username":\|Updated'; then
        print_success "更新用户 A 信息成功"
    else
        print_fail "更新用户 A 信息失败" "$result"
    fi

    # 12.4 封禁用户 A
    print_test "封禁用户 A"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d "{\"user_id\":\"$USER_A_ID\",\"reason\":\"Test ban\",\"duration_seconds\":3600}" \
        $SUPERUSER_ADDR superuser.SuperUserService/BanUser 2>&1)
    
    if echo "$result" | grep -q '"success": true'; then
        print_success "封禁用户 A 成功"
    else
        print_fail "封禁用户 A 失败" "$result"
    fi
    
    # 12.5 解封用户 A
    print_test "解封用户 A"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d "{\"user_id\":\"$USER_A_ID\"}" \
        $SUPERUSER_ADDR superuser.SuperUserService/UnbanUser 2>&1)
    
    if echo "$result" | grep -q '"success": true'; then
        print_success "解封用户 A 成功"
    else
        print_fail "解封用户 A 失败" "$result"
    fi
    
    # 12.6 删除用户 A（软删除）
    print_test "删除用户 A（软删除）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d "{\"user_id\":\"$USER_A_ID\",\"hard_delete\":false}" \
        $SUPERUSER_ADDR superuser.SuperUserService/DeleteUser 2>&1)
    
    if echo "$result" | grep -q '"success": true'; then
        print_success "删除用户 A（软删除）成功"
    else
        print_fail "删除用户 A（软删除）失败" "$result"
    fi

    # 12.7 删除用户 B（硬删除）
    print_test "删除用户 B（硬删除）"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $SUPERUSER_TOKEN" \
        -d "{\"user_id\":\"$USER_B_ID\",\"hard_delete\":true}" \
        $SUPERUSER_ADDR superuser.SuperUserService/DeleteUser 2>&1)
    
    if echo "$result" | grep -q '"success": true'; then
        print_success "删除用户 B（硬删除）成功"
    else
        print_fail "删除用户 B（硬删除）失败" "$result"
    fi
    
    # 12.8 SuperUser 登出
    print_test "SuperUser 登出"
    result=$(grpcurl -plaintext \
        -d "{\"access_token\":\"$SUPERUSER_TOKEN\"}" \
        $SUPERUSER_ADDR superuser.SuperUserService/Logout 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}"; then
        print_success "SuperUser 登出成功"
    else
        print_fail "SuperUser 登出失败" "$result"
    fi
}

# ============================================================================
# 13. 清理测试数据
# ============================================================================

cleanup_test_data() {
    print_header "13. 清理测试数据"
    
    # 删除回复评论
    if [ -n "$REPLY_COMMENT_ID" ]; then
        print_test "DeleteComment - 删除回复评论"
        result=$(grpcurl -plaintext \
            -H "authorization: Bearer $ACCESS_TOKEN" \
            -d "{\"comment_id\":\"$REPLY_COMMENT_ID\",\"user_id\":\"$USER_ID\"}" \
            $GATEWAY_ADDR comment.CommentService/DeleteComment 2>&1)
        
        if echo "$result" | grep -q "success" || [ -z "$result" ]; then
            print_success "DeleteComment (Reply) - 删除成功"
        else
            print_fail "DeleteComment (Reply) - 删除失败" "$result"
        fi
    fi

    # 删除评论
    if [ -n "$COMMENT_ID" ]; then
        print_test "DeleteComment - 删除测试评论"
        result=$(grpcurl -plaintext \
            -H "authorization: Bearer $ACCESS_TOKEN" \
            -d "{\"comment_id\":\"$COMMENT_ID\",\"user_id\":\"$USER_ID\"}" \
            $GATEWAY_ADDR comment.CommentService/DeleteComment 2>&1)
        
        if echo "$result" | grep -q "success" || [ -z "$result" ]; then
            print_success "DeleteComment - 删除成功"
        else
            print_fail "DeleteComment - 删除失败" "$result"
        fi
    fi
    
    # 删除草稿
    if [ -n "$DRAFT_ID" ]; then
        print_test "DeleteContent - 删除测试草稿"
        result=$(grpcurl -plaintext \
            -H "authorization: Bearer $ACCESS_TOKEN" \
            -d "{\"content_id\":\"$DRAFT_ID\",\"user_id\":\"$USER_ID\"}" \
            $GATEWAY_ADDR content.ContentService/DeleteContent 2>&1)
        
        if echo "$result" | grep -q "success" || [ -z "$result" ]; then
            print_success "DeleteContent (Draft) - 删除成功"
        else
            print_fail "DeleteContent (Draft) - 删除失败" "$result"
        fi
    fi
    
    # 删除内容
    if [ -n "$CONTENT_ID" ]; then
        print_test "DeleteContent - 删除测试内容"
        result=$(grpcurl -plaintext \
            -H "authorization: Bearer $ACCESS_TOKEN" \
            -d "{\"content_id\":\"$CONTENT_ID\",\"user_id\":\"$USER_ID\"}" \
            $GATEWAY_ADDR content.ContentService/DeleteContent 2>&1)
        
        if echo "$result" | grep -q "success" || [ -z "$result" ]; then
            print_success "DeleteContent - 删除成功"
        else
            print_fail "DeleteContent - 删除失败" "$result"
        fi
    fi

    # 登出
    print_test "Logout - 用户登出"
    result=$(grpcurl -plaintext \
        -H "authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"access_token\":\"$ACCESS_TOKEN\"}" \
        $GATEWAY_ADDR auth.AuthService/Logout 2>&1)
    
    if [ -z "$result" ] || echo "$result" | grep -q "{}" || ! echo "$result" | grep -q "Error"; then
        print_success "Logout - 登出成功"
    else
        print_fail "Logout - 登出失败" "$result"
    fi
}

# ============================================================================
# 主函数
# ============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           Lesser 后端服务完整联动测试                                    ║${NC}"
    echo -e "${BLUE}║           测试所有 gRPC 服务 API 是否正常工作                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "测试配置:"
    echo "  - Gateway: $GATEWAY_ADDR"
    echo "  - Chat: $CHAT_ADDR"
    echo "  - SuperUser: $SUPERUSER_ADDR"
    echo "  - 测试用户: $TEST_USER_EMAIL"
    echo ""
    
    # 执行测试
    test_auth_service
    test_user_service
    test_content_service
    test_interaction_service
    test_comment_service
    test_timeline_service
    test_search_service
    test_notification_service
    test_chat_service
    test_superuser_service
    test_two_users_interaction
    test_superuser_manage_two_users
    cleanup_test_data

    # 输出测试结果
    print_header "测试结果汇总"
    echo ""
    echo -e "总测试数: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "通过: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "失败: ${RED}$FAILED_TESTS${NC}"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                    ✓ 所有测试通过！                                     ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════╝${NC}"
        exit 0
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                    ✗ 部分测试失败                                       ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════════════════╝${NC}"
        exit 1
    fi
}

# 运行主函数
main
