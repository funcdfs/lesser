package repository

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Notification struct {
	ID        string
	UserID    string
	Type      int32
	ActorID   string
	TargetID  string
	Content   string
	IsRead    bool
	CreatedAt time.Time
}

type NotificationRepository struct {
	db *sql.DB
}

func NewNotificationRepository(db *sql.DB) *NotificationRepository {
	return &NotificationRepository{db: db}
}

func (r *NotificationRepository) Create(notif *Notification) error {
	notif.ID = uuid.New().String()
	notif.CreatedAt = time.Now()
	_, err := r.db.Exec(`
		INSERT INTO notifications (id, user_id, type, actor_id, target_id, content, is_read, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`, notif.ID, notif.UserID, notif.Type, notif.ActorID, notif.TargetID, notif.Content, notif.IsRead, notif.CreatedAt)
	return err
}

func (r *NotificationRepository) List(userID string, limit, offset int) ([]*Notification, int, error) {
	var total int
	r.db.QueryRow(`SELECT COUNT(*) FROM notifications WHERE user_id = $1`, userID).Scan(&total)

	rows, err := r.db.Query(`
		SELECT id, user_id, type, actor_id, target_id, content, is_read, created_at
		FROM notifications WHERE user_id = $1
		ORDER BY created_at DESC LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var notifications []*Notification
	for rows.Next() {
		n := &Notification{}
		var actorID, targetID, content sql.NullString
		rows.Scan(&n.ID, &n.UserID, &n.Type, &actorID, &targetID, &content, &n.IsRead, &n.CreatedAt)
		n.ActorID = actorID.String
		n.TargetID = targetID.String
		n.Content = content.String
		notifications = append(notifications, n)
	}
	return notifications, total, nil
}

func (r *NotificationRepository) MarkAsRead(id string) error {
	_, err := r.db.Exec(`UPDATE notifications SET is_read = true WHERE id = $1`, id)
	return err
}

func (r *NotificationRepository) MarkAllAsRead(userID string) (int64, error) {
	result, err := r.db.Exec(`UPDATE notifications SET is_read = true WHERE user_id = $1 AND is_read = false`, userID)
	if err != nil {
		return 0, err
	}
	return result.RowsAffected()
}

func (r *NotificationRepository) GetUnreadCount(userID string) (int64, error) {
	var count int64
	err := r.db.QueryRow(`SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false`, userID).Scan(&count)
	return count, err
}
