package repository

import (
	"database/sql"
	"time"

	"github.com/lib/pq"
)

type Post struct {
	ID        string
	AuthorID  string
	Title     string
	Content   string
	MediaURLs []string
	CreatedAt time.Time
}

type User struct {
	ID          string
	Username    string
	DisplayName string
	AvatarURL   string
	Bio         string
	CreatedAt   time.Time
}

type SearchRepository struct {
	db *sql.DB
}

func NewSearchRepository(db *sql.DB) *SearchRepository {
	return &SearchRepository{db: db}
}

func (r *SearchRepository) SearchPosts(query string, limit, offset int) ([]*Post, int, error) {
	var total int
	r.db.QueryRow(`
		SELECT COUNT(*) FROM posts 
		WHERE is_deleted = false AND (title ILIKE $1 OR content ILIKE $1)
	`, "%"+query+"%").Scan(&total)

	rows, err := r.db.Query(`
		SELECT id, author_id, title, content, media_urls, created_at
		FROM posts WHERE is_deleted = false AND (title ILIKE $1 OR content ILIKE $1)
		ORDER BY created_at DESC LIMIT $2 OFFSET $3
	`, "%"+query+"%", limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var posts []*Post
	for rows.Next() {
		p := &Post{}
		var title, content sql.NullString
		rows.Scan(&p.ID, &p.AuthorID, &title, &content, pq.Array(&p.MediaURLs), &p.CreatedAt)
		p.Title = title.String
		p.Content = content.String
		posts = append(posts, p)
	}
	return posts, total, nil
}

func (r *SearchRepository) SearchUsers(query string, limit, offset int) ([]*User, int, error) {
	var total int
	r.db.QueryRow(`
		SELECT COUNT(*) FROM users 
		WHERE username ILIKE $1 OR display_name ILIKE $1
	`, "%"+query+"%").Scan(&total)

	rows, err := r.db.Query(`
		SELECT id, username, display_name, avatar_url, bio, created_at
		FROM users WHERE username ILIKE $1 OR display_name ILIKE $1
		ORDER BY created_at DESC LIMIT $2 OFFSET $3
	`, "%"+query+"%", limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var users []*User
	for rows.Next() {
		u := &User{}
		var displayName, avatarURL, bio sql.NullString
		rows.Scan(&u.ID, &u.Username, &displayName, &avatarURL, &bio, &u.CreatedAt)
		u.DisplayName = displayName.String
		u.AvatarURL = avatarURL.String
		u.Bio = bio.String
		users = append(users, u)
	}
	return users, total, nil
}
