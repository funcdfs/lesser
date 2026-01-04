package repository

import (
	"database/sql"
	"time"

	"github.com/lib/pq"
)

// Content 内容实体（对应 contents 表）
type Content struct {
	ID        string
	AuthorID  string
	Title     string   // 可能为空
	Text      string   // 内容正文
	MediaURLs []string
	CreatedAt time.Time
}

// User 用户实体
type User struct {
	ID          string
	Username    string
	DisplayName string
	AvatarURL   string
	Bio         string
	CreatedAt   time.Time
}

// SearchRepository 搜索仓库
type SearchRepository struct {
	db *sql.DB
}

// NewSearchRepository 创建搜索仓库
func NewSearchRepository(db *sql.DB) *SearchRepository {
	return &SearchRepository{db: db}
}

// SearchContents 搜索内容（从 contents 表）
// 搜索条件：标题或正文包含关键词，且状态为已发布(status=2)
func (r *SearchRepository) SearchContents(query string, limit, offset int) ([]*Content, int, error) {
	var total int
	// 统计总数：status=2 表示已发布
	err := r.db.QueryRow(`
		SELECT COUNT(*) FROM contents 
		WHERE status = 2 AND (title ILIKE $1 OR text ILIKE $1)
	`, "%"+query+"%").Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	// 查询内容列表
	rows, err := r.db.Query(`
		SELECT id, author_id, title, text, media_urls, created_at
		FROM contents 
		WHERE status = 2 AND (title ILIKE $1 OR text ILIKE $1)
		ORDER BY created_at DESC 
		LIMIT $2 OFFSET $3
	`, "%"+query+"%", limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var contents []*Content
	for rows.Next() {
		c := &Content{}
		var title, text sql.NullString
		if err := rows.Scan(&c.ID, &c.AuthorID, &title, &text, pq.Array(&c.MediaURLs), &c.CreatedAt); err != nil {
			continue
		}
		c.Title = title.String
		c.Text = text.String
		contents = append(contents, c)
	}
	return contents, total, nil
}

// SearchUsers 搜索用户
// 搜索条件：用户名或显示名包含关键词，且账户处于激活状态
func (r *SearchRepository) SearchUsers(query string, limit, offset int) ([]*User, int, error) {
	var total int
	err := r.db.QueryRow(`
		SELECT COUNT(*) FROM users 
		WHERE is_active = true AND (username ILIKE $1 OR display_name ILIKE $1)
	`, "%"+query+"%").Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(`
		SELECT id, username, display_name, avatar_url, bio, created_at
		FROM users 
		WHERE is_active = true AND (username ILIKE $1 OR display_name ILIKE $1)
		ORDER BY created_at DESC 
		LIMIT $2 OFFSET $3
	`, "%"+query+"%", limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var users []*User
	for rows.Next() {
		u := &User{}
		var displayName, avatarURL, bio sql.NullString
		if err := rows.Scan(&u.ID, &u.Username, &displayName, &avatarURL, &bio, &u.CreatedAt); err != nil {
			continue
		}
		u.DisplayName = displayName.String
		u.AvatarURL = avatarURL.String
		u.Bio = bio.String
		users = append(users, u)
	}
	return users, total, nil
}
