# Sport Team Manager

Mobile-first assistant for amateur futsal coaches. The technical MVP foundation is validated. Slice 01.1 — creating a club and its initial team — is functionally validated, and Slice 01.2 — pre-creating a player without requiring an account — is implemented and awaiting product validation.

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

No state-management, router or model-generation library is selected yet. The current authenticated API integration uses the `http` package.

## Current implementation status

- Technical bootstrap: validated.
- Neon + Render + Firebase authentication foundation: validated.
- Authenticated `GET /identity/me`: validated end-to-end.
- Slice 01.1 — create club + initial team: validated functionally and complete.
- Slice 01.2 — pre-create player: implemented on `main` with `PlayerProfile`, Prisma migration, authenticated roster API, backend permissions, duplicate protection, Flutter roster page, add-player form and automated tests.
- API CI is green. Flutter formatting, analysis, tests and Web build are green, and the latest Web preview is deployed on GitHub Pages.
- Current gate before marking Slice 01.2 done: functional validation on the deployed app — add a player, confirm `Compte non associé`, reload, and verify persistence.

## Validation

```bash
cd apps/api && npm run lint && npm test && npm run build
cd apps/mobile && flutter pub get && flutter analyze && flutter test
docker build -f infra/docker/api.Dockerfile .
```

Google Drive is the product and architecture Source of Truth. Trello tracks execution. GitHub contains implementation. Read [AGENTS.md](AGENTS.md) before important changes.
