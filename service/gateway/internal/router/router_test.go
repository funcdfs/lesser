// Package router 路由器单元测试
package router

import (
	"context"
	"testing"
)

func TestRouter_NewRouter_EmptyConfig(t *testing.T) {
	// 使用空配置创建路由器
	router, err := NewRouter(ServiceConfig{}, nil)
	if err != nil {
		t.Fatalf("创建路由器失败: %v", err)
	}
	defer router.Close()

	// 所有连接应该为 nil
	if router.GetAuthConn() != nil {
		t.Error("Auth 连接应该为 nil")
	}
	if router.GetUserConn() != nil {
		t.Error("User 连接应该为 nil")
	}
	if router.GetContentConn() != nil {
		t.Error("Content 连接应该为 nil")
	}
}

func TestRouter_GetConn_NonExistent(t *testing.T) {
	router, err := NewRouter(ServiceConfig{}, nil)
	if err != nil {
		t.Fatalf("创建路由器失败: %v", err)
	}
	defer router.Close()

	// 获取不存在的服务连接
	conn := router.GetConn("non-existent")
	if conn != nil {
		t.Error("不存在的服务应该返回 nil")
	}
}

func TestRouter_RouteByService_NotFound(t *testing.T) {
	router, err := NewRouter(ServiceConfig{}, nil)
	if err != nil {
		t.Fatalf("创建路由器失败: %v", err)
	}
	defer router.Close()

	// 路由到不存在的服务
	_, err = router.RouteByService("non-existent")
	if err == nil {
		t.Error("路由到不存在的服务应该返回错误")
	}
}

func TestRouter_HealthCheck_EmptyConfig(t *testing.T) {
	router, err := NewRouter(ServiceConfig{}, nil)
	if err != nil {
		t.Fatalf("创建路由器失败: %v", err)
	}
	defer router.Close()

	// 健康检查应该返回空 map
	health := router.HealthCheck(context.Background())
	if len(health) != 0 {
		t.Errorf("空配置的健康检查应该返回空 map, 实际: %v", health)
	}
}

func TestRouter_Close_Idempotent(t *testing.T) {
	router, err := NewRouter(ServiceConfig{}, nil)
	if err != nil {
		t.Fatalf("创建路由器失败: %v", err)
	}

	// 多次调用 Close 不应该 panic
	router.Close()
	router.Close()
	router.Close()
}

func TestServiceName_Constants(t *testing.T) {
	// 验证服务名称常量
	expectedServices := map[ServiceName]string{
		// 认证与用户
		ServiceAuth:      "auth",
		ServiceUser:      "user",
		ServiceSuperUser: "superuser",

		// 内容与交互
		ServiceContent:     "content",
		ServiceComment:     "comment",
		ServiceInteraction: "interaction",
		ServiceTimeline:    "timeline",

		// 搜索与通知
		ServiceSearch:       "search",
		ServiceNotification: "notification",

		// 实时通信
		ServiceChat:    "chat",
		ServiceChannel: "channel",
	}

	for name, expected := range expectedServices {
		if string(name) != expected {
			t.Errorf("服务名称不匹配: 期望 %s, 实际 %s", expected, string(name))
		}
	}
}

func TestRouter_GetSpecificConns(t *testing.T) {
	router, err := NewRouter(ServiceConfig{}, nil)
	if err != nil {
		t.Fatalf("创建路由器失败: %v", err)
	}
	defer router.Close()

	// 测试所有 Get*Conn 方法都不会 panic
	// 认证与用户
	_ = router.GetAuthConn()
	_ = router.GetUserConn()
	_ = router.GetSuperUserConn()

	// 内容与交互
	_ = router.GetContentConn()
	_ = router.GetCommentConn()
	_ = router.GetInteractionConn()
	_ = router.GetTimelineConn()

	// 搜索与通知
	_ = router.GetSearchConn()
	_ = router.GetNotificationConn()

	// 实时通信
	_ = router.GetChatConn()
	_ = router.GetChannelConn()
}
