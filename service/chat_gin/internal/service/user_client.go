package service

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/google/uuid"
)

// UserInfo represents user information from auth service
type UserInfo struct {
	ID          string  `json:"id"`
	Username    string  `json:"username"`
	Email       string  `json:"email"`
	DisplayName *string `json:"display_name"`
	AvatarURL   *string `json:"avatar_url"`
	Bio         *string `json:"bio"`
}

// UserClient handles communication with the auth/user service
type UserClient struct {
	baseURL    string
	httpClient *http.Client
}

// NewUserClient creates a new UserClient
func NewUserClient(baseURL string) *UserClient {
	return &UserClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// GetUser fetches user info by ID
func (c *UserClient) GetUser(ctx context.Context, userID uuid.UUID) (*UserInfo, error) {
	url := fmt.Sprintf("%s/api/v1/users/%s/", c.baseURL, userID.String())

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch user: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		return nil, fmt.Errorf("user not found: %s", userID)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	var user UserInfo
	if err := json.NewDecoder(resp.Body).Decode(&user); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &user, nil
}

// GetUsers fetches multiple users by IDs
func (c *UserClient) GetUsers(ctx context.Context, userIDs []uuid.UUID) (map[uuid.UUID]*UserInfo, error) {
	result := make(map[uuid.UUID]*UserInfo)

	// Fetch users in parallel with a simple approach
	// In production, consider using a batch endpoint
	for _, userID := range userIDs {
		user, err := c.GetUser(ctx, userID)
		if err != nil {
			// Log error but continue - user might have been deleted
			fmt.Printf("Warning: failed to fetch user %s: %v\n", userID, err)
			continue
		}
		result[userID] = user
	}

	return result, nil
}
