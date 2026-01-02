package repository

import (
	"database/sql"
	"errors"
	"time"
)

var ErrUserNotFound = errors.New("user not found")

type User struct {
	ID             string
	Username       string
	Email          string
	DisplayName    string
	AvatarURL      string
	Bio            string
	IsVerified     bool
	FollowersCount int32
	FollowingCount int32
	PostsCount     int32
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) GetByID(id string) (*User, error) {
	user := &User{}
	var displayName, avatarURL, bio sql.NullString

	err := r.db.QueryRow(`
		SELECT id, username, email, display_name, avatar_url, bio, is_verified,
		       followers_count, following_count, posts_count, created_at, updated_at
		FROM users WHERE id = $1
	`, id).Scan(
		&user.ID, &user.Username, &user.Email, &displayName, &avatarURL, &bio,
		&user.IsVerified, &user.FollowersCount, &user.FollowingCount, &user.PostsCount,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, ErrUserNotFound
	}
	if err != nil {
		return nil, err
	}

	user.DisplayName = displayName.String
	user.AvatarURL = avatarURL.String
	user.Bio = bio.String
	return user, nil
}

func (r *UserRepository) Update(user *User) error {
	_, err := r.db.Exec(`
		UPDATE users SET display_name = $1, avatar_url = $2, bio = $3, updated_at = $4
		WHERE id = $5
	`, user.DisplayName, user.AvatarURL, user.Bio, time.Now(), user.ID)
	return err
}

func (r *UserRepository) IncrementFollowersCount(userID string) error {
	_, err := r.db.Exec(`UPDATE users SET followers_count = followers_count + 1 WHERE id = $1`, userID)
	return err
}

func (r *UserRepository) DecrementFollowersCount(userID string) error {
	_, err := r.db.Exec(`UPDATE users SET followers_count = GREATEST(followers_count - 1, 0) WHERE id = $1`, userID)
	return err
}

func (r *UserRepository) IncrementFollowingCount(userID string) error {
	_, err := r.db.Exec(`UPDATE users SET following_count = following_count + 1 WHERE id = $1`, userID)
	return err
}

func (r *UserRepository) DecrementFollowingCount(userID string) error {
	_, err := r.db.Exec(`UPDATE users SET following_count = GREATEST(following_count - 1, 0) WHERE id = $1`, userID)
	return err
}
