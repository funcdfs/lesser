package handler

import (
	"strconv"

	"github.com/funcdfs/lesser/chat/internal/repository"
	pb "github.com/funcdfs/lesser/chat/proto/chat"
	"github.com/funcdfs/lesser/chat/proto/common"
)

// conversationToProto 将会话实体转换为 Proto
func conversationToProto(conv *repository.Conversation) *pb.Conversation {
	memberIDs := make([]string, len(conv.Members))
	for i, m := range conv.Members {
		memberIDs[i] = m.UserID.String()
	}

	protoConv := &pb.Conversation{
		Id:        conv.ID.String(),
		Type:      conversationTypeToProto(conv.Type),
		Name:      conv.Name,
		MemberIds: memberIDs,
		CreatorId: conv.CreatorID.String(),
		CreatedAt: &common.Timestamp{
			Seconds: conv.CreatedAt.Unix(),
			Nanos:   int32(conv.CreatedAt.Nanosecond()),
		},
		UnreadCount: int64(conv.UnreadCount),
	}

	if conv.LastMessage != nil {
		protoConv.LastMessage = messageToProto(conv.LastMessage)
	}

	return protoConv
}

// messageToProto 将消息实体转换为 Proto
func messageToProto(msg *repository.Message) *pb.Message {
	protoMsg := &pb.Message{
		Id:             strconv.FormatInt(msg.ID, 10),
		ConversationId: msg.DialogID.String(),
		SenderId:       msg.SenderID.String(),
		Content:        msg.Content,
		MessageType:    msg.MsgType.String(),
		CreatedAt: &common.Timestamp{
			Seconds: msg.Date.Unix(),
			Nanos:   int32(msg.Date.Nanosecond()),
		},
	}

	// 已读时间（如果有）
	if msg.EditDate.Valid {
		protoMsg.ReadAt = &common.Timestamp{
			Seconds: msg.EditDate.Time.Unix(),
			Nanos:   int32(msg.EditDate.Time.Nanosecond()),
		}
	}

	return protoMsg
}

// conversationTypeToProto 将会话类型转换为 Proto
func conversationTypeToProto(t repository.ConversationType) pb.ConversationType {
	switch t {
	case repository.ConversationTypePrivate:
		return pb.ConversationType_PRIVATE
	case repository.ConversationTypeGroup:
		return pb.ConversationType_GROUP
	case repository.ConversationTypeChannel:
		return pb.ConversationType_CHANNEL
	default:
		return pb.ConversationType_PRIVATE
	}
}

// protoToConversationType 将 Proto 会话类型转换为实体
func protoToConversationType(t pb.ConversationType) repository.ConversationType {
	switch t {
	case pb.ConversationType_PRIVATE:
		return repository.ConversationTypePrivate
	case pb.ConversationType_GROUP:
		return repository.ConversationTypeGroup
	case pb.ConversationType_CHANNEL:
		return repository.ConversationTypeChannel
	default:
		return repository.ConversationTypePrivate
	}
}

// parseMessageType 解析消息类型字符串
func parseMessageType(s string) repository.MessageType {
	return repository.ParseMessageType(s)
}
