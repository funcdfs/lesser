package grpc

// 本文件包含 gRPC 类型定义的存根
// 生产环境中应通过 `make proto` 从 protos/chat/chat.proto 生成这些类型

import (
	"context"

	"google.golang.org/grpc"
)

// ConversationType 会话类型枚举
type ConversationType int32

const (
	ConversationType_PRIVATE ConversationType = 0 // 私聊
	ConversationType_GROUP   ConversationType = 1 // 群聊
	ConversationType_CHANNEL ConversationType = 2 // 频道
)

// Timestamp 时间戳消息
type Timestamp struct {
	Seconds int64 // Unix 秒数
	Nanos   int32 // 纳秒部分
}

// Pagination 分页参数消息
type Pagination struct {
	Page     int32 // 页码
	PageSize int32 // 每页数量
	Total    int32 // 总数
}

// GetPage 获取页码（带空值保护）
func (p *Pagination) GetPage() int32 {
	if p == nil {
		return 0
	}
	return p.Page
}

// GetPageSize 获取每页数量（带空值保护）
func (p *Pagination) GetPageSize() int32 {
	if p == nil {
		return 0
	}
	return p.PageSize
}

// Conversation 会话消息
type Conversation struct {
	Id          string           // 会话ID
	Type        ConversationType // 会话类型
	Name        string           // 会话名称
	MemberIds   []string         // 成员ID列表
	CreatorId   string           // 创建者ID
	CreatedAt   *Timestamp       // 创建时间
	LastMessage *Message         // 最后一条消息
}

// Message 消息实体
type Message struct {
	Id             string     // 消息ID
	ConversationId string     // 所属会话ID
	SenderId       string     // 发送者ID
	Content        string     // 消息内容
	MessageType    string     // 消息类型（text/image/file/system）
	CreatedAt      *Timestamp // 创建时间
	ReadAt         *Timestamp // 已读时间
}

// ReadReceipt 单条消息已读回执
type ReadReceipt struct {
	MessageId      string     // 消息ID
	ConversationId string     // 会话ID
	ReaderId       string     // 阅读者ID
	ReadAt         *Timestamp // 已读时间
}

// BatchReadReceipt 批量已读回执
type BatchReadReceipt struct {
	ConversationId string     // 会话ID
	ReaderId       string     // 阅读者ID
	MessageIds     []string   // 消息ID列表
	ReadAt         *Timestamp // 已读时间
}

// UnreadCount 单个会话的未读数
type UnreadCount struct {
	ConversationId string // 会话ID
	Count          int64  // 未读数
}

// 请求/响应消息定义

// GetConversationsRequest 获取会话列表请求
type GetConversationsRequest struct {
	UserId     string      // 用户ID
	Pagination *Pagination // 分页参数
}

// ConversationsResponse 会话列表响应
type ConversationsResponse struct {
	Conversations []*Conversation // 会话列表
	Pagination    *Pagination     // 分页信息
}

// GetConversationRequest 获取单个会话请求
type GetConversationRequest struct {
	ConversationId string // 会话ID
}

// CreateConversationRequest 创建会话请求
type CreateConversationRequest struct {
	Type      ConversationType // 会话类型
	Name      string           // 会话名称
	MemberIds []string         // 成员ID列表
	CreatorId string           // 创建者ID
}

// GetMessagesRequest 获取消息列表请求
type GetMessagesRequest struct {
	ConversationId string      // 会话ID
	Pagination     *Pagination // 分页参数
}

// MessagesResponse 消息列表响应
type MessagesResponse struct {
	Messages   []*Message  // 消息列表
	Pagination *Pagination // 分页信息
}

// SendMessageRequest 发送消息请求
type SendMessageRequest struct {
	ConversationId string // 会话ID
	SenderId       string // 发送者ID
	Content        string // 消息内容
	MessageType    string // 消息类型
}

// StreamRequest 消息流订阅请求
type StreamRequest struct {
	UserId string // 用户ID
}

// MarkAsReadRequest 标记单条消息已读请求
type MarkAsReadRequest struct {
	MessageId string // 消息ID
	UserId    string // 用户ID
}

// MarkConversationAsReadRequest 标记会话所有消息已读请求
type MarkConversationAsReadRequest struct {
	ConversationId string // 会话ID
	UserId         string // 用户ID
}

// GetUnreadCountsRequest 批量获取未读数请求
type GetUnreadCountsRequest struct {
	UserId          string   // 用户ID
	ConversationIds []string // 会话ID列表
}

// GetUnreadCountsResponse 批量获取未读数响应
type GetUnreadCountsResponse struct {
	UnreadCounts []*UnreadCount // 未读数列表
}

// ChatServiceServer gRPC 聊天服务接口
type ChatServiceServer interface {
	GetConversations(context.Context, *GetConversationsRequest) (*ConversationsResponse, error)
	GetConversation(context.Context, *GetConversationRequest) (*Conversation, error)
	CreateConversation(context.Context, *CreateConversationRequest) (*Conversation, error)
	GetMessages(context.Context, *GetMessagesRequest) (*MessagesResponse, error)
	SendMessage(context.Context, *SendMessageRequest) (*Message, error)
	StreamMessages(*StreamRequest, ChatService_StreamMessagesServer) error
	MarkAsRead(context.Context, *MarkAsReadRequest) (*ReadReceipt, error)
	MarkConversationAsRead(context.Context, *MarkConversationAsReadRequest) (*BatchReadReceipt, error)
	GetUnreadCounts(context.Context, *GetUnreadCountsRequest) (*GetUnreadCountsResponse, error)
}

// ChatService_StreamMessagesServer 消息流服务端接口
type ChatService_StreamMessagesServer interface {
	Send(*Message) error
	grpc.ServerStream
}

