// Package postgres 会话 PostgreSQL 仓库实现
package postgres

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"github.com/google/uuid"
)

// SessionRepository PostgreSQL 会话仓库
type SessionRepository struct {
	db *sql.DB
}

// NewSessionRepository 创建会话仓库
func NewSessionRepository(db *sql.DB) *SessionRepository {
	return &SessionRepository{db: db}
}

// Create 创建会话
func (r *SessionRepository) Create(ctx context.Context, session *data_access.Session) error {
	query := `
		INSERT INTO superuser_sessions (id, superuser_id, token_hash, ip_address, user_agent, expires_at, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`
	if session.ID == uuid.Nil {
		session.ID = uuid.New()
	}
	session.CreatedAt = time.Now()

	_, err := r.db.ExecContext(ctx, query,
		session.ID, session.SuperUserID, session.TokenHash, session.IPAddress,
		session.UserAgent, session.ExpiresAt, session.CreatedAt)
	return err
}

// GetByTokenHash 根据 Token 哈希获取会话
func (r *SessionRepository) GetByTokenHash(ctx context.Context, tokenHash string) (*data_access.Session, error) {
	query := `
		SELECT id, superuser_id, token_hash, ip_address, user_agent, expires_at, created_at, revoked_at
		FROM superuser_sessions 
		WHERE token_hash = $1 AND revoked_at IS NULL AND expires_at > $2
	`
	session := &data_access.Session{}
	err := r.db.QueryRowContext(ctx, query, tokenHash, time.Now()).Scan(
		&session.ID, &session.SuperUserID, &session.TokenHash, &session.IPAddress,
		&session.UserAgent, &session.ExpiresAt, &session.CreatedAt, &session.RevokedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return session, nil
}

// Revoke 撤销会话
func (r *SessionRepository) Revoke(ctx context.Context, tokenHash string) error {
	query := `UPDATE superuser_sessions SET revoked_at = $2 WHERE token_hash = $1 AND revoked_at IS NULL`
	_, err := r.db.ExecContext(ctx, query, tokenHash, time.Now())
	return err
}

// RevokeAllByUserID 撤销用户所有会话
func (r *SessionRepository) RevokeAllByUserID(ctx context.Context, userID uuid.UUID) error {
	query := `UPDATE superuser_sessions SET revoked_at = $2 WHERE superuser_id = $1 AND revoked_at IS NULL`
	_, err := r.db.ExecContext(ctx, query, userID, time.Now())
	return err
}

// CleanExpired 清理过期会话
func (r *SessionRepository) CleanExpired(ctx context.Context) error {
	query := `DELETE FROM superuser_sessions WHERE expires_at < $1 OR revoked_at IS NOT NULL`
	_, err := r.db.ExecContext(ctx, query, time.Now().Add(-24*time.Hour))
	return err
}
