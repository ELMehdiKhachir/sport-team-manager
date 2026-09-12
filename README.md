# Sport Team Manager

Mobile-first assistant for amateur futsal coaches. This repository contains the technical MVP foundation only; business features are intentionally not implemented yet.

## Repository layout

- `apps/mobile`: Flutter application, feature-first structure and centralized design system.
- `apps/api`: NestJS modular monolith, REST/OpenAPI, Prisma/PostgreSQL and Firebase Admin foundation.
- `packages/contracts`: reserved for generated OpenAPI contracts when needed.
- `docs/architecture`: architecture notes.
- `docs/adr`: explicit architecture decisions.
- `infra/docker`: local PostgreSQL and API container setup.
- `.github/workflows`: API and mobile validation.

## Prerequisites

- Node.js 24+
- npm 11+
- Flutter stable
- Docker with Compose (optional, for local PostgreSQL)

## Configuration

```bash
cp .env.example apps/api/.env
```

Never commit real credentials. Firebase role and team permissions live in PostgreSQL and are enforced by the API; Firebase only provides technical identity.

## Run the API

```bash
docker compose -f infra/docker/compose.yaml up -d postgres
cd apps/api
npm ci
npm run prisma:generate
npm run start:dev
```

OpenAPI UI is available at `http://localhost:3000/docs`; health is at `http://localhost:3000/health`.

## Run the mobile app

The first time only, generate the platform runners with your installed Flutter SDK:

```bash
cd apps/mobile
flutter create --project-name sport_team_manager --platforms=android,ios .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

No state-management, router, HTTP client or model-generation library is selected in this bootstrap.

## Validation

```bash
cd apps/api && npm run lint && npm test && npm run build
cd apps/mobile && flutter pub get && flutter analyze && flutter test
docker build -f infra/docker/api.Dockerfile .
```

Google Drive is the product and architecture Source of Truth. Trello tracks execution. GitHub contains implementation. Read [AGENTS.md](AGENTS.md) before important changes.

