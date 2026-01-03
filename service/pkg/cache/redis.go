package cache

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

// ErrKeyNotFound 键不存在错误
var ErrKeyNotFound = errors.New("key not found")

// Client Redis 客户端封装
type Client struct {
	client *redis.Client
}

// NewClient 创建新的 Redis 客户端
func NewClient(cfg Config) (*Client, error) {
	url := cfg.BuildURL()

	opt, err := redis.ParseURL(url)
	if err != nil {
		return nil, fmt.Errorf("failed to parse redis URL: %w", err)
	}

	// 应用连接池配置
	if cfg.PoolSize > 0 {
		opt.PoolSize = cfg.PoolSize
	}
	if cfg.MinIdleConns > 0 {
		opt.MinIdleConns = cfg.MinIdleConns
	}

	client := redis.NewClient(opt)

	// 测试连接
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("failed to connect to Redis at %s: %w", url, err)
	}

	return &Client{client: client}, nil
}

// Close 关闭 Redis 连接
func (c *Client) Close() error {
	return c.client.Close()
}

// Get 获取值并反序列化到 target
func (c *Client) Get(ctx context.Context, key string, target interface{}) error {
	data, err := c.client.Get(ctx, key).Bytes()
	if err != nil {
		if err == redis.Nil {
			return ErrKeyNotFound
		}
		return fmt.Errorf("redis get failed: %w", err)
	}
	return json.Unmarshal(data, target)
}

// GetString 获取字符串值
func (c *Client) GetString(ctx context.Context, key string) (string, error) {
	result, err := c.client.Get(ctx, key).Result()
	if err != nil {
		if err == redis.Nil {
			return "", ErrKeyNotFound
		}
		return "", fmt.Errorf("redis get failed: %w", err)
	}
	return result, nil
}

// GetBytes 获取字节数组
func (c *Client) GetBytes(ctx context.Context, key string) ([]byte, error) {
	result, err := c.client.Get(ctx, key).Bytes()
	if err != nil {
		if err == redis.Nil {
			return nil, ErrKeyNotFound
		}
		return nil, fmt.Errorf("redis get failed: %w", err)
	}
	return result, nil
}

// Set 序列化并存储值
func (c *Client) Set(ctx context.Context, key string, value interface{}, expiration time.Duration) error {
	data, err := json.Marshal(value)
	if err != nil {
		return fmt.Errorf("failed to marshal value: %w", err)
	}
	return c.client.Set(ctx, key, data, expiration).Err()
}

// SetString 存储字符串值
func (c *Client) SetString(ctx context.Context, key, value string, expiration time.Duration) error {
	return c.client.Set(ctx, key, value, expiration).Err()
}

// SetBytes 存储字节数组
func (c *Client) SetBytes(ctx context.Context, key string, value []byte, expiration time.Duration) error {
	return c.client.Set(ctx, key, value, expiration).Err()
}

// Delete 删除键
func (c *Client) Delete(ctx context.Context, keys ...string) error {
	return c.client.Del(ctx, keys...).Err()
}

// Exists 检查键是否存在
func (c *Client) Exists(ctx context.Context, key string) (bool, error) {
	result, err := c.client.Exists(ctx, key).Result()
	if err != nil {
		return false, fmt.Errorf("redis exists failed: %w", err)
	}
	return result > 0, nil
}

// SetNX 仅当键不存在时设置（用于分布式锁）
func (c *Client) SetNX(ctx context.Context, key string, value interface{}, expiration time.Duration) (bool, error) {
	data, err := json.Marshal(value)
	if err != nil {
		return false, fmt.Errorf("failed to marshal value: %w", err)
	}
	return c.client.SetNX(ctx, key, data, expiration).Result()
}

// GetClient 返回底层 Redis 客户端
func (c *Client) GetClient() *redis.Client {
	return c.client
}

