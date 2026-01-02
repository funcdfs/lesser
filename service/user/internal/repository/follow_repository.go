package repository

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Follow struct {
	ID          string
	FollowerID  string
	FollowingID string
	CreatedAt   time.Time
}

type FollowRepository struct {
	db *sql.DB
}

func NewFollowRepository(db *sql.DB) *FollowRepository {
	return &FollowRepository{db: db}
}

func (r *FollowRepository) Create(followerID, followingID string) error {
	_, err := r.db.Exec(`
		INSERT INTO follows (id, follower_id, following_id, created_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (follower_id, following_id) DO NOTHING
	`, uuid.New().String(), followerID, followingID, time.Now())
	return err
}

func (r *FollowRepository) Delete(followerID, followingID string) error {
	_, err := r.db.Exec(`
		DELETE FROM follows WHERE follower_id = $1 AND following_id = $2
	`, followerID, followingID)
	return err
}

func (r *FollowRepository) Exists(followerID, followingID string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(`
		SELECT EXISTS(SELECT 1 FROM follows WHERE follower_id = $1 AND following_id = $2)
	`, followerID, followingID).Scan(&exists)
	return exists, err
}

func (r *FollowRepository) GetFollowers(userID string, limit, offset int) ([]*User, int, error) {
	var total int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM follows WHERE following_id = $1`, userID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(`
		SELECT u.id, u.username, u.email, u.display_name, u.avatar_url, u.bio, u.is_verified,
		       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at
		FROM users u
		JOIN follows f ON u.id = f.follower_id
		WHERE f.following_id = $1
		ORDER BY f.created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanUsers(rows), total, nil
}

func (r *FollowRepository) GetFollowing(userID string, limit, offset int) ([]*User, int, error) {
	var total int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM follows WHERE follower_id = $1`, userID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(`
		SELECT u.id, u.username, u.email, u.display_name, u.avatar_url, u.bio, u.is_verified,
		       u.followers_count, u.following_count, u.posts_count, u.created_at, u.updated_at
		FROM users u
		JOIN follows f ON u.id = f.following_id
		WHERE f.follower_id = $1
		ORDER BY f.created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	return scanUsers(rows), total, nil
}

func scanUsers(rows *sql.Rows) []*User {
	var users []*User
	for rows.Next() {
		user := &User{}
		var displayName, avatarURL, bio sql.NullString
		rows.Scan(
			&user.ID, &user.Username, &user.Email, &displayName, &avatarURL, &bio,
			&user.IsVerified, &user.FollowersCount, &user.FollowingCount, &user.PostsCount,
			&user.CreatedAt, &user.UpdatedAt,
		)
		user.DisplayName = displayName.String
		user.AvatarURL = avatarURL.String
		user.Bio = bio.String
		users = append(users, user)
	}
	return users
}
