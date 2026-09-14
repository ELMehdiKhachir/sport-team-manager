# Sport Team Manager

Mobile-first assistant for amateur futsal coaches. The technical MVP foundation and Slices 01.1 through 01.4 are functionally validated: club and initial team creation, player pre-creation, invitation and profile claim, and active-team switching for multi-team users. Slices 01.1 through 01.5 are functionally validated and Epic 01 is complete. Team-scoped, cumulative business permissions are enforced by NestJS and exposed to Flutter.

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
- Slice 01.3 — invite + claim player profile: functionally validated and complete. The existing `PlayerProfile` is claimed without duplication and the `PLAYER` role is merged without removing existing roles.
- Slice 01.4 — active-team switching: functionally validated and complete. A multi-team user can select an active team, and the displayed club, roles and roster access follow that choice.
- Slice 01.5 — business-permission matrix: functionally validated and complete. NestJS computes cumulative team permissions, protects roster mutations and invitations, and Flutter uses API permissions to show management actions. Manager actions are visible only on authorized teams; Player-only teams retain read access without management actions.
- Slice 02.1 — edit player information: functionally validated and complete. Managers and coaches can update the pre-filled player form and clear optional sports fields; player-only memberships cannot access the action. NestJS enforces MANAGE_ROSTER and team ownership.
- Production startup runs `prisma migrate deploy` before NestJS, so committed migrations are applied on Render startup.
- API CI is green, including Prisma validation, tests, build and Docker. Flutter formatting, analysis, tests and Web build are green. GitHub Pages contains the validated player-editing version.
- Epic 01 — foundations (account, club, team and roles): complete.

## Validation

```bash
cd apps/api && npm run lint && npm test && npm run build
cd apps/mobile && flutter pub get && flutter analyze && flutter test
docker build -f infra/docker/api.Dockerfile .
```

Google Drive is the product and architecture Source of Truth. Trello tracks execution. GitHub contains implementation. Read [AGENTS.md](AGENTS.md) before important changes.