// Publish 发布消息到频道
func (c *Client) Publish(ctx context.Context, channel string, message interface{}) error {
	data, err := json.Marshal(message)
	if err != nil {
		return fmt.Errorf("failed to marshal message: %w", err)
	}
	return c.client.Publish(ctx, channel, data).Err()
}

// PublishString 发布字符串消息到频道
func (c *Client) PublishString(ctx context.Context, channel, message string) error {
	return c.client.Publish(ctx, channel, message).Err()
}

// Subscribe 订阅频道
func (c *Client) Subscribe(ctx context.Context, channels ...string) *redis.PubSub {
	return c.client.Subscribe(ctx, channels...)
}

// ---- Hash 操作 ----

// HGet 获取 Hash 字段值
func (c *Client) HGet(ctx context.Context, key, field string) (string, error) {
	result, err := c.client.HGet(ctx, key, field).Result()
	if err != nil {
		if err == redis.Nil {
			return "", ErrKeyNotFound
		}
		return "", fmt.Errorf("redis hget failed: %w", err)
	}
	return result, nil
}

// HSet 设置 Hash 字段值
func (c *Client) HSet(ctx context.Context, key string, values ...interface{}) error {
	return c.client.HSet(ctx, key, values...).Err()
}

// HGetAll 获取 Hash 所有字段
func (c *Client) HGetAll(ctx context.Context, key string) (map[string]string, error) {
	result, err := c.client.HGetAll(ctx, key).Result()
	if err != nil {
		return nil, fmt.Errorf("redis hgetall failed: %w", err)
	}
	return result, nil
}

// HDel 删除 Hash 字段
func (c *Client) HDel(ctx context.Context, key string, fields ...string) error {
	return c.client.HDel(ctx, key, fields...).Err()
}

// HExists 检查 Hash 字段是否存在
func (c *Client) HExists(ctx context.Context, key, field string) (bool, error) {
	return c.client.HExists(ctx, key, field).Result()
}

// HIncrBy 增加 Hash 字段的整数值
func (c *Client) HIncrBy(ctx context.Context, key, field string, incr int64) (int64, error) {
	return c.client.HIncrBy(ctx, key, field, incr).Result()
}

// ---- List 操作 ----

// LPush 从左侧插入列表
func (c *Client) LPush(ctx context.Context, key string, values ...interface{}) error {
	return c.client.LPush(ctx, key, values...).Err()
}

// RPush 从右侧插入列表
func (c *Client) RPush(ctx context.Context, key string, values ...interface{}) error {
	return c.client.RPush(ctx, key, values...).Err()
}

// LRange 获取列表范围
func (c *Client) LRange(ctx context.Context, key string, start, stop int64) ([]string, error) {
	return c.client.LRange(ctx, key, start, stop).Result()
}

// LLen 获取列表长度
func (c *Client) LLen(ctx context.Context, key string) (int64, error) {
	return c.client.LLen(ctx, key).Result()
}

// LTrim 修剪列表
func (c *Client) LTrim(ctx context.Context, key string, start, stop int64) error {
	return c.client.LTrim(ctx, key, start, stop).Err()
}

// ---- Set 操作 ----

// SAdd 添加集合成员
func (c *Client) SAdd(ctx context.Context, key string, members ...interface{}) error {
	return c.client.SAdd(ctx, key, members...).Err()
}

// SRem 移除集合成员
func (c *Client) SRem(ctx context.Context, key string, members ...interface{}) error {
	return c.client.SRem(ctx, key, members...).Err()
}

// SMembers 获取集合所有成员
func (c *Client) SMembers(ctx context.Context, key string) ([]string, error) {
	return c.client.SMembers(ctx, key).Result()
}

// SIsMember 检查是否为集合成员
func (c *Client) SIsMember(ctx context.Context, key string, member interface{}) (bool, error) {
	return c.client.SIsMember(ctx, key, member).Result()
}

// SCard 获取集合大小
func (c *Client) SCard(ctx context.Context, key string) (int64, error) {
	return c.client.SCard(ctx, key).Result()
}

// ---- Sorted Set 操作 ----

