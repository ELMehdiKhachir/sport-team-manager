# Business modules

The validated modular-monolith boundaries are: `identity`, `club`, `team`, `roster`, `competition`, `fff`, `match` (availability, selection, convocation, lineup and events), `training`, `statistics`, `notification` and `jobs`.

Modules are created only when their validated vertical slice starts. Each module must expose application use cases, keep infrastructure encapsulated, and prevent controllers from accessing Prisma directly.

