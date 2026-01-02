package repository

import (
	"database/sql"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

var ErrPostNotFound = errors.New("post not found")

type Post struct {
	ID            string
	AuthorID      string
	PostType      int32
	Title         string
	Content       string
	MediaURLs     []string
	ExpiresAt     *time.Time
	CreatedAt     time.Time
	UpdatedAt     time.Time
	LikeCount     int32
	CommentCount  int32
	RepostCount   int32
	BookmarkCount int32
	IsDeleted     bool
}

type PostRepository struct {
	db *sql.DB
}

func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

func (r *PostRepository) Create(post *Post) error {
	post.ID = uuid.New().String()
	post.CreatedAt = time.Now()
	post.UpdatedAt = time.Now()

	_, err := r.db.Exec(`
		INSERT INTO posts (id, author_id, post_type, title, content, media_urls, expires_at, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`, post.ID, post.AuthorID, post.PostType, post.Title, post.Content, pq.Array(post.MediaURLs), post.ExpiresAt, post.CreatedAt, post.UpdatedAt)
	return err
}

func (r *PostRepository) GetByID(id string) (*Post, error) {
	post := &Post{}
	var title, content sql.NullString
	var expiresAt sql.NullTime

	err := r.db.QueryRow(`
		SELECT id, author_id, post_type, title, content, media_urls, expires_at, created_at, updated_at,
		       like_count, comment_count, repost_count, bookmark_count, is_deleted
		FROM posts WHERE id = $1 AND is_deleted = false
	`, id).Scan(
		&post.ID, &post.AuthorID, &post.PostType, &title, &content, pq.Array(&post.MediaURLs),
		&expiresAt, &post.CreatedAt, &post.UpdatedAt, &post.LikeCount, &post.CommentCount,
		&post.RepostCount, &post.BookmarkCount, &post.IsDeleted,
	)
	if err == sql.ErrNoRows {
		return nil, ErrPostNotFound
	}
	if err != nil {
		return nil, err
	}

	post.Title = title.String
	post.Content = content.String
	if expiresAt.Valid {
		post.ExpiresAt = &expiresAt.Time
	}
	return post, nil
}

func (r *PostRepository) List(authorID string, postType int32, limit, offset int) ([]*Post, int, error) {
	query := `SELECT COUNT(*) FROM posts WHERE is_deleted = false`
	args := []interface{}{}
	argIdx := 1

	if authorID != "" {
		query += ` AND author_id = $` + string(rune('0'+argIdx))
		args = append(args, authorID)
		argIdx++
	}
	if postType > 0 {
		query += ` AND post_type = $` + string(rune('0'+argIdx))
		args = append(args, postType)
	}

	var total int
	r.db.QueryRow(query, args...).Scan(&total)

	// 简化查询
	rows, err := r.db.Query(`
		SELECT id, author_id, post_type, title, content, media_urls, expires_at, created_at, updated_at,
		       like_count, comment_count, repost_count, bookmark_count, is_deleted
		FROM posts WHERE is_deleted = false
		ORDER BY created_at DESC LIMIT $1 OFFSET $2
	`, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var posts []*Post
	for rows.Next() {
		post := &Post{}
		var title, content sql.NullString
		var expiresAt sql.NullTime
		rows.Scan(
			&post.ID, &post.AuthorID, &post.PostType, &title, &content, pq.Array(&post.MediaURLs),
			&expiresAt, &post.CreatedAt, &post.UpdatedAt, &post.LikeCount, &post.CommentCount,
			&post.RepostCount, &post.BookmarkCount, &post.IsDeleted,
		)
		post.Title = title.String
		post.Content = content.String
		if expiresAt.Valid {
			post.ExpiresAt = &expiresAt.Time
		}
		posts = append(posts, post)
	}
	return posts, total, nil
}

func (r *PostRepository) Update(post *Post) error {
	post.UpdatedAt = time.Now()
	_, err := r.db.Exec(`
		UPDATE posts SET title = $1, content = $2, media_urls = $3, updated_at = $4
		WHERE id = $5 AND is_deleted = false
	`, post.Title, post.Content, pq.Array(post.MediaURLs), post.UpdatedAt, post.ID)
	return err
}

func (r *PostRepository) Delete(id string) error {
	_, err := r.db.Exec(`UPDATE posts SET is_deleted = true, updated_at = $1 WHERE id = $2`, time.Now(), id)
	return err
}
