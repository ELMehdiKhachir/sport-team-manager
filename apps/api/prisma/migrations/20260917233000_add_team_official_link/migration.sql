CREATE TABLE "TeamOfficialLink" (
    "id" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'FFF',
    "externalClubId" TEXT NOT NULL,
    "externalTeamId" TEXT,
    "externalCompetitionId" TEXT NOT NULL,
    "competitionName" TEXT NOT NULL,
    "seasonLabel" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TeamOfficialLink_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "TeamOfficialLink_teamId_key" ON "TeamOfficialLink"("teamId");
CREATE INDEX "TeamOfficialLink_provider_externalClubId_idx" ON "TeamOfficialLink"("provider", "externalClubId");
CREATE INDEX "TeamOfficialLink_provider_externalTeamId_idx" ON "TeamOfficialLink"("provider", "externalTeamId");

ALTER TABLE "TeamOfficialLink" ADD CONSTRAINT "TeamOfficialLink_teamId_fkey"
FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
