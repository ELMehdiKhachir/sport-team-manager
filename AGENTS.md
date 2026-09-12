# Agent instructions

## Source of Truth

- Read the Google Drive Source of Truth before important changes.
- Drive owns decisions; Trello owns execution/backlog; GitHub owns implementation.
- An explicitly validated Product Owner decision wins.
- Never invent anything marked TBD or implement out-of-scope features early.

## Architecture

- Keep NestJS as a modular monolith. Do not add microservices.
- PostgreSQL is the business source of truth; use Prisma behind repositories/application services.
- Controllers contain no business rules and never access Prisma directly.
- Keep external providers replaceable and infrastructure separate from the domain.
- Isolate FFF access in the backend `fff` module. Flutter must never call `api-dofa.fff.fr` directly.
- Persist jobs in PostgreSQL and make processing idempotent. Do not add Redis, BullMQ, RabbitMQ or Kafka for the MVP.
- Justify every structural dependency before adding it.

## Authorization and domain invariants

- NestJS is always the permission authority; hiding a Flutter control is not security.
- Roles are cumulative and scoped per team: OWNER/MANAGER, COACH, STAFF/ASSISTANT, PLAYER.
- OWNER/MANAGER does not imply COACH.
- Preserve the distinction: roster → availability → selection → convocation → lineup.

## Mobile and design

- Keep Flutter feature-first and mobile-first.
- Do not choose state management, routing, networking or code generation libraries without an explicit decision.
- Use centralized semantic color tokens; do not hard-code club colors in screens.
- Support light/dark themes and future 1–3 color club identities, while keeping functional status colors independent.

## Delivery

- Version and review Prisma migrations.
- Test critical workflows and permissions when implemented.
- Keep commits small and coherent.
- Do not start a new epic or the first business vertical slice without Product Owner validation.

