package repository

import (
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"time"

	"github.com/lib/pq"
)

// Content 内容实体（对应 contents 表）
type Content struct {
	ID        string
	AuthorID  string
	Title     string
	Text      string
	MediaURLs []string
	CreatedAt time.Time
	Score     float64 // 相关性得分
}

// User 用户实体
type User struct {
	ID          string
	Username    string
	DisplayName string
	AvatarURL   string
	Bio         string
	CreatedAt   time.Time
	Score       float64
}

// Comment 评论实体
type Comment struct {
	ID        string
	AuthorID  string
	PostID    string
	Content   string
	CreatedAt time.Time
	Score     float64
}

// SearchRepository 搜索仓库
type SearchRepository struct {
	db *sql.DB
}

// NewSearchRepository 创建搜索仓库
func NewSearchRepository(db *sql.DB) *SearchRepository {
	return &SearchRepository{db: db}
}

// SearchContents 搜索内容（关键词匹配）
func (r *SearchRepository) SearchContents(query string, limit, offset int) ([]*Content, int, error) {
	var total int
	err := r.db.QueryRow(`
		SELECT COUNT(*) FROM contents 
		WHERE status = 2 AND (title ILIKE $1 OR text ILIKE $1)
	`, "%"+query+"%").Scan(&total)
	if err != nil {
		return nil, 0, err
	}

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

// SearchContentsSemantic 语义搜索内容（使用 pgvector）
func (r *SearchRepository) SearchContentsSemantic(embedding []float32, limit, offset int) ([]*Content, int, error) {
	// 统计有向量的内容总数
	var total int
	err := r.db.QueryRow(`
		SELECT COUNT(*) FROM content_embeddings ce
		JOIN contents c ON ce.content_id = c.id
		WHERE c.status = 2
	`).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	// 使用余弦相似度搜索
	rows, err := r.db.Query(`
		SELECT c.id, c.author_id, c.title, c.text, c.media_urls, c.created_at,
		       1 - (ce.embedding <=> $1::vector) as score
		FROM content_embeddings ce
		JOIN contents c ON ce.content_id = c.id
		WHERE c.status = 2
		ORDER BY ce.embedding <=> $1::vector
		LIMIT $2 OFFSET $3
	`, pq.Array(embedding), limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var contents []*Content
	for rows.Next() {
		c := &Content{}
		var title, text sql.NullString
		if err := rows.Scan(&c.ID, &c.AuthorID, &title, &text, pq.Array(&c.MediaURLs), &c.CreatedAt, &c.Score); err != nil {
			continue
		}
		c.Title = title.String
		c.Text = text.String
		contents = append(contents, c)
	}
	return contents, total, nil
}

// SearchUsers 搜索用户（关键词匹配）
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

// SearchUsersSemantic 语义搜索用户
func (r *SearchRepository) SearchUsersSemantic(embedding []float32, limit, offset int) ([]*User, int, error) {
	var total int
	err := r.db.QueryRow(`
		SELECT COUNT(*) FROM user_embeddings ue
		JOIN users u ON ue.user_id = u.id
		WHERE u.is_active = true
	`).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(`
		SELECT u.id, u.username, u.display_name, u.avatar_url, u.bio, u.created_at,
		       1 - (ue.embedding <=> $1::vector) as score
		FROM user_embeddings ue
		JOIN users u ON ue.user_id = u.id
		WHERE u.is_active = true
		ORDER BY ue.embedding <=> $1::vector
		LIMIT $2 OFFSET $3
	`, pq.Array(embedding), limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var users []*User
	for rows.Next() {
		u := &User{}
		var displayName, avatarURL, bio sql.NullString
		if err := rows.Scan(&u.ID, &u.Username, &displayName, &avatarURL, &bio, &u.CreatedAt, &u.Score); err != nil {
			continue
		}
		u.DisplayName = displayName.String
		u.AvatarURL = avatarURL.String
		u.Bio = bio.String
		users = append(users, u)
	}
	return users, total, nil
}

// SearchComments 搜索评论（关键词匹配）
func (r *SearchRepository) SearchComments(query string, postID string, limit, offset int) ([]*Comment, int, error) {
	var total int
	var err error

	if postID != "" {
		err = r.db.QueryRow(`
			SELECT COUNT(*) FROM comments 
			WHERE is_deleted = false AND post_id = $1 AND content ILIKE $2
		`, postID, "%"+query+"%").Scan(&total)
	} else {
		err = r.db.QueryRow(`
			SELECT COUNT(*) FROM comments 
			WHERE is_deleted = false AND content ILIKE $1
		`, "%"+query+"%").Scan(&total)
	}
	if err != nil {
		return nil, 0, err
	}

	var rows *sql.Rows
	if postID != "" {
		rows, err = r.db.Query(`
			SELECT id, author_id, post_id, content, created_at
			FROM comments 
			WHERE is_deleted = false AND post_id = $1 AND content ILIKE $2
			ORDER BY created_at DESC 
			LIMIT $3 OFFSET $4
		`, postID, "%"+query+"%", limit, offset)
	} else {
		rows, err = r.db.Query(`
			SELECT id, author_id, post_id, content, created_at
			FROM comments 
			WHERE is_deleted = false AND content ILIKE $1
			ORDER BY created_at DESC 
			LIMIT $2 OFFSET $3
		`, "%"+query+"%", limit, offset)
	}
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var comments []*Comment
	for rows.Next() {
		c := &Comment{}
		if err := rows.Scan(&c.ID, &c.AuthorID, &c.PostID, &c.Content, &c.CreatedAt); err != nil {
			continue
		}
		comments = append(comments, c)
	}
	return comments, total, nil
}

// SearchCommentsSemantic 语义搜索评论
func (r *SearchRepository) SearchCommentsSemantic(embedding []float32, postID string, limit, offset int) ([]*Comment, int, error) {
	var total int
	var err error

	if postID != "" {
		err = r.db.QueryRow(`
			SELECT COUNT(*) FROM comment_embeddings ce
			JOIN comments c ON ce.comment_id = c.id
			WHERE c.is_deleted = false AND c.post_id = $1
		`, postID).Scan(&total)
	} else {
		err = r.db.QueryRow(`
			SELECT COUNT(*) FROM comment_embeddings ce
			JOIN comments c ON ce.comment_id = c.id
			WHERE c.is_deleted = false
		`).Scan(&total)
	}
	if err != nil {
		return nil, 0, err
	}

	var rows *sql.Rows
	if postID != "" {
		rows, err = r.db.Query(`
			SELECT c.id, c.author_id, c.post_id, c.content, c.created_at,
			       1 - (ce.embedding <=> $1::vector) as score
			FROM comment_embeddings ce
			JOIN comments c ON ce.comment_id = c.id
			WHERE c.is_deleted = false AND c.post_id = $2
			ORDER BY ce.embedding <=> $1::vector
			LIMIT $3 OFFSET $4
		`, pq.Array(embedding), postID, limit, offset)
	} else {
		rows, err = r.db.Query(`
			SELECT c.id, c.author_id, c.post_id, c.content, c.created_at,
			       1 - (ce.embedding <=> $1::vector) as score
			FROM comment_embeddings ce
			JOIN comments c ON ce.comment_id = c.id
			WHERE c.is_deleted = false
			ORDER BY ce.embedding <=> $1::vector
			LIMIT $2 OFFSET $3
		`, pq.Array(embedding), limit, offset)
	}
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var comments []*Comment
	for rows.Next() {
		c := &Comment{}
		if err := rows.Scan(&c.ID, &c.AuthorID, &c.PostID, &c.Content, &c.CreatedAt, &c.Score); err != nil {
			continue
		}
		comments = append(comments, c)
	}
	return comments, total, nil
}

// UpsertContentEmbedding 更新或插入内容向量
func (r *SearchRepository) UpsertContentEmbedding(contentID string, embedding []float32, text string) error {
	textHash := hashText(text)
	_, err := r.db.Exec(`
		INSERT INTO content_embeddings (content_id, embedding, text_hash)
		VALUES ($1, $2::vector, $3)
		ON CONFLICT (content_id) DO UPDATE SET
			embedding = EXCLUDED.embedding,
			text_hash = EXCLUDED.text_hash,
			updated_at = NOW()
	`, contentID, pq.Array(embedding), textHash)
	return err
}

// UpsertCommentEmbedding 更新或插入评论向量
func (r *SearchRepository) UpsertCommentEmbedding(commentID string, embedding []float32, text string) error {
	textHash := hashText(text)
	_, err := r.db.Exec(`
		INSERT INTO comment_embeddings (comment_id, embedding, text_hash)
		VALUES ($1, $2::vector, $3)
		ON CONFLICT (comment_id) DO UPDATE SET
			embedding = EXCLUDED.embedding,
			text_hash = EXCLUDED.text_hash,
			updated_at = NOW()
	`, commentID, pq.Array(embedding), textHash)
	return err
}

// UpsertUserEmbedding 更新或插入用户向量
func (r *SearchRepository) UpsertUserEmbedding(userID string, embedding []float32, text string) error {
	textHash := hashText(text)
	_, err := r.db.Exec(`
		INSERT INTO user_embeddings (user_id, embedding, text_hash)
		VALUES ($1, $2::vector, $3)
		ON CONFLICT (user_id) DO UPDATE SET
			embedding = EXCLUDED.embedding,
			text_hash = EXCLUDED.text_hash,
			updated_at = NOW()
	`, userID, pq.Array(embedding), textHash)
	return err
}

// hashText 计算文本的 SHA256 哈希
func hashText(text string) string {
	h := sha256.Sum256([]byte(text))
	return hex.EncodeToString(h[:])
}
