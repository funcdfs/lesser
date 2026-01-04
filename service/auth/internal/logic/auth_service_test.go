// Package service 提供 Auth Service 单元测试
package logic

import (
	"context"
	"errors"
	"log/slog"
	"os"
	"testing"
	"time"

	"github.com/funcdfs/lesser/auth/internal/config"
	"github.com/funcdfs/lesser/auth/internal/crypto"
	"github.com/funcdfs/lesser/auth/internal/data_access"
)

// ==================== Mock 实现 ====================

// mockUserRepository 用户仓库 Mock
type mockUserRepository struct {
	users       map[string]*data_access.User
	emailIndex  map[string]string // email -> userID
	usernameIdx map[string]string // username -> userID
}

func newMockUserRepository() *mockUserRepository {
	return &mockUserRepository{
		users:       make(map[string]*data_access.User),
		emailIndex:  make(map[string]string),
		usernameIdx: make(map[string]string),
	}
}

func (m *mockUserRepository) Create(ctx context.Context, user *data_access.User) error {
	if _, exists := m.emailIndex[user.Email]; exists {
		return data_access.ErrUserExists
	}
	if _, exists := m.usernameIdx[user.Username]; exists {
		return data_access.ErrUserExists
	}
	m.users[user.ID] = user
	m.emailIndex[user.Email] = user.ID
	m.usernameIdx[user.Username] = user.ID
	return nil
}

func (m *mockUserRepository) GetByID(ctx context.Context, id string) (*data_access.User, error) {
	user, ok := m.users[id]
	if !ok {
		return nil, data_access.ErrUserNotFound
	}
	return user, nil
}

func (m *mockUserRepository) GetByEmail(ctx context.Context, email string) (*data_access.User, error) {
	id, ok := m.emailIndex[email]
	if !ok {
		return nil, data_access.ErrUserNotFound
	}
	return m.users[id], nil
}

func (m *mockUserRepository) GetByUsername(ctx context.Context, username string) (*data_access.User, error) {
	id, ok := m.usernameIdx[username]
	if !ok {
		return nil, data_access.ErrUserNotFound
	}
	return m.users[id], nil
}

func (m *mockUserRepository) ExistsByEmailOrUsername(ctx context.Context, email, username string) (bool, error) {
	_, emailExists := m.emailIndex[email]
	_, usernameExists := m.usernameIdx[username]
	return emailExists || usernameExists, nil
}

func (m *mockUserRepository) UpdatePassword(ctx context.Context, userID, hashedPassword string) error {
	user, ok := m.users[userID]
	if !ok {
		return data_access.ErrUserNotFound
	}
	user.Password = hashedPassword
	return nil
}

func (m *mockUserRepository) UpdateLastLogin(ctx context.Context, userID string) error {
	user, ok := m.users[userID]
	if !ok {
		return data_access.ErrUserNotFound
	}
	user.UpdatedAt = time.Now()
	return nil
}

// mockBanRepository 封禁仓库 Mock
type mockBanRepository struct {
	bans map[string]*data_access.Ban // userID -> ban
}

func newMockBanRepository() *mockBanRepository {
	return &mockBanRepository{
		bans: make(map[string]*data_access.Ban),
	}
}

func (m *mockBanRepository) Create(ctx context.Context, ban *data_access.Ban) error {
	m.bans[ban.UserID] = ban
	return nil
}

func (m *mockBanRepository) GetByUserID(ctx context.Context, userID string) (*data_access.Ban, error) {
	ban, ok := m.bans[userID]
	if !ok {
		return nil, nil
	}
	return ban, nil
}

func (m *mockBanRepository) Delete(ctx context.Context, userID string) error {
	delete(m.bans, userID)
	return nil
}

func (m *mockBanRepository) IsUserBanned(ctx context.Context, userID string) (bool, *data_access.Ban, error) {
	ban, ok := m.bans[userID]
	if !ok {
		return false, nil, nil
	}
	// 检查是否已过期
	if ban.ExpiresAt != nil && ban.ExpiresAt.Before(time.Now()) {
		delete(m.bans, userID)
		return false, nil, nil
	}
	return true, ban, nil
}

