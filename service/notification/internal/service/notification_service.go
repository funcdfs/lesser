package service

import "github.com/lesser/notification/internal/repository"

type NotificationService struct {
	notifRepo *repository.NotificationRepository
}

func NewNotificationService(notifRepo *repository.NotificationRepository) *NotificationService {
	return &NotificationService{notifRepo: notifRepo}
}

func (s *NotificationService) Create(userID string, notifType int32, actorID, targetID, content string) (*repository.Notification, error) {
	notif := &repository.Notification{
		UserID:   userID,
		Type:     notifType,
		ActorID:  actorID,
		TargetID: targetID,
		Content:  content,
	}
	if err := s.notifRepo.Create(notif); err != nil {
		return nil, err
	}
	return notif, nil
}

func (s *NotificationService) List(userID string, limit, offset int) ([]*repository.Notification, int, error) {
	if limit <= 0 {
		limit = 20
	}
	return s.notifRepo.List(userID, limit, offset)
}

func (s *NotificationService) MarkAsRead(id string) error {
	return s.notifRepo.MarkAsRead(id)
}

func (s *NotificationService) MarkAllAsRead(userID string) (int64, error) {
	return s.notifRepo.MarkAllAsRead(userID)
}

func (s *NotificationService) GetUnreadCount(userID string) (int64, error) {
	return s.notifRepo.GetUnreadCount(userID)
}
