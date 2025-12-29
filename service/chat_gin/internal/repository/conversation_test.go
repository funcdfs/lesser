package repository

import (
	"context"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/google/uuid"
	"github.com/lesser/chat/internal/model"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// setupMockDB 创建 mock 数据库连接
func setupMockDB(t *testing.T) (*gorm.DB, sqlmock.Sqlmock) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("failed to create sqlmock: %v", err)
	}

	dialector := postgres.New(postgres.Config{
		Conn:       db,
		DriverName: "postgres",
	})

	gormDB, err := gorm.Open(dialector, &gorm.Config{})
	if err != nil {
		t.Fatalf("failed to open gorm db: %v", err)
	}

	return gormDB, mock
}

func TestNewConversationRepository(t *testing.T) {
	db, _ := setupMockDB(t)
	repo := NewConversationRepository(db)

	if repo == nil {
		t.Error("NewConversationRepository() returned nil")
	}
	if repo.db != db {
		t.Error("NewConversationRepository() db mismatch")
	}
}

func TestConversationRepository_GetByID(t *testing.T) {
	db, mock := setupMockDB(t)
	repo := NewConversationRepository(db)

	convID := uuid.New()
	creatorID := uuid.New()
	now := time.Now()

	// Mock conversation query - GORM adds ORDER BY and LIMIT
	convRows := sqlmock.NewRows([]string{"id", "type", "name", "creator_id", "created_at", "updated_at"}).
		AddRow(convID, "private", "Test Conv", creatorID, now, now)

	mock.ExpectQuery(`SELECT \* FROM "chat_conversations" WHERE id = \$1`).
		WithArgs(convID, 1). // GORM adds LIMIT 1
		WillReturnRows(convRows)

	// Mock members query
	memberRows := sqlmock.NewRows([]string{"conversation_id", "user_id", "role", "joined_at"}).
		AddRow(convID, creatorID, "owner", now)

	mock.ExpectQuery(`SELECT \* FROM "chat_conversation_members" WHERE "chat_conversation_members"."conversation_id" = \$1`).
		WithArgs(convID).
		WillReturnRows(memberRows)

	conv, err := repo.GetByID(context.Background(), convID)
	if err != nil {
		t.Errorf("GetByID() error = %v", err)
		return
	}

	if conv.ID != convID {
		t.Errorf("GetByID() ID = %v, want %v", conv.ID, convID)
	}
}

func TestConversationRepository_GetByID_NotFound(t *testing.T) {
	db, mock := setupMockDB(t)
	repo := NewConversationRepository(db)

	convID := uuid.New()

	mock.ExpectQuery(`SELECT \* FROM "chat_conversations" WHERE id = \$1`).
		WithArgs(convID, 1). // GORM adds LIMIT 1
		WillReturnRows(sqlmock.NewRows([]string{}))

	_, err := repo.GetByID(context.Background(), convID)
	if err != ErrNotFound {
		t.Errorf("GetByID() error = %v, want ErrNotFound", err)
	}
}

func TestConversationRepository_IsMember(t *testing.T) {
	db, mock := setupMockDB(t)
	repo := NewConversationRepository(db)

	convID := uuid.New()
	userID := uuid.New()

	// 测试是成员的情况
	mock.ExpectQuery(`SELECT count\(\*\) FROM "chat_conversation_members"`).
		WithArgs(convID, userID).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(1))

	isMember, err := repo.IsMember(context.Background(), convID, userID)
	if err != nil {
		t.Errorf("IsMember() error = %v", err)
		return
	}
	if !isMember {
		t.Error("IsMember() = false, want true")
	}

	// 测试不是成员的情况
	mock.ExpectQuery(`SELECT count\(\*\) FROM "chat_conversation_members"`).
		WithArgs(convID, userID).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(0))

	isMember, err = repo.IsMember(context.Background(), convID, userID)
	if err != nil {
		t.Errorf("IsMember() error = %v", err)
		return
	}
	if isMember {
		t.Error("IsMember() = true, want false")
	}
}

func TestConversationRepository_GetMemberIDs(t *testing.T) {
	db, mock := setupMockDB(t)
	repo := NewConversationRepository(db)

	convID := uuid.New()
	user1 := uuid.New()
	user2 := uuid.New()

	rows := sqlmock.NewRows([]string{"conversation_id", "user_id", "role", "joined_at"}).
		AddRow(convID, user1, "owner", time.Now()).
		AddRow(convID, user2, "member", time.Now())

	mock.ExpectQuery(`SELECT "user_id" FROM "chat_conversation_members" WHERE conversation_id = \$1`).
		WithArgs(convID).
		WillReturnRows(rows)

	ids, err := repo.GetMemberIDs(context.Background(), convID)
	if err != nil {
		t.Errorf("GetMemberIDs() error = %v", err)
		return
	}

	if len(ids) != 2 {
		t.Errorf("GetMemberIDs() returned %d IDs, want 2", len(ids))
	}
}

func TestConversationRepository_UpdateTimestamp(t *testing.T) {
	db, mock := setupMockDB(t)
	repo := NewConversationRepository(db)

	convID := uuid.New()

	mock.ExpectBegin()
	mock.ExpectExec(`UPDATE "chat_conversations" SET "updated_at"=NOW\(\) WHERE id = \$1`).
		WithArgs(convID).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	err := repo.UpdateTimestamp(context.Background(), convID)
	if err != nil {
		t.Errorf("UpdateTimestamp() error = %v", err)
	}
}

// 测试 model 常量
func TestMemberRoleConstants(t *testing.T) {
	if model.MemberRoleOwner != "owner" {
		t.Errorf("MemberRoleOwner = %v, want owner", model.MemberRoleOwner)
	}
	if model.MemberRoleAdmin != "admin" {
		t.Errorf("MemberRoleAdmin = %v, want admin", model.MemberRoleAdmin)
	}
	if model.MemberRoleMember != "member" {
		t.Errorf("MemberRoleMember = %v, want member", model.MemberRoleMember)
	}
}
