package cache

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

// RedisClient wraps the Redis client with helper methods
type RedisClient struct {
	client *redis.Client
}

// NewRedis creates a new Redis client
func NewRedis(redisURL string) (*RedisClient, error) {
	if redisURL == "" {
		return nil, fmt.Errorf("redis URL is required")
	}

	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse redis URL: %w", err)
	}

	client := redis.NewClient(opt)

	// Test connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("failed to ping redis: %w", err)
	}

	return &RedisClient{client: client}, nil
}

// Close closes the Redis connection
func (r *RedisClient) Close() error {
	return r.client.Close()
}

// Set stores a value with optional expiration
func (r *RedisClient) Set(ctx context.Context, key string, value interface{}, expiration time.Duration) error {
	data, err := json.Marshal(value)
	if err != nil {
		return fmt.Errorf("failed to marshal value: %w", err)
	}
	return r.client.Set(ctx, key, data, expiration).Err()
}

// Get retrieves a value and unmarshals it into the target
func (r *RedisClient) Get(ctx context.Context, key string, target interface{}) error {
	data, err := r.client.Get(ctx, key).Bytes()
	if err != nil {
		if err == redis.Nil {
			return ErrKeyNotFound
		}
		return fmt.Errorf("failed to get value: %w", err)
	}
	return json.Unmarshal(data, target)
}

// Delete removes a key
func (r *RedisClient) Delete(ctx context.Context, keys ...string) error {
	return r.client.Del(ctx, keys...).Err()
}

// Exists checks if a key exists
func (r *RedisClient) Exists(ctx context.Context, key string) (bool, error) {
	result, err := r.client.Exists(ctx, key).Result()
	if err != nil {
		return false, err
	}
	return result > 0, nil
}

// SetNX sets a value only if the key doesn't exist (for distributed locks)
func (r *RedisClient) SetNX(ctx context.Context, key string, value interface{}, expiration time.Duration) (bool, error) {
	data, err := json.Marshal(value)
	if err != nil {
		return false, fmt.Errorf("failed to marshal value: %w", err)
	}
	return r.client.SetNX(ctx, key, data, expiration).Result()
}

// Publish publishes a message to a channel
func (r *RedisClient) Publish(ctx context.Context, channel string, message interface{}) error {
	data, err := json.Marshal(message)
	if err != nil {
		return fmt.Errorf("failed to marshal message: %w", err)
	}
	return r.client.Publish(ctx, channel, data).Err()
}

// Subscribe subscribes to a channel
func (r *RedisClient) Subscribe(ctx context.Context, channels ...string) *redis.PubSub {
	return r.client.Subscribe(ctx, channels...)
}

// GetClient returns the underlying Redis client
func (r *RedisClient) GetClient() *redis.Client {
	return r.client
}

// ErrKeyNotFound is returned when a key is not found in Redis
var ErrKeyNotFound = fmt.Errorf("key not found")
