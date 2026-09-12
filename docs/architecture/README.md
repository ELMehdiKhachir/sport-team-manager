# Architecture

The MVP uses a Flutter mobile client and a NestJS modular monolith over REST/OpenAPI. NestJS owns authorization and persists business state through Prisma to PostgreSQL. Firebase Authentication supplies technical identity only.

External integrations (FFF, Firebase Cloud Messaging and Cloudflare R2) stay behind replaceable backend adapters. They are intentionally not implemented in this bootstrap beyond Firebase Admin configuration scaffolding.

