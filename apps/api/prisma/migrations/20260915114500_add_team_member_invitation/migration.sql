CREATE TABLE "TeamMemberInvitation" (
  "id" TEXT NOT NULL,
  "teamId" TEXT NOT NULL,
  "role" "TeamRole" NOT NULL,
  "tokenHash" TEXT NOT NULL,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  "claimedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "TeamMemberInvitation_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "TeamMemberInvitation_tokenHash_key"
ON "TeamMemberInvitation"("tokenHash");

CREATE INDEX "TeamMemberInvitation_teamId_idx"
ON "TeamMemberInvitation"("teamId");

CREATE INDEX "TeamMemberInvitation_expiresAt_idx"
ON "TeamMemberInvitation"("expiresAt");

ALTER TABLE "TeamMemberInvitation"
ADD CONSTRAINT "TeamMemberInvitation_teamId_fkey"
FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
