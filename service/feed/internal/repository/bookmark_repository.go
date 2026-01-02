package repository

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Bookmark struct {
	ID        string
	UserID    string
	PostID    string
	CreatedAt time.Time
}

type BookmarkRepository struct {
	db *sql.DB
}

func NewBookmarkRepository(db *sql.DB) *BookmarkRepository {
	return &BookmarkRepository{db: db}
}

func (r *BookmarkRepository) Create(userID, postID string) error {
	_, err := r.db.Exec(`
		INSERT INTO bookmarks (id, user_id, post_id, created_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, post_id) DO NOTHING
	`, uuid.New().String(), userID, postID, time.Now())
	if err == nil {
		r.db.Exec(`UPDATE posts SET bookmark_count = bookmark_count + 1 WHERE id = $1`, postID)
	}
	return err
}

func (r *BookmarkRepository) Delete(userID, postID string) error {
	result, err := r.db.Exec(`DELETE FROM bookmarks WHERE user_id = $1 AND post_id = $2`, userID, postID)
	if err == nil {
		if rows, _ := result.RowsAffected(); rows > 0 {
			r.db.Exec(`UPDATE posts SET bookmark_count = GREATEST(bookmark_count - 1, 0) WHERE id = $1`, postID)
		}
	}
	return err
}

func (r *BookmarkRepository) List(userID string, limit, offset int) ([]*Bookmark, int, error) {
	var total int
	r.db.QueryRow(`SELECT COUNT(*) FROM bookmarks WHERE user_id = $1`, userID).Scan(&total)

	rows, err := r.db.Query(`
		SELECT id, user_id, post_id, created_at FROM bookmarks
		WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var bookmarks []*Bookmark
	for rows.Next() {
		b := &Bookmark{}
		rows.Scan(&b.ID, &b.UserID, &b.PostID, &b.CreatedAt)
		bookmarks = append(bookmarks, b)
	}
	return bookmarks, total, nil
}
