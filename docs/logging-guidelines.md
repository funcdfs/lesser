# Logging Standards & Guidelines

## Overview

This document defines the unified logging format and practices for the Lesser project's microservices architecture.

## Unified JSON Format

All services **MUST** output logs in JSON format with the following standard fields:

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `timestamp` | String | ISO8601 with timezone (UTC) | `"2025-12-31T01:36:30.680Z"` |
| `level` | String | Log level (uppercase) | `"INFO"`, `"ERROR"`, `"WARN"` |
| `service` | String | Service identifier | `"go-chat-service"`, `"auth-worker"` |
| `msg` | String | Human-readable message | `"http_request"`, `"db_query"` |

### Tracing Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `trace_id` | String | Unique request identifier across all services | `"a1b2c3d4-e5f6-g7h8"` |
| `span_id` | String (optional) | Current trace span ID | `"b87654321"` |

### Context Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `user_id` | String (optional) | Authenticated user ID | `"10293"` |
| `client_ip` | String (optional) | Client IP address | `"192.168.1.5"` |
| `caller` | String (optional) | Code location | `"middleware/logger.go:50"` |

### HTTP Request Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `http_method` | String | HTTP method | `"POST"` |
| `http_path` | String | Request path | `"/api/v1/posts/"` |
| `status_code` | Integer | HTTP status code | `201` |
| `latency_ms` | Float | Request duration in milliseconds | `15.5` |

### Database Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `db_instance` | String | Database identifier | `"postgres"`, `"redis_cache"` |
| `sql` | String | SQL query (if applicable) | `"SELECT * FROM..."` |
| `rows_affected` | Integer | Rows affected by query | `5` |

## Implementation by Service

### Go Services (Zap)

```go
// Use Uber Zap with JSON encoder
logger.Log.Info("http_request",
    zap.String("service", "go-chat-service"),
    zap.String("trace_id", traceID),
    zap.Int("status_code", 200),
    // ...
)
```

## Log Filtering

**ALL logs are sent to stdout/stderr without filtering.**

Log filtering should be configured in **Dozzle** or your log aggregation system (ELK, Datadog, etc.), NOT in application code.

### Why No Application-Level Filtering?

1. **Flexibility**: Different environments may need different log levels
2. **Observability**: Health check failures are important to capture
3. **Debugging**: Having complete logs aids troubleshooting
4. **Centralization**: Single source of truth for all log data

### Dozzle Configuration

Filter health check logs in Dozzle using query filters:

```
NOT msg:"http_request" OR (msg:"http_request" AND NOT http_path:"/health")
```

## Best Practices

### DO ✅

- Always include `trace_id` in logs for requests
- Use structured logging with typed fields
- Log errors with stack traces at ERROR level
- Include meaningful context (user_id, resource_id, etc.)
- Use consistent field names across services

### DON'T include ❌

- Don't log sensitive data (passwords, tokens, PII)
- Don't filter logs at application level
- Don't use print() or console.log() - use proper loggers
- Don't log binary data
- Don't create custom log formatters - use the unified format

## Log Levels

Use log levels consistently:

- **DEBUG**: Detailed diagnostic information (development only)
- **INFO**: General informational messages, normal operation
- **WARN**: Warning messages, potentially harmful situations
- **ERROR**: Error events that might still allow continued execution
- **FATAL/CRITICAL**: Severe errors causing application termination

## Example Logs

### HTTP Request (Success)
```json
{
  "timestamp": "2025-12-31T01:36:30.680Z",
  "level": "INFO",
  "service": "go-chat-service",
  "msg": "http_request",
  "trace_id": "cbc86e12-738c-484c-a684-aeb29ce3cdd5",
  "status_code": 200,
  "http_method": "GET",
  "http_path": "/health",
  "latency_ms": 0.412,
  "client_ip": "::1"
}
```

### Database Query (Slow)
```json
{
  "timestamp": "2025-12-31T01:36:35.123Z",
  "level": "WARN",
  "service": "go-chat-service",
  "msg": "db_slow_query",
  "trace_id": "abc123",
  "db_instance": "postgres",
  "latency_ms": 1250.5,
  "sql": "SELECT * FROM messages WHERE...",
  "rows_affected": 1500
}
```

### Application Error
```json
{
  "timestamp": "2025-12-31T01:36:40.456Z",
  "level": "ERROR",
  "service": "auth-worker",
  "msg": "Failed to send notification",
  "trace_id": "def456",
  "user_id": "user_123",
  "error": "Connection timeout",
  "stacktrace": "..."
}
```

## Trace ID Propagation

1. **Frontend** sends `X-Trace-ID` header with requests
2. **First service** receives or generates trace_id
3. **All downstream services** propagate the same trace_id
4. **Logs** from all services share the same trace_id for end-to-end tracing

## Compliance

All services MUST follow this logging standard. Non-compliant logs will make debugging difficult and break observability tools.