// UnimplementedChatServiceServer 未实现的服务基类（用于向前兼容）
type UnimplementedChatServiceServer struct{}

func (UnimplementedChatServiceServer) GetConversations(context.Context, *GetConversationsRequest) (*ConversationsResponse, error) {
	return nil, nil
}

func (UnimplementedChatServiceServer) GetConversation(context.Context, *GetConversationRequest) (*Conversation, error) {
	return nil, nil
}

func (UnimplementedChatServiceServer) CreateConversation(context.Context, *CreateConversationRequest) (*Conversation, error) {
	return nil, nil
}

func (UnimplementedChatServiceServer) GetMessages(context.Context, *GetMessagesRequest) (*MessagesResponse, error) {
	return nil, nil
}

func (UnimplementedChatServiceServer) SendMessage(context.Context, *SendMessageRequest) (*Message, error) {
	return nil, nil
}

func (UnimplementedChatServiceServer) StreamMessages(*StreamRequest, ChatService_StreamMessagesServer) error {
	return nil
}

func (UnimplementedChatServiceServer) MarkAsRead(context.Context, *MarkAsReadRequest) (*ReadReceipt, error) {
	return nil, nil
}

func (UnimplementedChatServiceServer) MarkConversationAsRead(context.Context, *MarkConversationAsReadRequest) (*BatchReadReceipt, error) {
	return nil, nil
}

func (UnimplementedChatServiceServer) GetUnreadCounts(context.Context, *GetUnreadCountsRequest) (*GetUnreadCountsResponse, error) {
	return nil, nil
}

// RegisterChatServiceServer 注册聊天服务到 gRPC 服务器
func RegisterChatServiceServer(s *grpc.Server, srv ChatServiceServer) {
	// 生产环境中由 protoc-gen-go-grpc 生成
	// 这里使用手动注册
	s.RegisterService(&ChatService_ServiceDesc, srv)
}

// ChatService_ServiceDesc gRPC 服务描述符
var ChatService_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "chat.ChatService",
	HandlerType: (*ChatServiceServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "GetConversations",
			Handler:    _ChatService_GetConversations_Handler,
		},
		{
			MethodName: "GetConversation",
			Handler:    _ChatService_GetConversation_Handler,
		},
		{
			MethodName: "CreateConversation",
			Handler:    _ChatService_CreateConversation_Handler,
		},
		{
			MethodName: "GetMessages",
			Handler:    _ChatService_GetMessages_Handler,
		},
		{
			MethodName: "SendMessage",
			Handler:    _ChatService_SendMessage_Handler,
		},
		{
			MethodName: "MarkAsRead",
			Handler:    _ChatService_MarkAsRead_Handler,
		},
		{
			MethodName: "MarkConversationAsRead",
			Handler:    _ChatService_MarkConversationAsRead_Handler,
		},
		{
			MethodName: "GetUnreadCounts",
			Handler:    _ChatService_GetUnreadCounts_Handler,
		},
	},
	Streams: []grpc.StreamDesc{
		{
			StreamName:    "StreamMessages",
			Handler:       _ChatService_StreamMessages_Handler,
			ServerStreams: true,
		},
	},
	Metadata: "chat/chat.proto",
}

// gRPC 方法处理器实现

func _ChatService_GetConversations_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(GetConversationsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ChatServiceServer).GetConversations(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/chat.ChatService/GetConversations",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ChatServiceServer).GetConversations(ctx, req.(*GetConversationsRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ChatService_GetConversation_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(GetConversationRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ChatServiceServer).GetConversation(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/chat.ChatService/GetConversation",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ChatServiceServer).GetConversation(ctx, req.(*GetConversationRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ChatService_CreateConversation_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(CreateConversationRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ChatServiceServer).CreateConversation(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/chat.ChatService/CreateConversation",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ChatServiceServer).CreateConversation(ctx, req.(*CreateConversationRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ChatService_GetMessages_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(GetMessagesRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ChatServiceServer).GetMessages(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/chat.ChatService/GetMessages",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ChatServiceServer).GetMessages(ctx, req.(*GetMessagesRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ChatService_SendMessage_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(SendMessageRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ChatServiceServer).SendMessage(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/chat.ChatService/SendMessage",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ChatServiceServer).SendMessage(ctx, req.(*SendMessageRequest))
	}
	return interceptor(ctx, in, info, handler)
}

type chatServiceStreamMessagesServer struct {
	grpc.ServerStream
}

func (x *chatServiceStreamMessagesServer) Send(m *Message) error {
	return x.ServerStream.SendMsg(m)
}

func _ChatService_StreamMessages_Handler(srv interface{}, stream grpc.ServerStream) error {
	m := new(StreamRequest)
	if err := stream.RecvMsg(m); err != nil {
		return err
	}
	return srv.(ChatServiceServer).StreamMessages(m, &chatServiceStreamMessagesServer{stream})
}

func _ChatService_MarkAsRead_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(MarkAsReadRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ChatServiceServer).MarkAsRead(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/chat.ChatService/MarkAsRead",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ChatServiceServer).MarkAsRead(ctx, req.(*MarkAsReadRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ChatService_MarkConversationAsRead_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(MarkConversationAsReadRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ChatServiceServer).MarkConversationAsRead(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/chat.ChatService/MarkConversationAsRead",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ChatServiceServer).MarkConversationAsRead(ctx, req.(*MarkConversationAsReadRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ChatService_GetUnreadCounts_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(GetUnreadCountsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ChatServiceServer).GetUnreadCounts(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/chat.ChatService/GetUnreadCounts",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ChatServiceServer).GetUnreadCounts(ctx, req.(*GetUnreadCountsRequest))
	}
	return interceptor(ctx, in, info, handler)
}
