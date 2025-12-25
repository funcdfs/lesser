package main

import (
	"fmt"
	"net/http"
	"time"
)

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"status":"ok","timestamp":"%s"}`, time.Now().Format(time.RFC3339))
}

func main() {
	// 注册健康检查端点
	http.HandleFunc("/health", healthCheckHandler)

	// 启动服务器
	fmt.Println("Starting Golang Hot Service on port 8080...")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(fmt.Sprintf("Failed to start server: %v", err))
	}
}