// mockTokenBlacklist Token 黑名单 Mock
type mockTokenBlacklist struct {
	blacklist map[string]time.Time // tokenID -> expiresAt
}

func newMockTokenBlacklist() *mockTokenBlacklist {
	return &mockTokenBlacklist{
		blacklist: make(map[string]time.Time),
	}
}

func (m *mockTokenBlacklist) Add(ctx context.Context, tokenID string, expiresAt time.Time) error {
	m.blacklist[tokenID] = expiresAt
	return nil
}

func (m *mockTokenBlacklist) IsBlacklisted(ctx context.Context, tokenID string) (bool, error) {
	_, ok := m.blacklist[tokenID]
	return ok, nil
}

// ==================== 测试辅助函数 ====================

// createTestAuthService 创建测试用的 AuthService
func createTestAuthService(t *testing.T) (AuthService, *mockUserRepository, *mockBanRepository, *mockTokenBlacklist) {
	t.Helper()

	userRepo := newMockUserRepository()
	banRepo := newMockBanRepository()
	tokenBlacklist := newMockTokenBlacklist()

	// 创建密码哈希器（使用较低参数加速测试）
	passwordHasher := crypto.NewPasswordHasher(&crypto.Argon2Params{
		Memory:      4096,
		Iterations:  1,
		Parallelism: 1,
		SaltLength:  16,
		KeyLength:   32,
	})

	// 创建密码验证器
	passwordValidator := crypto.NewPasswordValidator(8, true, false)

	// 创建 JWT 管理器
	jwtManager, err := crypto.NewJWTManager(crypto.JWTManagerConfig{
		HMACSecret:           "test-secret-key-for-unit-tests",
		KeySize:              2048,
		AccessTokenDuration:  15 * time.Minute,
		RefreshTokenDuration: 7 * 24 * time.Hour,
		KeyRotationInterval:  30 * 24 * time.Hour,
	})
	if err != nil {
		t.Fatalf("创建 JWT 管理器失败: %v", err)
	}

	// 创建配置
	cfg := &config.Config{
		MaxLoginAttempts: 5,
	}

	// 创建日志
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelError}))

	// 创建服务
	svc := NewAuthService(AuthServiceDeps{
		UserRepo:          userRepo,
		BanRepo:           banRepo,
		TokenBlacklist:    tokenBlacklist,
		BanCache:          nil, // 测试中不使用缓存
		LoginAttemptCache: nil, // 测试中不使用登录尝试缓存
		PasswordHasher:    passwordHasher,
		PasswordValidator: passwordValidator,
		JWTManager:        jwtManager,
		Config:            cfg,
		Logger:            logger,
	})

	return svc, userRepo, banRepo, tokenBlacklist
}

// ==================== 注册测试 ====================

func TestRegister_Success(t *testing.T) {
	svc, userRepo, _, _ := createTestAuthService(t)
	ctx := context.Background()

	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 验证返回结果
	if result.User == nil {
		t.Fatal("返回的用户为空")
	}
	if result.User.Username != "testuser" {
		t.Errorf("用户名不匹配: got %s, want testuser", result.User.Username)
	}
	if result.User.Email != "test@example.com" {
		t.Errorf("邮箱不匹配: got %s, want test@example.com", result.User.Email)
	}
	if result.AccessToken == "" {
		t.Error("Access Token 为空")
	}
	if result.RefreshToken == "" {
		t.Error("Refresh Token 为空")
	}

	// 验证用户已保存到仓库
	savedUser, err := userRepo.GetByEmail(ctx, "test@example.com")
	if err != nil {
		t.Fatalf("获取保存的用户失败: %v", err)
	}
	if savedUser.ID != result.User.ID {
		t.Error("保存的用户 ID 不匹配")
	}
}

