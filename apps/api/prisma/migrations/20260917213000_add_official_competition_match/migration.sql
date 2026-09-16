-- CreateEnum
CREATE TYPE "MatchVenue" AS ENUM ('HOME', 'AWAY', 'NEUTRAL');

-- CreateEnum
CREATE TYPE "MatchStatus" AS ENUM ('SCHEDULED', 'POSTPONED', 'CANCELLED', 'PLAYED');

-- CreateTable
CREATE TABLE "OfficialCompetition" (
    "id" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'FFF',
    "externalId" TEXT NOT NULL,
    "externalTeamId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "seasonLabel" TEXT,
    "lastSyncedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OfficialCompetition_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OfficialMatch" (
    "id" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "competitionId" TEXT NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'FFF',
    "externalId" TEXT NOT NULL,
    "startsAt" TIMESTAMP(3) NOT NULL,
    "venue" "MatchVenue" NOT NULL,
    "status" "MatchStatus" NOT NULL DEFAULT 'SCHEDULED',
    "homeTeamName" TEXT NOT NULL,
    "awayTeamName" TEXT NOT NULL,
    "homeExternalId" TEXT,
    "awayExternalId" TEXT,
    "lastSyncedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OfficialMatch_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "OfficialCompetition_teamId_provider_externalId_key" ON "OfficialCompetition"("teamId", "provider", "externalId");
CREATE INDEX "OfficialCompetition_teamId_idx" ON "OfficialCompetition"("teamId");
CREATE INDEX "OfficialCompetition_provider_externalTeamId_idx" ON "OfficialCompetition"("provider", "externalTeamId");
CREATE UNIQUE INDEX "OfficialMatch_provider_externalId_key" ON "OfficialMatch"("provider", "externalId");
CREATE INDEX "OfficialMatch_teamId_startsAt_idx" ON "OfficialMatch"("teamId", "startsAt");
CREATE INDEX "OfficialMatch_competitionId_startsAt_idx" ON "OfficialMatch"("competitionId", "startsAt");

-- AddForeignKey
ALTER TABLE "OfficialCompetition" ADD CONSTRAINT "OfficialCompetition_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "OfficialMatch" ADD CONSTRAINT "OfficialMatch_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "OfficialMatch" ADD CONSTRAINT "OfficialMatch_competitionId_fkey" FOREIGN KEY ("competitionId") REFERENCES "OfficialCompetition"("id") ON DELETE CASCADE ON UPDATE CASCADE;
