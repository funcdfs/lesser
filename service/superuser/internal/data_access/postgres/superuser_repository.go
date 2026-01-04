// Package postgres SuperUser PostgreSQL 仓库实现
package postgres

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"github.com/google/uuid"
)

// SuperUserRepository PostgreSQL 超级管理员仓库
type SuperUserRepository struct {
	db *sql.DB
}

// NewSuperUserRepository 创建超级管理员仓库
func NewSuperUserRepository(db *sql.DB) *SuperUserRepository {
	return &SuperUserRepository{db: db}
}

// Create 创建超级管理员
func (r *SuperUserRepository) Create(ctx context.Context, su *data_access.SuperUser) error {
	query := `
		INSERT INTO superusers (id, username, email, password, display_name, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`
	if su.ID == uuid.Nil {
		su.ID = uuid.New()
	}
	now := time.Now()
	su.CreatedAt = now
	su.UpdatedAt = now

	_, err := r.db.ExecContext(ctx, query,
		su.ID, su.Username, su.Email, su.Password, su.DisplayName, su.IsActive, su.CreatedAt, su.UpdatedAt)
	return err
}

// GetByID 根据 ID 获取超级管理员
func (r *SuperUserRepository) GetByID(ctx context.Context, id uuid.UUID) (*data_access.SuperUser, error) {
	query := `
		SELECT id, username, email, password, display_name, is_active, 
		       last_login_at, last_login_ip, login_count, created_at, updated_at
		FROM superusers WHERE id = $1
	`
	return r.scanSuperUser(r.db.QueryRowContext(ctx, query, id))
}

// GetByUsername 根据用户名获取超级管理员
func (r *SuperUserRepository) GetByUsername(ctx context.Context, username string) (*data_access.SuperUser, error) {
	query := `
		SELECT id, username, email, password, display_name, is_active, 
		       last_login_at, last_login_ip, login_count, created_at, updated_at
		FROM superusers WHERE username = $1
	`
	return r.scanSuperUser(r.db.QueryRowContext(ctx, query, username))
}

// GetByEmail 根据邮箱获取超级管理员
func (r *SuperUserRepository) GetByEmail(ctx context.Context, email string) (*data_access.SuperUser, error) {
	query := `
		SELECT id, username, email, password, display_name, is_active, 
		       last_login_at, last_login_ip, login_count, created_at, updated_at
		FROM superusers WHERE email = $1
	`
	return r.scanSuperUser(r.db.QueryRowContext(ctx, query, email))
}

// Update 更新超级管理员
func (r *SuperUserRepository) Update(ctx context.Context, su *data_access.SuperUser) error {
	query := `
		UPDATE superusers 
		SET username = $2, email = $3, password = $4, display_name = $5, 
		    is_active = $6, updated_at = $7
		WHERE id = $1
	`
	su.UpdatedAt = time.Now()
	_, err := r.db.ExecContext(ctx, query,
		su.ID, su.Username, su.Email, su.Password, su.DisplayName, su.IsActive, su.UpdatedAt)
	return err
}

// UpdateLoginInfo 更新登录信息
func (r *SuperUserRepository) UpdateLoginInfo(ctx context.Context, id uuid.UUID, ip string) error {
	query := `
		UPDATE superusers 
		SET last_login_at = $2, last_login_ip = $3, login_count = login_count + 1, updated_at = $4
		WHERE id = $1
	`
	now := time.Now()
	_, err := r.db.ExecContext(ctx, query, id, now, ip, now)
	return err
}

// ExistsByUsername 检查用户名是否存在
func (r *SuperUserRepository) ExistsByUsername(ctx context.Context, username string) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM superusers WHERE username = $1)`
	var exists bool
	err := r.db.QueryRowContext(ctx, query, username).Scan(&exists)
	return exists, err
}

// ExistsByEmail 检查邮箱是否存在
func (r *SuperUserRepository) ExistsByEmail(ctx context.Context, email string) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM superusers WHERE email = $1)`
	var exists bool
	err := r.db.QueryRowContext(ctx, query, email).Scan(&exists)
	return exists, err
}

// scanSuperUser 扫描超级管理员行
func (r *SuperUserRepository) scanSuperUser(row *sql.Row) (*data_access.SuperUser, error) {
	su := &data_access.SuperUser{}
	err := row.Scan(
		&su.ID, &su.Username, &su.Email, &su.Password, &su.DisplayName, &su.IsActive,
		&su.LastLoginAt, &su.LastLoginIP, &su.LoginCount, &su.CreatedAt, &su.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return su, nil
}