func TestRegister_DuplicateEmail(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 第一次注册
	_, err := svc.Register(ctx, "user1", "test@example.com", "Password123", "User 1")
	if err != nil {
		t.Fatalf("第一次注册失败: %v", err)
	}

	// 第二次注册相同邮箱
	_, err = svc.Register(ctx, "user2", "test@example.com", "Password456", "User 2")
	if err == nil {
		t.Fatal("重复邮箱注册应该失败")
	}
	if !errors.Is(err, data_access.ErrUserExists) {
		t.Errorf("错误类型不匹配: got %v, want ErrUserExists", err)
	}
}

func TestRegister_DuplicateUsername(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 第一次注册
	_, err := svc.Register(ctx, "testuser", "test1@example.com", "Password123", "User 1")
	if err != nil {
		t.Fatalf("第一次注册失败: %v", err)
	}

	// 第二次注册相同用户名
	_, err = svc.Register(ctx, "testuser", "test2@example.com", "Password456", "User 2")
	if err == nil {
		t.Fatal("重复用户名注册应该失败")
	}
}

func TestRegister_WeakPassword(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 密码太短
	_, err := svc.Register(ctx, "testuser", "test@example.com", "Pass1", "Test User")
	if err == nil {
		t.Fatal("弱密码注册应该失败")
	}
	if !errors.Is(err, ErrPasswordTooWeak) {
		t.Errorf("错误类型不匹配: got %v, want ErrPasswordTooWeak", err)
	}
}

func TestRegister_PasswordWithoutNumber(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 密码没有数字
	_, err := svc.Register(ctx, "testuser", "test@example.com", "PasswordOnly", "Test User")
	if err == nil {
		t.Fatal("没有数字的密码注册应该失败")
	}
}

// ==================== 登录测试 ====================

func TestLogin_Success(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	_, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 登录
	result, err := svc.Login(ctx, "test@example.com", "Password123")
	if err != nil {
		t.Fatalf("登录失败: %v", err)
	}

	if result.User == nil {
		t.Fatal("返回的用户为空")
	}
	if result.User.Email != "test@example.com" {
		t.Errorf("邮箱不匹配: got %s, want test@example.com", result.User.Email)
	}
	if result.AccessToken == "" {
		t.Error("Access Token 为空")
	}
	if result.RefreshToken == "" {
		t.Error("Refresh Token 为空")
	}
}

func TestLogin_WrongPassword(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	_, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 使用错误密码登录
	_, err = svc.Login(ctx, "test@example.com", "WrongPassword123")
	if err == nil {
		t.Fatal("错误密码登录应该失败")
	}
	if !errors.Is(err, ErrInvalidCredentials) {
		t.Errorf("错误类型不匹配: got %v, want ErrInvalidCredentials", err)
	}
}

func TestLogin_UserNotFound(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 登录不存在的用户
	_, err := svc.Login(ctx, "nonexistent@example.com", "Password123")
	if err == nil {
		t.Fatal("不存在的用户登录应该失败")
	}
	if !errors.Is(err, ErrInvalidCredentials) {
		t.Errorf("错误类型不匹配: got %v, want ErrInvalidCredentials", err)
	}
}

func TestLogin_BannedUser(t *testing.T) {
	svc, _, banRepo, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 封禁用户
	err = banRepo.Create(ctx, &data_access.Ban{
		ID:        "ban-1",
		UserID:    result.User.ID,
		Reason:    "违规行为",
		ExpiresAt: nil, // 永久封禁
		CreatedAt: time.Now(),
		CreatedBy: "admin",
	})
	if err != nil {
		t.Fatalf("创建封禁记录失败: %v", err)
	}

	// 尝试登录
	_, err = svc.Login(ctx, "test@example.com", "Password123")
	if err == nil {
		t.Fatal("被封禁用户登录应该失败")
	}
	if !errors.Is(err, ErrUserBanned) {
		t.Errorf("错误类型不匹配: got %v, want ErrUserBanned", err)
	}
}

func TestLogin_InactiveUser(t *testing.T) {
	svc, userRepo, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 将用户设为非激活状态
	user, _ := userRepo.GetByID(ctx, result.User.ID)
	user.IsActive = false

	// 尝试登录
	_, err = svc.Login(ctx, "test@example.com", "Password123")
	if err == nil {
		t.Fatal("非激活用户登录应该失败")
	}
	if !errors.Is(err, ErrUserNotActive) {
		t.Errorf("错误类型不匹配: got %v, want ErrUserNotActive", err)
	}
}

