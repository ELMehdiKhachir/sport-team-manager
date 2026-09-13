-- CreateEnum
CREATE TYPE "PlayerPosition" AS ENUM ('GOALKEEPER', 'FIXO', 'WINGER', 'PIVOT');

-- CreateEnum
CREATE TYPE "DominantFoot" AS ENUM ('RIGHT', 'LEFT', 'BOTH');

-- CreateTable
CREATE TABLE "PlayerProfile" (
    "id" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "userId" TEXT,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "primaryPosition" "PlayerPosition" NOT NULL,
    "secondaryPosition" "PlayerPosition",
    "shirtNumber" INTEGER,
    "dominantFoot" "DominantFoot",
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlayerProfile_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "PlayerProfile_teamId_userId_key" ON "PlayerProfile"("teamId", "userId");

-- CreateIndex
CREATE INDEX "PlayerProfile_teamId_idx" ON "PlayerProfile"("teamId");

-- CreateIndex
CREATE INDEX "PlayerProfile_teamId_lastName_firstName_idx" ON "PlayerProfile"("teamId", "lastName", "firstName");

-- AddForeignKey
ALTER TABLE "PlayerProfile" ADD CONSTRAINT "PlayerProfile_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerProfile" ADD CONSTRAINT "PlayerProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
