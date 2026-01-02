package repository

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type LikeRepository struct {
	db *sql.DB
}

func NewLikeRepository(db *sql.DB) *LikeRepository {
	return &LikeRepository{db: db}
}

func (r *LikeRepository) Create(userID, postID string) error {
	_, err := r.db.Exec(`
		INSERT INTO likes (id, user_id, post_id, created_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, post_id) DO NOTHING
	`, uuid.New().String(), userID, postID, time.Now())
	if err == nil {
		r.db.Exec(`UPDATE posts SET like_count = like_count + 1 WHERE id = $1`, postID)
	}
	return err
}

func (r *LikeRepository) Delete(userID, postID string) error {
	result, err := r.db.Exec(`DELETE FROM likes WHERE user_id = $1 AND post_id = $2`, userID, postID)
	if err == nil {
		if rows, _ := result.RowsAffected(); rows > 0 {
			r.db.Exec(`UPDATE posts SET like_count = GREATEST(like_count - 1, 0) WHERE id = $1`, postID)
		}
	}
	return err
}

func (r *LikeRepository) Exists(userID, postID string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(`SELECT EXISTS(SELECT 1 FROM likes WHERE user_id = $1 AND post_id = $2)`, userID, postID).Scan(&exists)
	return exists, err
}
