package id

import (
	"errors"
	"sync"
	"time"
)

// 雪花 ID 配置
const (
	// 起始时间戳 (2024-01-01 00:00:00 UTC)
	epoch int64 = 1704067200000

	// 各部分位数
	timestampBits  = 41
	datacenterBits = 5
	workerBits     = 5
	sequenceBits   = 12

	// 最大值
	maxDatacenterID = -1 ^ (-1 << datacenterBits)
	maxWorkerID     = -1 ^ (-1 << workerBits)
	maxSequence     = -1 ^ (-1 << sequenceBits)

	// 位移
	workerShift     = sequenceBits
	datacenterShift = sequenceBits + workerBits
	timestampShift  = sequenceBits + workerBits + datacenterBits
)

// 雪花 ID 错误
var (
	ErrInvalidDatacenterID = errors.New("datacenter ID 超出范围")
	ErrInvalidWorkerID     = errors.New("worker ID 超出范围")
	ErrClockMovedBackward  = errors.New("时钟回拨")
)

// Snowflake 雪花 ID 生成器
type Snowflake struct {
	mu           sync.Mutex
	datacenterID int64
	workerID     int64
	sequence     int64
	lastTime     int64
}

// NewSnowflake 创建雪花 ID 生成器
func NewSnowflake(datacenterID, workerID int64) (*Snowflake, error) {
	if datacenterID < 0 || datacenterID > maxDatacenterID {
		return nil, ErrInvalidDatacenterID
	}
	if workerID < 0 || workerID > maxWorkerID {
		return nil, ErrInvalidWorkerID
	}

	return &Snowflake{
		datacenterID: datacenterID,
		workerID:     workerID,
	}, nil
}

// MustNewSnowflake 创建雪花 ID 生成器，失败时 panic
func MustNewSnowflake(datacenterID, workerID int64) *Snowflake {
	sf, err := NewSnowflake(datacenterID, workerID)
	if err != nil {
		panic(err)
	}
	return sf
}


// Generate 生成雪花 ID
func (s *Snowflake) Generate() (int64, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := time.Now().UnixMilli()

	// 时钟回拨检测
	if now < s.lastTime {
		return 0, ErrClockMovedBackward
	}

	if now == s.lastTime {
		// 同一毫秒内，序列号递增
		s.sequence = (s.sequence + 1) & maxSequence
		if s.sequence == 0 {
			// 序列号溢出，等待下一毫秒
			now = s.waitNextMillis(s.lastTime)
		}
	} else {
		// 新的毫秒，重置序列号
		s.sequence = 0
	}

	s.lastTime = now

	// 组装 ID
	id := ((now - epoch) << timestampShift) |
		(s.datacenterID << datacenterShift) |
		(s.workerID << workerShift) |
		s.sequence

	return id, nil
}

// MustGenerate 生成雪花 ID，失败时 panic
func (s *Snowflake) MustGenerate() int64 {
	id, err := s.Generate()
	if err != nil {
		panic(err)
	}
	return id
}

// waitNextMillis 等待下一毫秒
func (s *Snowflake) waitNextMillis(lastTime int64) int64 {
	now := time.Now().UnixMilli()
	for now <= lastTime {
		time.Sleep(time.Microsecond * 100)
		now = time.Now().UnixMilli()
	}
	return now
}

// ParseSnowflake 解析雪花 ID
func ParseSnowflake(id int64) (timestamp time.Time, datacenterID, workerID, sequence int64) {
	timestamp = time.UnixMilli(((id >> timestampShift) & ((1 << timestampBits) - 1)) + epoch)
	datacenterID = (id >> datacenterShift) & maxDatacenterID
	workerID = (id >> workerShift) & maxWorkerID
	sequence = id & maxSequence
	return
}

// ---- 全局雪花 ID 生成器 ----

var (
	globalSnowflake *Snowflake
	snowflakeOnce   sync.Once
)

// InitGlobalSnowflake 初始化全局雪花 ID 生成器
func InitGlobalSnowflake(datacenterID, workerID int64) error {
	var err error
	snowflakeOnce.Do(func() {
		globalSnowflake, err = NewSnowflake(datacenterID, workerID)
	})
	return err
}

// NewSnowflakeID 使用全局生成器生成雪花 ID
func NewSnowflakeID() (int64, error) {
	if globalSnowflake == nil {
		// 默认初始化
		InitGlobalSnowflake(1, 1)
	}
	return globalSnowflake.Generate()
}

// MustSnowflakeID 使用全局生成器生成雪花 ID，失败时 panic
func MustSnowflakeID() int64 {
	id, err := NewSnowflakeID()
	if err != nil {
		panic(err)
	}
	return id
}
