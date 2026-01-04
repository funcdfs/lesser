package handler

import (
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
	content := ""
	if msg.Content.Valid {
		content = msg.Content.String
	}

	protoMsg := &pb.Message{
		Id:             msg.ID.String(),
		ConversationId: msg.ConversationID.String(),
		SenderId:       msg.SenderID.String(),
		Content:        content,
		MessageType:    messageTypeToString(msg.Type),
		CreatedAt: &common.Timestamp{
			Seconds: msg.CreatedAt.Unix(),
			Nanos:   int32(msg.CreatedAt.Nanosecond()),
		},
	}

	return protoMsg
}

// messageTypeToString 将消息类型转换为字符串
func messageTypeToString(t repository.MessageType) string {
	switch t {
	case repository.MessageTypeText:
		return "text"
	case repository.MessageTypeImage:
		return "image"
	case repository.MessageTypeVideo:
		return "video"
	case repository.MessageTypeFile:
		return "file"
	case repository.MessageTypeSystem:
		return "system"
	default:
		return "text"
	}
}

// conversationTypeToProto 将会话类型转换为 Proto
func conversationTypeToProto(t repository.ConversationType) pb.ConversationType {
	switch t {
	case repository.ConversationTypePrivate:
		return pb.ConversationType_PRIVATE
	case repository.ConversationTypeGroup:
		return pb.ConversationType_GROUP
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
	default:
		return repository.ConversationTypePrivate
	}
}

// parseMessageType 解析消息类型字符串
func parseMessageType(s string) repository.MessageType {
	switch s {
	case "text":
		return repository.MessageTypeText
	case "image":
		return repository.MessageTypeImage
	case "video":
		return repository.MessageTypeVideo
	case "file":
		return repository.MessageTypeFile
	case "system":
		return repository.MessageTypeSystem
	default:
		return repository.MessageTypeText
	}
}
