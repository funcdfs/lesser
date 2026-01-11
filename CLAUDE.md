# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Before You Act: Read the Docs First

**Before making changes, read the relevant documentation:**

| Task | Read First |
|------|------------|
| Backend service changes | `docs/架构梳理.md` - service architecture, messaging layer, call chains |
| Flutter UI changes | `docs/UI 细节.md` - UI principles, component guidelines, icon styles |
| Any development | `docs/开发准则.md` - code standards, directory structure, conventions |
| Using shared Go libraries | `service/pkg/README.md` - available packages and usage examples |

## Project Overview

Lesser is a Twitter-like social platform built with pure gRPC microservices architecture. Flutter cross-platform client (mobile + web), Go backend services, Docker Compose infrastructure.

## Commands

All commands use the Rust CLI tool `devlesser`:

```bash
# Install CLI
cargo install --path infra/cli

# Start services
devlesser start              # All services
devlesser start infra        # Infrastructure only (PostgreSQL/Redis/RabbitMQ/Traefik)
devlesser start service      # Backend services only
devlesser start flutter      # Flutter client (interactive platform selection)

# Proto code generation
devlesser proto              # Generate all (alias: devlesser gen)
devlesser proto go           # Go only
devlesser proto dart         # Dart only

# Testing
devlesser test               # All service tests
devlesser test <service>     # Single service (auth, user, content, comment, interaction, timeline, search, notification, chat, gateway, superuser, channel)
devlesser test full          # Complete three-round testing

# Other
devlesser stop
devlesser status
devlesser clean
devlesser clean volumes
```

## Architecture

```
Flutter Client (gRPC-Web)
    ↓
Traefik Gateway (:50050 gRPC, :80 HTTP)
    ↓
Go Gateway (:50051) - JWT verification, rate limiting, routing
    ↓
Service Cluster (gRPC):
  Auth(:50052), User(:50053), Content(:50054), Comment(:50055),
  Interaction(:50056), Timeline(:50057), Search(:50058),
  Notification(:50059), Chat(:50060), SuperUser(:50061), Channel(:50062)
    ↓
Data Layer: PostgreSQL 17 + pgvector, Redis 7, RabbitMQ
```

**Communication patterns:**
- Synchronous: gRPC between all services and clients
- Asynchronous: RabbitMQ for events (notifications, search indexing) - see `docs/架构梳理.md` for event types and flow
- Real-time: gRPC bidirectional streams for Chat and Channel services

## Code Structure

**Backend (Go):** `service/<name>/internal/` with layers:
- `handler/` - gRPC handlers (protocol, parameter conversion)
- `logic/` - core business rules (permissions, caching strategy)
- `remote/` - cross-service gRPC calls
- `data_access/` - database operations
- `messaging/` - RabbitMQ publish/subscribe

Shared libraries in `service/pkg/` - read `service/pkg/README.md` before using.

**Frontend (Flutter):** `client/mobile_flutter/lib/features/<module>/` with layers: pages → handler → data_access → models
- State management: Riverpod
- Routing: go_router
- Shared code in `lib/pkg/` (network, errors, ui, constants)

**Proto files:** `protos/<service>/` - managed with buf, generates to `gen_protos/` (do not edit manually)

## Development Guidelines

- 中文注释 (Chinese comments throughout). 中英混杂时前后加空格
- Follow existing layered architecture strictly
- Use shared libraries from `service/pkg/` - don't reimplement
- Check if official/popular libraries exist before implementing from scratch
- Minimize code generation - only what's needed
- Avoid over-abstraction and unnecessary syntactic sugar

**Adding a new route:**
1. Define proto in `protos/<service>/<service>.proto`
2. Run `devlesser proto`
3. Implement handler/logic/data_access in `service/<service>/internal/`
4. Configure gateway routing in `service/gateway/internal/router/`
5. Update Traefik routes if needed in `infra/gateway/dynamic/routes.yml`
6. Implement Flutter data_access and UI in `lib/features/<module>/`

**Flutter UI principles** (from `docs/UI 细节.md`):
- Content-centric: all UI elements serve content readability
- Use negative space and alignment instead of heavy borders
- Optimistic UI updates for all interactions
- Use `_rounded` icon variants only (e.g., `Icons.favorite_rounded`)
- Components should not have outer margins - containers distribute spacing

**Go conventions:**
- Use interfaces for dependency injection
- Use `context` for request context propagation
- gRPC error codes: InvalidArgument, Unauthenticated, PermissionDenied, NotFound, Internal
