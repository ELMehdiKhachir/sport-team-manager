# ADR 0001: Simple monorepo

- Status: accepted
- Date: 2026-09-12

## Decision

Use a simple repository layout with `apps/mobile`, `apps/api`, `packages`, `docs` and `infra`. Do not introduce Nx, Turborepo or a similar orchestrator until a demonstrated need exists.

## Consequences

Each application keeps its native toolchain. CI jobs run independently, reducing early coupling and dependency overhead.

