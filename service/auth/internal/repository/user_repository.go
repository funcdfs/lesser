package repository

import (
	"database/sql"
	"errors"
	"time"
)

var (
	ErrUserNotFound = errors.New("user not found")
	ErrUserExists   = errors.New("user already exists")
)

// User 用户实体
type User struct {
	ID          string
	Username    string
	Email       string
	Password    string
	DisplayName string
	AvatarURL   string
	Bio         string
	IsActive    bool
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// UserRepository 用户数据访问
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository 创建用户仓库
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create 创建用户
func (r *UserRepository) Create(user *User) error {
	_, err := r.db.Exec(`
		INSERT INTO users (id, username, email, password, display_name, bio, is_active, is_staff, is_superuser, is_verified, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, false, false, false, $8, $9)
	`, user.ID, user.Username, user.Email, user.Password, user.DisplayName, user.Bio, user.IsActive, user.CreatedAt, user.UpdatedAt)
	return err
}

// GetByID 根据 ID 获取用户
func (r *UserRepository) GetByID(id string) (*User, error) {
	user := &User{}
	var displayName, avatarURL, bio sql.NullString

	err := r.db.QueryRow(`
		SELECT id, username, email, password, display_name, avatar_url, bio, is_active, created_at, updated_at
		FROM users WHERE id = $1
	`, id).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password,
		&displayName, &avatarURL, &bio, &user.IsActive,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, ErrUserNotFound
	}
	if err != nil {
		return nil, err
	}

	user.DisplayName = displayName.String
	user.AvatarURL = avatarURL.String
	user.Bio = bio.String
	return user, nil
}

// GetByEmail 根据邮箱获取用户
func (r *UserRepository) GetByEmail(email string) (*User, error) {
	user := &User{}
	var displayName, avatarURL, bio sql.NullString

	err := r.db.QueryRow(`
		SELECT id, username, email, password, display_name, avatar_url, bio, is_active, created_at, updated_at
		FROM users WHERE email = $1
	`, email).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password,
		&displayName, &avatarURL, &bio, &user.IsActive,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, ErrUserNotFound
	}
	if err != nil {
		return nil, err
	}

	user.DisplayName = displayName.String
	user.AvatarURL = avatarURL.String
	user.Bio = bio.String
	return user, nil
}

// GetByUsername 根据用户名获取用户
func (r *UserRepository) GetByUsername(username string) (*User, error) {
	user := &User{}
	var displayName, avatarURL, bio sql.NullString

	err := r.db.QueryRow(`
		SELECT id, username, email, password, display_name, avatar_url, bio, is_active, created_at, updated_at
		FROM users WHERE username = $1
	`, username).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password,
		&displayName, &avatarURL, &bio, &user.IsActive,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, ErrUserNotFound
	}
	if err != nil {
		return nil, err
	}

	user.DisplayName = displayName.String
	user.AvatarURL = avatarURL.String
	user.Bio = bio.String
	return user, nil
}

// ExistsByEmailOrUsername 检查邮箱或用户名是否已存在
func (r *UserRepository) ExistsByEmailOrUsername(email, username string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(`
		SELECT EXISTS(SELECT 1 FROM users WHERE email = $1 OR username = $2)
	`, email, username).Scan(&exists)
	return exists, err
}
