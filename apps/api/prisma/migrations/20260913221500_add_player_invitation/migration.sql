ALTER TABLE "PlayerProfile"
ADD COLUMN "inviteTokenHash" TEXT,
ADD COLUMN "inviteExpiresAt" TIMESTAMP(3);

CREATE UNIQUE INDEX "PlayerProfile_inviteTokenHash_key"
ON "PlayerProfile"("inviteTokenHash");
