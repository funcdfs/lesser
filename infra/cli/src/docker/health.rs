use std::time::{Duration, Instant};

use anyhow::Result;
use reqwest::Client;

/// 健康检查结果
#[derive(Debug, Clone)]
pub struct HealthCheckResult {
    pub service: String,
    pub url: String,
    pub status: HealthStatus,
    pub response_time_ms: Option<u64>,
}

/// 健康状态
#[derive(Debug, Clone)]
pub enum HealthStatus {
    /// 服务健康
    Healthy,
    /// 服务不健康（返回了错误状态码）
    Unhealthy(String),
    /// 服务不可达（连接失败）
    Unreachable,
    /// 超时
    Timeout,
}

impl HealthStatus {
    /// 检查是否健康
    pub fn is_healthy(&self) -> bool {
        matches!(self, HealthStatus::Healthy)
    }

    /// 获取状态描述
    #[allow(dead_code)]
    pub fn description(&self) -> String {
        match self {
            HealthStatus::Healthy => "健康".to_string(),
            HealthStatus::Unhealthy(msg) => format!("不健康: {}", msg),
            HealthStatus::Unreachable => "不可达".to_string(),
            HealthStatus::Timeout => "超时".to_string(),
        }
    }
}

impl HealthCheckResult {
    /// 执行健康检查
    #[allow(dead_code)]
    pub async fn check(service: &str, url: &str) -> Self {
        Self::check_with_timeout(service, url, Duration::from_secs(5)).await
    }

    /// 执行健康检查（带超时）
    #[allow(dead_code)]
    pub async fn check_with_timeout(service: &str, url: &str, timeout: Duration) -> Self {
        let start = Instant::now();

        let client = match Client::builder()
            .timeout(timeout)
            .build()
        {
            Ok(c) => c,
            Err(_) => {
                return Self {
                    service: service.to_string(),
                    url: url.to_string(),
                    status: HealthStatus::Unreachable,
                    response_time_ms: None,
                };
            }
        };

        match client.get(url).send().await {
            Ok(response) => {
                let elapsed = start.elapsed().as_millis() as u64;
                if response.status().is_success() {
                    Self {
                        service: service.to_string(),
                        url: url.to_string(),
                        status: HealthStatus::Healthy,
                        response_time_ms: Some(elapsed),
                    }
                } else {
                    Self {
                        service: service.to_string(),
                        url: url.to_string(),
                        status: HealthStatus::Unhealthy(format!(
                            "HTTP {}",
                            response.status().as_u16()
                        )),
                        response_time_ms: Some(elapsed),
                    }
                }
            }
            Err(e) => {
                let elapsed = start.elapsed().as_millis() as u64;
                let status = if e.is_timeout() {
                    HealthStatus::Timeout
                } else {
                    HealthStatus::Unreachable
                };
                Self {
                    service: service.to_string(),
                    url: url.to_string(),
                    status,
                    response_time_ms: Some(elapsed),
                }
            }
        }
    }

    /// 检查是否健康
    pub fn is_healthy(&self) -> bool {
        self.status.is_healthy()
    }
}

/// 健康检查器
#[allow(dead_code)]
pub struct HealthChecker {
    client: Client,
    timeout: Duration,
}

impl Default for HealthChecker {
    fn default() -> Self {
        Self::new(Duration::from_secs(5))
    }
}

impl HealthChecker {
    /// 创建新的健康检查器
    pub fn new(timeout: Duration) -> Self {
        let client = Client::builder()
            .timeout(timeout)
            .danger_accept_invalid_certs(false) // 明确拒绝无效证书
            .no_proxy() // 禁用代理，直接连接本地服务
            .build()
            .expect("创建 HTTP 客户端失败");
        
        Self { client, timeout }
    }

    /// 创建带自定义配置的健康检查器
    #[allow(dead_code)]
    pub fn with_config(timeout: Duration, accept_invalid_certs: bool) -> Self {
        let client = Client::builder()
            .timeout(timeout)
            .danger_accept_invalid_certs(accept_invalid_certs)
            .no_proxy()
            .build()
            .expect("创建 HTTP 客户端失败");
        
        Self { client, timeout }
    }