// ZAdd 添加有序集合成员
func (c *Client) ZAdd(ctx context.Context, key string, members ...redis.Z) error {
	return c.client.ZAdd(ctx, key, members...).Err()
}

// ZRem 移除有序集合成员
func (c *Client) ZRem(ctx context.Context, key string, members ...interface{}) error {
	return c.client.ZRem(ctx, key, members...).Err()
}

// ZRange 获取有序集合范围（按索引）
func (c *Client) ZRange(ctx context.Context, key string, start, stop int64) ([]string, error) {
	return c.client.ZRange(ctx, key, start, stop).Result()
}

// ZRevRange 获取有序集合范围（按索引，倒序）
func (c *Client) ZRevRange(ctx context.Context, key string, start, stop int64) ([]string, error) {
	return c.client.ZRevRange(ctx, key, start, stop).Result()
}

// ZRangeByScore 获取有序集合范围（按分数）
func (c *Client) ZRangeByScore(ctx context.Context, key string, opt *redis.ZRangeBy) ([]string, error) {
	return c.client.ZRangeByScore(ctx, key, opt).Result()
}

// ZScore 获取成员分数
func (c *Client) ZScore(ctx context.Context, key, member string) (float64, error) {
	result, err := c.client.ZScore(ctx, key, member).Result()
	if err != nil {
		if err == redis.Nil {
			return 0, ErrKeyNotFound
		}
		return 0, err
	}
	return result, nil
}

// ZCard 获取有序集合大小
func (c *Client) ZCard(ctx context.Context, key string) (int64, error) {
	return c.client.ZCard(ctx, key).Result()
}

// ZIncrBy 增加成员分数
func (c *Client) ZIncrBy(ctx context.Context, key string, increment float64, member string) (float64, error) {
	return c.client.ZIncrBy(ctx, key, increment, member).Result()
}

// ---- 计数器操作 ----

// Incr 自增
func (c *Client) Incr(ctx context.Context, key string) (int64, error) {
	return c.client.Incr(ctx, key).Result()
}

// IncrBy 增加指定值
func (c *Client) IncrBy(ctx context.Context, key string, value int64) (int64, error) {
	return c.client.IncrBy(ctx, key, value).Result()
}

// Decr 自减
func (c *Client) Decr(ctx context.Context, key string) (int64, error) {
	return c.client.Decr(ctx, key).Result()
}

// DecrBy 减少指定值
func (c *Client) DecrBy(ctx context.Context, key string, value int64) (int64, error) {
	return c.client.DecrBy(ctx, key, value).Result()
}

// ---- 过期时间操作 ----

// Expire 设置过期时间
func (c *Client) Expire(ctx context.Context, key string, expiration time.Duration) (bool, error) {
	return c.client.Expire(ctx, key, expiration).Result()
}

// ExpireAt 设置过期时间点
func (c *Client) ExpireAt(ctx context.Context, key string, tm time.Time) (bool, error) {
	return c.client.ExpireAt(ctx, key, tm).Result()
}

// TTL 获取剩余过期时间
func (c *Client) TTL(ctx context.Context, key string) (time.Duration, error) {
	return c.client.TTL(ctx, key).Result()
}

// Persist 移除过期时间
func (c *Client) Persist(ctx context.Context, key string) (bool, error) {
	return c.client.Persist(ctx, key).Result()
}

// ---- 批量操作 ----

// MGet 批量获取
func (c *Client) MGet(ctx context.Context, keys ...string) ([]interface{}, error) {
	return c.client.MGet(ctx, keys...).Result()
}

// MSet 批量设置
func (c *Client) MSet(ctx context.Context, values ...interface{}) error {
	return c.client.MSet(ctx, values...).Err()
}

// Pipeline 创建管道
func (c *Client) Pipeline() redis.Pipeliner {
	return c.client.Pipeline()
}

// TxPipeline 创建事务管道
func (c *Client) TxPipeline() redis.Pipeliner {
	return c.client.TxPipeline()
}
