package service

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/lesser/auth/internal/repository"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUserBanned         = errors.New("user is banned")
	ErrInvalidToken       = errors.New("invalid token")
	ErrTokenExpired       = errors.New("token expired")
)

// AuthService 认证服务
type AuthService struct {
	userRepo  *repository.UserRepository
	banRepo   *repository.BanRepository
	jwtSecret []byte

	// RSA 密钥对（用于 JWT 签名）
	privateKey    *rsa.PrivateKey
	publicKey     *rsa.PublicKey
	publicKeyPEM  string
	keyID         string
	keyExpiresAt  time.Time
	keyMu         sync.RWMutex
}

// NewAuthService 创建认证服务
func NewAuthService(userRepo *repository.UserRepository, banRepo *repository.BanRepository, jwtSecret string) *AuthService {
	svc := &AuthService{
		userRepo:  userRepo,
		banRepo:   banRepo,
		jwtSecret: []byte(jwtSecret),
	}

	// 生成 RSA 密钥对
	if err := svc.generateKeyPair(); err != nil {
		panic("failed to generate RSA key pair: " + err.Error())
	}

	return svc
}

// generateKeyPair 生成 RSA 密钥对
func (s *AuthService) generateKeyPair() error {
	privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return err
	}

	publicKeyBytes, err := x509.MarshalPKIXPublicKey(&privateKey.PublicKey)
	if err != nil {
		return err
	}

	publicKeyPEM := pem.EncodeToMemory(&pem.Block{
		Type:  "PUBLIC KEY",
		Bytes: publicKeyBytes,
	})

	s.keyMu.Lock()
	s.privateKey = privateKey
	s.publicKey = &privateKey.PublicKey
	s.publicKeyPEM = string(publicKeyPEM)
	s.keyID = uuid.New().String()[:8]
	s.keyExpiresAt = time.Now().Add(30 * 24 * time.Hour) // 30 天后过期
	s.keyMu.Unlock()

	return nil
}


// Register 用户注册
func (s *AuthService) Register(username, email, password, displayName string) (*AuthResult, error) {
	// 检查用户是否已存在
	exists, err := s.userRepo.ExistsByEmailOrUsername(email, username)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, repository.ErrUserExists
	}

	// 哈希密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// 创建用户
	now := time.Now()
	user := &repository.User{
		ID:          uuid.New().String(),
		Username:    username,
		Email:       email,
		Password:    string(hashedPassword),
		DisplayName: displayName,
		IsActive:    true,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	if err := s.userRepo.Create(user); err != nil {
		return nil, err
	}

	// 生成 Token
	accessToken, err := s.generateAccessToken(user.ID)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(user.ID)
	if err != nil {
		return nil, err
	}

	return &AuthResult{
		User:         user,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

// Login 用户登录
func (s *AuthService) Login(email, password string) (*AuthResult, error) {
	// 获取用户
	user, err := s.userRepo.GetByEmail(email)
	if err != nil {
		if err == repository.ErrUserNotFound {
			return nil, ErrInvalidCredentials
		}
		return nil, err
	}

	// 检查是否被封禁
	banned, ban, err := s.banRepo.IsUserBanned(user.ID)
	if err != nil {
		return nil, err
	}
	if banned {
		return nil, errors.New("user is banned: " + ban.Reason)
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return nil, ErrInvalidCredentials
	}

	// 生成 Token
	accessToken, err := s.generateAccessToken(user.ID)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(user.ID)
	if err != nil {
		return nil, err
	}

	return &AuthResult{
		User:         user,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

// RefreshToken 刷新 Token
func (s *AuthService) RefreshToken(refreshToken string) (*AuthResult, error) {
	// 解析 refresh token（使用 HMAC 验证）
	token, err := jwt.Parse(refreshToken, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return s.jwtSecret, nil
	})
	if err != nil {
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}

	// 验证 token 类型
	tokenType, ok := claims["type"].(string)
	if !ok || tokenType != "refresh" {
		return nil, ErrInvalidToken
	}

	// 获取用户 ID
	userID, ok := claims["sub"].(string)
	if !ok {
		return nil, ErrInvalidToken
	}

	// 获取用户
	user, err := s.userRepo.GetByID(userID)
	if err != nil {
		return nil, err
	}

	// 检查是否被封禁
	banned, _, err := s.banRepo.IsUserBanned(user.ID)
	if err != nil {
		return nil, err
	}
	if banned {
		return nil, ErrUserBanned
	}

	// 生成新 Token
	newAccessToken, err := s.generateAccessToken(user.ID)
	if err != nil {
		return nil, err
	}

	newRefreshToken, err := s.generateRefreshToken(user.ID)
	if err != nil {
		return nil, err
	}

	return &AuthResult{
		User:         user,
		AccessToken:  newAccessToken,
		RefreshToken: newRefreshToken,
	}, nil
}

// GetPublicKey 获取公钥信息
func (s *AuthService) GetPublicKey() *PublicKeyInfo {
	s.keyMu.RLock()
	defer s.keyMu.RUnlock()

	return &PublicKeyInfo{
		PublicKey: s.publicKeyPEM,
		KeyID:     s.keyID,
		Algorithm: "RS256",
		ExpiresAt: s.keyExpiresAt.Unix(),
	}
}

// BanUser 封禁用户
func (s *AuthService) BanUser(userID, reason string, durationSeconds int64) error {
	var expiresAt *time.Time
	if durationSeconds > 0 {
		t := time.Now().Add(time.Duration(durationSeconds) * time.Second)
		expiresAt = &t
	}

	ban := &repository.Ban{
		ID:        uuid.New().String(),
		UserID:    userID,
		Reason:    reason,
		ExpiresAt: expiresAt,
		CreatedAt: time.Now(),
	}

	return s.banRepo.Create(ban)
}

// CheckBanned 检查用户是否被封禁
func (s *AuthService) CheckBanned(userID string) (bool, string, int64) {
	banned, ban, err := s.banRepo.IsUserBanned(userID)
	if err != nil || !banned {
		return false, "", 0
	}

	var expiresAt int64
	if ban.ExpiresAt != nil {
		expiresAt = ban.ExpiresAt.Unix()
	}

	return true, ban.Reason, expiresAt
}

// GetUser 获取用户信息
func (s *AuthService) GetUser(userID string) (*repository.User, error) {
	return s.userRepo.GetByID(userID)
}

// generateAccessToken 生成访问令牌（使用 RSA 签名）
func (s *AuthService) generateAccessToken(userID string) (string, error) {
	s.keyMu.RLock()
	privateKey := s.privateKey
	keyID := s.keyID
	s.keyMu.RUnlock()

	claims := jwt.MapClaims{
		"sub":  userID,
		"type": "access",
		"exp":  time.Now().Add(15 * time.Minute).Unix(),
		"iat":  time.Now().Unix(),
		"jti":  uuid.New().String(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	token.Header["kid"] = keyID

	return token.SignedString(privateKey)
}

// generateRefreshToken 生成刷新令牌（使用 HMAC 签名）
func (s *AuthService) generateRefreshToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"sub":  userID,
		"type": "refresh",
		"exp":  time.Now().Add(7 * 24 * time.Hour).Unix(),
		"iat":  time.Now().Unix(),
		"jti":  uuid.New().String(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.jwtSecret)
}

// AuthResult 认证结果
type AuthResult struct {
	User         *repository.User
	AccessToken  string
	RefreshToken string
}

// PublicKeyInfo 公钥信息
type PublicKeyInfo struct {
	PublicKey string
	KeyID     string
	Algorithm string
	ExpiresAt int64
}