// ==================== 登出测试 ====================

func TestLogout_Success(t *testing.T) {
	svc, _, _, tokenBlacklist := createTestAuthService(t)
	ctx := context.Background()

	// 先注册并登录
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 登出
	err = svc.Logout(ctx, result.AccessToken)
	if err != nil {
		t.Fatalf("登出失败: %v", err)
	}

	// 验证 Token 已加入黑名单
	if len(tokenBlacklist.blacklist) == 0 {
		t.Error("Token 应该被加入黑名单")
	}
}

// ==================== Token 刷新测试 ====================

func TestRefreshToken_Success(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 刷新 Token
	newResult, err := svc.RefreshToken(ctx, result.RefreshToken)
	if err != nil {
		t.Fatalf("刷新 Token 失败: %v", err)
	}

	if newResult.AccessToken == "" {
		t.Error("新的 Access Token 为空")
	}
	if newResult.RefreshToken == "" {
		t.Error("新的 Refresh Token 为空")
	}
	if newResult.User.ID != result.User.ID {
		t.Error("用户 ID 不匹配")
	}
}

func TestRefreshToken_InvalidToken(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 使用无效的 Refresh Token
	_, err := svc.RefreshToken(ctx, "invalid-token")
	if err == nil {
		t.Fatal("无效 Token 刷新应该失败")
	}
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("错误类型不匹配: got %v, want ErrInvalidToken", err)
	}
}

func TestRefreshToken_BannedUser(t *testing.T) {
	svc, _, banRepo, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 封禁用户
	err = banRepo.Create(ctx, &data_access.Ban{
		ID:        "ban-1",
		UserID:    result.User.ID,
		Reason:    "违规行为",
		ExpiresAt: nil,
		CreatedAt: time.Now(),
		CreatedBy: "admin",
	})
	if err != nil {
		t.Fatalf("创建封禁记录失败: %v", err)
	}

	// 尝试刷新 Token
	_, err = svc.RefreshToken(ctx, result.RefreshToken)
	if err == nil {
		t.Fatal("被封禁用户刷新 Token 应该失败")
	}
	if !errors.Is(err, ErrUserBanned) {
		t.Errorf("错误类型不匹配: got %v, want ErrUserBanned", err)
	}
}

// ==================== 封禁测试 ====================

func TestBanUser_Success(t *testing.T) {
	svc, _, banRepo, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 封禁用户（24 小时）
	err = svc.BanUser(ctx, result.User.ID, "违规行为", 24*time.Hour, "admin")
	if err != nil {
		t.Fatalf("封禁用户失败: %v", err)
	}

	// 验证封禁记录
	ban, err := banRepo.GetByUserID(ctx, result.User.ID)
	if err != nil {
		t.Fatalf("获取封禁记录失败: %v", err)
	}
	if ban == nil {
		t.Fatal("封禁记录为空")
	}
	if ban.Reason != "违规行为" {
		t.Errorf("封禁原因不匹配: got %s, want 违规行为", ban.Reason)
	}
}

func TestBanUser_PermanentBan(t *testing.T) {
	svc, _, banRepo, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 永久封禁（duration = 0）
	err = svc.BanUser(ctx, result.User.ID, "严重违规", 0, "admin")
	if err != nil {
		t.Fatalf("永久封禁失败: %v", err)
	}

	// 验证封禁记录
	ban, _ := banRepo.GetByUserID(ctx, result.User.ID)
	if ban.ExpiresAt != nil {
		t.Error("永久封禁的 ExpiresAt 应该为 nil")
	}
}

