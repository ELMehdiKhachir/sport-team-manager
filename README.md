# Sport Team Manager

Mobile-first assistant for amateur futsal coaches. The technical MVP foundation, Epics 01 and 02, and Slices 00.1 and 00.2 are functionally validated. Club and team creation, player lifecycle, cumulative roles, active-team switching, business permissions, secure Coach/Staff invitations, and the five-section mobile navigation work end to end.

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
- Slice 02.2 — deactivate/reactivate players: functionally validated and complete. Inactive players remain visible without losing profile data or account association; managers and coaches can change status, while player-only memberships cannot access the action.
- Slice 02.3 — invite Coach/Staff members: functionally validated and complete. Only managers can issue secure, single-use invitations that expire after seven days. Claiming an invitation adds the selected role without removing roles already held by the member.
- Slice 00.1 — main mobile navigation: functionally validated and complete. The authenticated shell exposes Home, Calendar, Team, Stats and Profile while preserving Home state between tab changes. Profile displays the connected account and supports sign-out.
- Slice 00.2 — Team workspace: functionally validated and complete. Team creation, active-team switching, roster access and Coach/Staff invitations now live under Team. Invitation links open Team directly, while Home exposes an honest operational-dashboard empty state without fabricated match or training data.
- Production startup runs `prisma migrate deploy` before NestJS, so committed migrations are applied on Render startup.
- API CI is green, including Prisma validation, tests, build and Docker. Flutter formatting, analysis, tests, Web build and Android APK build are green. GitHub Pages contains the functionally validated Slice 00.2 version.
- Epic 01 — foundations (account, club, team and roles): complete.
- Epic 02 — roster, player profiles and invitations: functionally validated and complete.

## Validation

```bash
cd apps/api && npm run lint && npm test && npm run build
cd apps/mobile && flutter pub get && flutter analyze && flutter test
docker build -f infra/docker/api.Dockerfile .
```

Google Drive is the product and architecture Source of Truth. Trello tracks execution. GitHub contains implementation. Read [AGENTS.md](AGENTS.md) before important changes.
