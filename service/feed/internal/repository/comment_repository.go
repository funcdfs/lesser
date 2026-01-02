package repository

import (
	"database/sql"
	"errors"
	"time"

	"github.com/google/uuid"
)

var ErrCommentNotFound = errors.New("comment not found")

type Comment struct {
	ID         string
	AuthorID   string
	PostID     string
	ParentID   string
	Content    string
	IsDeleted  bool
	CreatedAt  time.Time
	UpdatedAt  time.Time
	ReplyCount int32
}

type CommentRepository struct {
	db *sql.DB
}

func NewCommentRepository(db *sql.DB) *CommentRepository {
	return &CommentRepository{db: db}
}

func (r *CommentRepository) Create(comment *Comment) error {
	comment.ID = uuid.New().String()
	comment.CreatedAt = time.Now()
	comment.UpdatedAt = time.Now()

	_, err := r.db.Exec(`
		INSERT INTO comments (id, author_id, post_id, parent_id, content, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`, comment.ID, comment.AuthorID, comment.PostID, nullString(comment.ParentID), comment.Content, comment.CreatedAt, comment.UpdatedAt)

	if err == nil {
		r.db.Exec(`UPDATE posts SET comment_count = comment_count + 1 WHERE id = $1`, comment.PostID)
		if comment.ParentID != "" {
			r.db.Exec(`UPDATE comments SET reply_count = reply_count + 1 WHERE id = $1`, comment.ParentID)
		}
	}
	return err
}

func (r *CommentRepository) GetByID(id string) (*Comment, error) {
	comment := &Comment{}
	var parentID sql.NullString

	err := r.db.QueryRow(`
		SELECT id, author_id, post_id, parent_id, content, is_deleted, created_at, updated_at, reply_count
		FROM comments WHERE id = $1
	`, id).Scan(&comment.ID, &comment.AuthorID, &comment.PostID, &parentID, &comment.Content, &comment.IsDeleted, &comment.CreatedAt, &comment.UpdatedAt, &comment.ReplyCount)
	if err == sql.ErrNoRows {
		return nil, ErrCommentNotFound
	}
	comment.ParentID = parentID.String
	return comment, err
}

func (r *CommentRepository) List(postID, parentID string, limit, offset int) ([]*Comment, int, error) {
	var total int
	query := `SELECT COUNT(*) FROM comments WHERE post_id = $1 AND is_deleted = false`
	args := []interface{}{postID}
	if parentID != "" {
		query += ` AND parent_id = $2`
		args = append(args, parentID)
	} else {
		query += ` AND parent_id IS NULL`
	}
	r.db.QueryRow(query, args...).Scan(&total)

	listQuery := `
		SELECT id, author_id, post_id, parent_id, content, is_deleted, created_at, updated_at, reply_count
		FROM comments WHERE post_id = $1 AND is_deleted = false`
	listArgs := []interface{}{postID}
	if parentID != "" {
		listQuery += ` AND parent_id = $2 ORDER BY created_at ASC LIMIT $3 OFFSET $4`
		listArgs = append(listArgs, parentID, limit, offset)
	} else {
		listQuery += ` AND parent_id IS NULL ORDER BY created_at DESC LIMIT $2 OFFSET $3`
		listArgs = append(listArgs, limit, offset)
	}

	rows, err := r.db.Query(listQuery, listArgs...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var comments []*Comment
	for rows.Next() {
		c := &Comment{}
		var parentID sql.NullString
		rows.Scan(&c.ID, &c.AuthorID, &c.PostID, &parentID, &c.Content, &c.IsDeleted, &c.CreatedAt, &c.UpdatedAt, &c.ReplyCount)
		c.ParentID = parentID.String
		comments = append(comments, c)
	}
	return comments, total, nil
}

func (r *CommentRepository) Delete(id string) error {
	_, err := r.db.Exec(`UPDATE comments SET is_deleted = true, updated_at = $1 WHERE id = $2`, time.Now(), id)
	return err
}

func nullString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{}
	}
	return sql.NullString{String: s, Valid: true}
}