func TestUnbanUser_Success(t *testing.T) {
	svc, _, banRepo, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 封禁用户
	err = svc.BanUser(ctx, result.User.ID, "违规行为", 24*time.Hour, "admin")
	if err != nil {
		t.Fatalf("封禁用户失败: %v", err)
	}

	// 解封用户
	err = svc.UnbanUser(ctx, result.User.ID)
	if err != nil {
		t.Fatalf("解封用户失败: %v", err)
	}

	// 验证封禁记录已删除
	ban, _ := banRepo.GetByUserID(ctx, result.User.ID)
	if ban != nil {
		t.Error("解封后封禁记录应该为空")
	}
}

func TestCheckBanned_NotBanned(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 检查封禁状态
	banInfo, err := svc.CheckBanned(ctx, result.User.ID)
	if err != nil {
		t.Fatalf("检查封禁状态失败: %v", err)
	}
	if banInfo.Banned {
		t.Error("用户不应该被封禁")
	}
}

func TestCheckBanned_Banned(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 封禁用户
	err = svc.BanUser(ctx, result.User.ID, "违规行为", 24*time.Hour, "admin")
	if err != nil {
		t.Fatalf("封禁用户失败: %v", err)
	}

	// 检查封禁状态
	banInfo, err := svc.CheckBanned(ctx, result.User.ID)
	if err != nil {
		t.Fatalf("检查封禁状态失败: %v", err)
	}
	if !banInfo.Banned {
		t.Error("用户应该被封禁")
	}
	if banInfo.Reason != "违规行为" {
		t.Errorf("封禁原因不匹配: got %s, want 违规行为", banInfo.Reason)
	}
}

func TestCheckBanned_ExpiredBan(t *testing.T) {
	svc, _, banRepo, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 创建已过期的封禁记录
	expiredTime := time.Now().Add(-1 * time.Hour)
	err = banRepo.Create(ctx, &data_access.Ban{
		ID:        "ban-1",
		UserID:    result.User.ID,
		Reason:    "违规行为",
		ExpiresAt: &expiredTime,
		CreatedAt: time.Now().Add(-2 * time.Hour),
		CreatedBy: "admin",
	})
	if err != nil {
		t.Fatalf("创建封禁记录失败: %v", err)
	}

	// 检查封禁状态（应该自动清理过期记录）
	banInfo, err := svc.CheckBanned(ctx, result.User.ID)
	if err != nil {
		t.Fatalf("检查封禁状态失败: %v", err)
	}
	if banInfo.Banned {
		t.Error("过期的封禁不应该生效")
	}
}

// ==================== 获取公钥测试 ====================

func TestGetPublicKey_Success(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)

	keyInfo := svc.GetPublicKey()
	if keyInfo == nil {
		t.Fatal("公钥信息为空")
	}
	if keyInfo.PublicKey == "" {
		t.Error("公钥为空")
	}
	if keyInfo.KeyID == "" {
		t.Error("KeyID 为空")
	}
	if keyInfo.Algorithm != "RS256" {
		t.Errorf("算法不匹配: got %s, want RS256", keyInfo.Algorithm)
	}
	if keyInfo.ExpiresAt == 0 {
		t.Error("过期时间为 0")
	}
}

// ==================== 获取用户测试 ====================

func TestGetUser_Success(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 先注册
	result, err := svc.Register(ctx, "testuser", "test@example.com", "Password123", "Test User")
	if err != nil {
		t.Fatalf("注册失败: %v", err)
	}

	// 获取用户
	user, err := svc.GetUser(ctx, result.User.ID)
	if err != nil {
		t.Fatalf("获取用户失败: %v", err)
	}
	if user.ID != result.User.ID {
		t.Error("用户 ID 不匹配")
	}
	if user.Username != "testuser" {
		t.Errorf("用户名不匹配: got %s, want testuser", user.Username)
	}
}

func TestGetUser_NotFound(t *testing.T) {
	svc, _, _, _ := createTestAuthService(t)
	ctx := context.Background()

	// 获取不存在的用户
	_, err := svc.GetUser(ctx, "nonexistent-id")
	if err == nil {
		t.Fatal("获取不存在的用户应该失败")
	}
	if !errors.Is(err, data_access.ErrUserNotFound) {
		t.Errorf("错误类型不匹配: got %v, want ErrUserNotFound", err)
	}
}
