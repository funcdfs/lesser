package server

import (
	"context"
	"fmt"
	"log"

	"github.com/lesser/gateway/internal/broker"
	pb "github.com/lesser/gateway/proto/gateway"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/proto"
)

// GatewayServer 实现 GatewayService
type GatewayServer struct {
	pb.UnimplementedGatewayServiceServer
	broker *broker.Connection
}

// NewGatewayServer 创建新的 Gateway 服务器
func NewGatewayServer(brokerConn *broker.Connection) (*GatewayServer, error) {
	return &GatewayServer{
		broker: brokerConn,
	}, nil
}

// RegisterGatewayServer 注册 gRPC 服务
func RegisterGatewayServer(s *grpc.Server, srv *GatewayServer) {
	pb.RegisterGatewayServiceServer(s, srv)
}

// Process 处理所有客户端请求
func (s *GatewayServer) Process(ctx context.Context, req *pb.GatewayRequest) (*pb.GatewayResponse, error) {
	log.Printf("Received request: action=%v, request_id=%s", req.Action, req.RequestId)

	// 验证请求
	if req.RequestId == "" {
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "INVALID_REQUEST",
			ErrorMessage: "request_id is required",
		}, nil
	}

	// 根据 action 分发到对应队列
	var routingKey string
	switch req.Action {
	case pb.Action_USER_REGISTER:
		routingKey = broker.QueueAuthRegister
	case pb.Action_USER_LOGIN:
		routingKey = broker.QueueAuthLogin
	default:
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "INVALID_ACTION",
			ErrorMessage: fmt.Sprintf("unknown action: %v", req.Action),
		}, nil
	}

	// 序列化整个请求并发布到队列
	msgBytes, err := serializeRequest(req)
	if err != nil {
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "SERIALIZATION_ERROR",
			ErrorMessage: err.Error(),
		}, nil
	}

	// 发布到 RabbitMQ
	if err := s.broker.Publish(routingKey, msgBytes); err != nil {
		log.Printf("Failed to publish message: %v", err)
		return &pb.GatewayResponse{
			RequestId:    req.RequestId,
			Accepted:     false,
			ErrorCode:    "BROKER_ERROR",
			ErrorMessage: "failed to queue task",
		}, nil
	}

	log.Printf("Task queued: request_id=%s, queue=%s", req.RequestId, routingKey)

	return &pb.GatewayResponse{
		RequestId: req.RequestId,
		Accepted:  true,
	}, nil
}

// GetResult 获取异步任务结果（暂时返回 pending）
func (s *GatewayServer) GetResult(ctx context.Context, req *pb.GetResultRequest) (*pb.TaskResult, error) {
	// TODO: 从 Redis 或其他存储获取结果
	return &pb.TaskResult{
		RequestId: req.RequestId,
		Status:    pb.TaskStatus_PENDING,
	}, nil
}

// serializeRequest 序列化请求为字节
func serializeRequest(req *pb.GatewayRequest) ([]byte, error) {
	return proto.Marshal(req)
}
