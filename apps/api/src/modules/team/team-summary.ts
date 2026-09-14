import type { TeamPermission } from './team-permission.js';

export interface TeamMembershipSummary {
  id: string;
  name: string;
  club: { id: string; name: string } | null;
  roles: string[];
}

export interface TeamSummary extends TeamMembershipSummary {
  permissions: TeamPermission[];
}
