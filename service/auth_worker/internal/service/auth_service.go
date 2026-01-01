package service

import (
	"database/sql"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/lesser/auth_worker/proto/auth"
	"github.com/lesser/auth_worker/proto/common"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrUserExists        = errors.New("user already exists")
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUserNotFound      = errors.New("user not found")
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

// Register 用户注册
func (s *AuthService) Register(req *auth.RegisterRequest) (*auth.AuthResponse, error) {
	// 检查用户是否已存在
	var exists bool
	err := s.db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM users WHERE email = $1 OR username = $2)",
		req.Email, req.Username,
	).Scan(&exists)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrUserExists
	}

	// 哈希密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// 创建用户
	userID := uuid.New().String()
	var createdAt time.Time
	err = s.db.QueryRow(`
		INSERT INTO users (id, username, email, password, display_name, bio, is_active, is_staff, is_superuser, is_verified, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, '', true, false, false, false, NOW(), NOW())
		RETURNING created_at
	`, userID, req.Username, req.Email, string(hashedPassword), req.DisplayName).Scan(&createdAt)
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

	return &auth.AuthResponse{
		User: &auth.User{
			Id:          userID,
			Username:    req.Username,
			Email:       req.Email,
			DisplayName: req.DisplayName,
			CreatedAt: &common.Timestamp{
				Seconds: createdAt.Unix(),
				Nanos:   int32(createdAt.Nanosecond()),
			},
		},
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

// Login 用户登录
func (s *AuthService) Login(req *auth.LoginRequest) (*auth.AuthResponse, error) {
	var user struct {
		ID           string
		Username     string
		Email        string
		PasswordHash string
		DisplayName  sql.NullString
		AvatarURL    sql.NullString
		Bio          sql.NullString
		CreatedAt    time.Time
	}

	err := s.db.QueryRow(`
		SELECT id, username, email, password, display_name, avatar_url, bio, created_at
		FROM users WHERE email = $1
	`, req.Email).Scan(
		&user.ID, &user.Username, &user.Email, &user.PasswordHash,
		&user.DisplayName, &user.AvatarURL, &user.Bio, &user.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, ErrInvalidCredentials
	}
	if err != nil {
		return nil, err
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
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

	return &auth.AuthResponse{
		User: &auth.User{
			Id:          user.ID,
			Username:    user.Username,
			Email:       user.Email,
			DisplayName: user.DisplayName.String,
			AvatarUrl:   user.AvatarURL.String,
			Bio:         user.Bio.String,
			CreatedAt: &common.Timestamp{
				Seconds: user.CreatedAt.Unix(),
				Nanos:   int32(user.CreatedAt.Nanosecond()),
			},
		},
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
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
