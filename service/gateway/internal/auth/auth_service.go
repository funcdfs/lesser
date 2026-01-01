package auth

import (
	"database/sql"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrUserExists         = errors.New("user already exists")
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUserNotFound       = errors.New("user not found")
	ErrInvalidToken       = errors.New("invalid token")
	ErrTokenExpired       = errors.New("token expired")
)

// AuthService 认证服务
type AuthService struct {
	db        *sql.DB
	jwtSecret []byte
}

// NewAuthService 创建新的 AuthService
func NewAuthService(db *sql.DB, jwtSecret string) *AuthService {
	return &AuthService{
		db:        db,
		jwtSecret: []byte(jwtSecret),
	}
}

// LoginResult 登录结果
type LoginResult struct {
	UserID       string
	AccessToken  string
	RefreshToken string
}

// Login 用户登录
func (s *AuthService) Login(username, password string) (*LoginResult, error) {
	var user struct {
		ID           string
		PasswordHash string
	}

	// 支持用户名或邮箱登录
	err := s.db.QueryRow(`
		SELECT id, password FROM users 
		WHERE username = $1 OR email = $1
	`, username).Scan(&user.ID, &user.PasswordHash)
	if err == sql.ErrNoRows {
		return nil, ErrInvalidCredentials
	}
	if err != nil {
		return nil, err
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return nil, ErrInvalidCredentials
	}

	// 生成 token
	accessToken, err := s.generateAccessToken(user.ID)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(user.ID)
	if err != nil {
		return nil, err
	}

	return &LoginResult{
		UserID:       user.ID,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

// RegisterResult 注册结果
type RegisterResult struct {
	UserID       string
	AccessToken  string
	RefreshToken string
}

// Register 用户注册
func (s *AuthService) Register(username, email, password string) (*RegisterResult, error) {
	// 检查用户是否已存在
	var exists bool
	err := s.db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM users WHERE email = $1 OR username = $2)",
		email, username,
	).Scan(&exists)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrUserExists
	}

	// 哈希密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// 创建用户
	userID := uuid.New().String()
	_, err = s.db.Exec(`
		INSERT INTO users (id, username, email, password, display_name, bio, is_active, is_staff, is_superuser, is_verified, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, '', true, false, false, false, NOW(), NOW())
	`, userID, username, email, string(hashedPassword), username)
	if err != nil {
		return nil, err
	}

	// 生成 token
	accessToken, err := s.generateAccessToken(userID)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(userID)
	if err != nil {
		return nil, err
	}

	return &RegisterResult{
		UserID:       userID,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

// RefreshTokenResult 刷新 Token 结果
type RefreshTokenResult struct {
	UserID       string
	AccessToken  string
	RefreshToken string
}

// RefreshToken 刷新 Token
func (s *AuthService) RefreshToken(refreshToken string) (*RefreshTokenResult, error) {
	// 解析 refresh token
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

	// 验证用户是否存在
	var exists bool
	err = s.db.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE id = $1)", userID).Scan(&exists)
	if err != nil || !exists {
		return nil, ErrUserNotFound
	}

	// 生成新 token
	newAccessToken, err := s.generateAccessToken(userID)
	if err != nil {
		return nil, err
	}

	newRefreshToken, err := s.generateRefreshToken(userID)
	if err != nil {
		return nil, err
	}

	return &RefreshTokenResult{
		UserID:       userID,
		AccessToken:  newAccessToken,
		RefreshToken: newRefreshToken,
	}, nil
}

// generateAccessToken 生成访问令牌
func (s *AuthService) generateAccessToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"sub":  userID,
		"type": "access",
		"exp":  time.Now().Add(15 * time.Minute).Unix(),
		"iat":  time.Now().Unix(),
		"jti":  uuid.New().String(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.jwtSecret)
}

// generateRefreshToken 生成刷新令牌
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