    /// 检查单个服务
    pub async fn check(&self, service: &str, url: &str) -> HealthCheckResult {
        let start = Instant::now();

        match self.client.get(url).send().await {
            Ok(response) => {
                let elapsed = start.elapsed().as_millis() as u64;
                if response.status().is_success() {
                    HealthCheckResult {
                        service: service.to_string(),
                        url: url.to_string(),
                        status: HealthStatus::Healthy,
                        response_time_ms: Some(elapsed),
                    }
                } else {
                    HealthCheckResult {
                        service: service.to_string(),
                        url: url.to_string(),
                        status: HealthStatus::Unhealthy(format!(
                            "HTTP {}",
                            response.status().as_u16()
                        )),
                        response_time_ms: Some(elapsed),
                    }
                }
            }
            Err(e) => {
                let elapsed = start.elapsed().as_millis() as u64;
                let status = if e.is_timeout() {
                    HealthStatus::Timeout
                } else {
                    HealthStatus::Unreachable
                };
                HealthCheckResult {
                    service: service.to_string(),
                    url: url.to_string(),
                    status,
                    response_time_ms: Some(elapsed),
                }
            }
        }
    }

    /// 检查多个服务
    #[allow(dead_code)]
    pub async fn check_all(&self, endpoints: &[(&str, &str)]) -> Vec<HealthCheckResult> {
        let mut results = Vec::with_capacity(endpoints.len());
        
        for (service, url) in endpoints {
            let result = self.check(service, url).await;
            results.push(result);
        }
        
        results
    }

    /// 并发检查多个服务
    pub async fn check_all_concurrent(&self, endpoints: &[(&str, &str)]) -> Vec<HealthCheckResult> {
        let futures: Vec<_> = endpoints
            .iter()
            .map(|(service, url)| self.check(service, url))
            .collect();
        
        futures::future::join_all(futures).await
    }

    /// 等待服务健康（带重试）
    #[allow(dead_code)]
    pub async fn wait_for_healthy(
        &self,
        service: &str,
        url: &str,
        max_retries: u32,
        retry_interval: Duration,
    ) -> Result<HealthCheckResult> {
        for attempt in 0..max_retries {
            let result = self.check(service, url).await;
            
            if result.is_healthy() {
                return Ok(result);
            }
            
            if attempt < max_retries - 1 {
                tokio::time::sleep(retry_interval).await;
            }
        }
        
        // 返回最后一次检查结果
        Ok(self.check(service, url).await)
    }
}

/// 预定义的服务健康检查端点
pub struct ServiceEndpoints;

impl ServiceEndpoints {
    /// Django 健康检查端点
    pub const DJANGO_HEALTH: &'static str = "http://localhost:8000/api/v1/health/";
    
    /// Chat 服务健康检查端点 (外部端口 8081)
    pub const CHAT_HEALTH: &'static str = "http://localhost:8081/health";
    
    /// Traefik 健康检查端点 (Dashboard API)
    pub const TRAEFIK_HEALTH: &'static str = "http://localhost:8088/api/overview";
    
    /// 获取所有服务端点
    pub fn all() -> Vec<(&'static str, &'static str)> {
        vec![
            ("Django", Self::DJANGO_HEALTH),
            ("Chat", Self::CHAT_HEALTH),
            ("Traefik", Self::TRAEFIK_HEALTH),
        ]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_health_status_is_healthy() {
        assert!(HealthStatus::Healthy.is_healthy());
        assert!(!HealthStatus::Unhealthy("error".to_string()).is_healthy());
        assert!(!HealthStatus::Unreachable.is_healthy());
        assert!(!HealthStatus::Timeout.is_healthy());
    }

    #[test]
    fn test_health_status_description() {
        assert_eq!(HealthStatus::Healthy.description(), "健康");
        assert!(HealthStatus::Unhealthy("HTTP 500".to_string())
            .description()
            .contains("不健康"));
        assert_eq!(HealthStatus::Unreachable.description(), "不可达");
        assert_eq!(HealthStatus::Timeout.description(), "超时");
    }

    #[test]
    fn test_health_check_result_is_healthy() {
        let healthy = HealthCheckResult {
            service: "test".to_string(),
            url: "http://localhost".to_string(),
            status: HealthStatus::Healthy,
            response_time_ms: Some(100),
        };
        assert!(healthy.is_healthy());

        let unhealthy = HealthCheckResult {
            service: "test".to_string(),
            url: "http://localhost".to_string(),
            status: HealthStatus::Unhealthy("error".to_string()),
            response_time_ms: Some(100),
        };
        assert!(!unhealthy.is_healthy());
    }

    #[test]
    fn test_service_endpoints() {
        let endpoints = ServiceEndpoints::all();
        assert!(!endpoints.is_empty());
        
        // 验证所有端点都是有效的 URL 格式
        for (name, url) in &endpoints {
            assert!(!name.is_empty());
            assert!(url.starts_with("http://"));
        }
    }
}
