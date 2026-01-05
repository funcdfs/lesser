// Package data_access 审计日志 PostgreSQL 数据访问实现
package data_access

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
)

// AuditLogDataAccessImpl PostgreSQL 审计日志数据访问
type AuditLogDataAccessImpl struct {
	db *sql.DB
}

// NewAuditLogDataAccess 创建审计日志数据访问
func NewAuditLogDataAccess(db *sql.DB) *AuditLogDataAccessImpl {
	return &AuditLogDataAccessImpl{db: db}
}

// Create 创建审计日志
func (r *AuditLogDataAccessImpl) Create(ctx context.Context, log *AuditLog) error {
	query := `
		INSERT INTO superuser_audit_logs (id, superuser_id, action, target_type, target_id, details, ip_address, user_agent, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`
	if log.ID == uuid.Nil {
		log.ID = uuid.New()
	}
	log.CreatedAt = time.Now()

	// 序列化 details 为 JSON
	var detailsJSON []byte
	var err error
	if log.Details != nil {
		detailsJSON, err = json.Marshal(log.Details)
		if err != nil {
			return fmt.Errorf("序列化 details 失败: %w", err)
		}
	}

	_, err = r.db.ExecContext(ctx, query,
		log.ID, log.SuperUserID, log.Action, log.TargetType, log.TargetID,
		detailsJSON, log.IPAddress, log.UserAgent, log.CreatedAt)
	return err
}

// List 获取审计日志列表
func (r *AuditLogDataAccessImpl) List(ctx context.Context, filter AuditLogFilter) ([]*AuditLog, int, error) {
	// 构建查询条件
	var conditions []string
	var args []interface{}
	argIndex := 1

	if filter.SuperUserID != nil {
		conditions = append(conditions, fmt.Sprintf("al.superuser_id = $%d", argIndex))
		args = append(args, *filter.SuperUserID)
		argIndex++
	}
	if filter.Action != nil {
		conditions = append(conditions, fmt.Sprintf("al.action = $%d", argIndex))
		args = append(args, *filter.Action)
		argIndex++
	}
	if filter.StartTime != nil {
		conditions = append(conditions, fmt.Sprintf("al.created_at >= $%d", argIndex))
		args = append(args, *filter.StartTime)
		argIndex++
	}
	if filter.EndTime != nil {
		conditions = append(conditions, fmt.Sprintf("al.created_at <= $%d", argIndex))
		args = append(args, *filter.EndTime)
		argIndex++
	}

	whereClause := ""
	if len(conditions) > 0 {
		whereClause = "WHERE " + strings.Join(conditions, " AND ")
	}

	// 获取总数
	countQuery := fmt.Sprintf(`SELECT COUNT(*) FROM superuser_audit_logs al %s`, whereClause)
	var total int
	if err := r.db.QueryRowContext(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	// 获取列表
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 20
	}
	offset := (filter.Page - 1) * filter.PageSize

	query := fmt.Sprintf(`
		SELECT al.id, al.superuser_id, su.username, al.action, al.target_type, al.target_id, 
		       al.details, al.ip_address, al.user_agent, al.created_at
		FROM superuser_audit_logs al
		LEFT JOIN superusers su ON al.superuser_id = su.id
		%s
		ORDER BY al.created_at DESC
		LIMIT $%d OFFSET $%d
	`, whereClause, argIndex, argIndex+1)
	args = append(args, filter.PageSize, offset)

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var logs []*AuditLog
	for rows.Next() {
		log := &AuditLog{}
		var detailsJSON []byte
		err := rows.Scan(
			&log.ID, &log.SuperUserID, &log.SuperUserUsername, &log.Action,
			&log.TargetType, &log.TargetID, &detailsJSON, &log.IPAddress, &log.UserAgent, &log.CreatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		if detailsJSON != nil {
			if err := json.Unmarshal(detailsJSON, &log.Details); err != nil {
				log.Details = nil
			}
		}
		logs = append(logs, log)
	}

	return logs, total, rows.Err()
}

// 确保实现接口
var _ AuditLogDataAccess = (*AuditLogDataAccessImpl)(nil)
