package handler

import (
	pb "github.com/funcdfs/lesser/chat/gen_protos/chat"
	"github.com/funcdfs/lesser/chat/internal/data_access"
	"github.com/funcdfs/lesser/pkg/gen_protos/common"
)

// conversationToProto 将会话实体转换为 Proto
func conversationToProto(conv *data_access.Conversation) *pb.Conversation {
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
func messageToProto(msg *data_access.Message) *pb.Message {
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
func messageTypeToString(t data_access.MessageType) string {
	switch t {
	case data_access.MessageTypeText:
		return "text"
	case data_access.MessageTypeImage:
		return "image"
	case data_access.MessageTypeVideo:
		return "video"
	case data_access.MessageTypeFile:
		return "file"
	case data_access.MessageTypeSystem:
		return "system"
	default:
		return "text"
	}
}

// conversationTypeToProto 将会话类型转换为 Proto
func conversationTypeToProto(t data_access.ConversationType) pb.ConversationType {
	switch t {
	case data_access.ConversationTypePrivate:
		return pb.ConversationType_PRIVATE
	case data_access.ConversationTypeGroup:
		return pb.ConversationType_GROUP
	default:
		return pb.ConversationType_PRIVATE
	}
}

// protoToConversationType 将 Proto 会话类型转换为实体
// 注意：CHANNEL 类型已迁移到独立的 Channel 服务，此处返回 ConversationTypeChannel 用于错误处理
func protoToConversationType(t pb.ConversationType) data_access.ConversationType {
	switch t {
	case pb.ConversationType_PRIVATE:
		return data_access.ConversationTypePrivate
	case pb.ConversationType_GROUP:
		return data_access.ConversationTypeGroup
	default:
		return data_access.ConversationTypePrivate
	}
}

// parseMessageType 解析消息类型字符串
func parseMessageType(s string) data_access.MessageType {
	switch s {
	case "text":
		return data_access.MessageTypeText
	case "image":
		return data_access.MessageTypeImage
	case "video":
		return data_access.MessageTypeVideo
	case "file":
		return data_access.MessageTypeFile
	case "system":
		return data_access.MessageTypeSystem
	default:
		return data_access.MessageTypeText
	}
}
