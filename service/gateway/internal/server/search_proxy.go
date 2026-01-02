package server

import (
	"context"
	"log"

	searchpb "github.com/lesser/gateway/proto/search"
	"google.golang.org/grpc"
)

// SearchProxyServer 代理 Search 服务请求到后端 Search 服务
type SearchProxyServer struct {
	searchpb.UnimplementedSearchServiceServer
	searchClient searchpb.SearchServiceClient
}

// NewSearchProxyServer 创建 Search 代理服务器
func NewSearchProxyServer(searchConn *grpc.ClientConn) *SearchProxyServer {
	return &SearchProxyServer{
		searchClient: searchpb.NewSearchServiceClient(searchConn),
	}
}

// SearchPosts 代理搜索帖子请求
func (s *SearchProxyServer) SearchPosts(ctx context.Context, req *searchpb.SearchPostsRequest) (*searchpb.SearchPostsResponse, error) {
	log.Printf("[SearchProxy] SearchPosts: query=%s", req.Query)
	return s.searchClient.SearchPosts(ctx, req)
}

// SearchUsers 代理搜索用户请求
func (s *SearchProxyServer) SearchUsers(ctx context.Context, req *searchpb.SearchUsersRequest) (*searchpb.SearchUsersResponse, error) {
	log.Printf("[SearchProxy] SearchUsers: query=%s", req.Query)
	return s.searchClient.SearchUsers(ctx, req)
}

// RegisterSearchProxyServer 注册 Search 代理服务到 gRPC 服务器
func RegisterSearchProxyServer(s *grpc.Server, searchConn *grpc.ClientConn) {
	searchProxy := NewSearchProxyServer(searchConn)
	searchpb.RegisterSearchServiceServer(s, searchProxy)
	log.Println("[Gateway] Search proxy service registered")
}
