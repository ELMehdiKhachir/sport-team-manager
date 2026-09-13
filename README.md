# Sport Team Manager

Mobile-first assistant for amateur futsal coaches. The technical MVP foundation is validated. Slice 01.1 — creating a club and its initial team — and Slice 01.2 — pre-creating a player without requiring an account — are functionally validated. Slice 01.3 — inviting a player and claiming the existing profile — is implemented and awaiting end-to-end product validation with a second account.

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
- Slice 01.1 — create club + initial team: functionally validated and complete.
- Slice 01.2 — pre-create player: functionally validated and complete, including narrow-screen roster layout.
- Slice 01.3 — invite + claim player profile: implemented on `main` with hashed, expiring, regenerable invite tokens; single-use transactional claim; preservation of the existing `PlayerProfile`; `PLAYER` membership role merge; manager invite UI and authenticated Web claim flow.
- API CI is green, including Prisma validation, tests, build and Docker. Flutter formatting, analysis, tests and Web build are green for the invitation flow.
- Production startup runs `prisma migrate deploy` before NestJS, so committed migrations are applied on Render startup.
- Current gate before marking Slice 01.3 done: functional validation with two distinct Firebase accounts. The manager generates the link; a different player account opens it, confirms the claim, joins with role `PLAYER`, and the original roster entry becomes associated without duplication.

## Validation

```bash
cd apps/api && npm run lint && npm test && npm run build
cd apps/mobile && flutter pub get && flutter analyze && flutter test
docker build -f infra/docker/api.Dockerfile .
```

Google Drive is the product and architecture Source of Truth. Trello tracks execution. GitHub contains implementation. Read [AGENTS.md](AGENTS.md) before important changes.
