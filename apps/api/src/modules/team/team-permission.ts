import { TeamRole } from '../../generated/prisma/enums.js';

export enum TeamPermission {
  VIEW_ROSTER = 'VIEW_ROSTER',
  MANAGE_ROSTER = 'MANAGE_ROSTER',
  INVITE_PLAYER = 'INVITE_PLAYER',
  MANAGE_TEAM_MEMBERS = 'MANAGE_TEAM_MEMBERS',
  FFF_SYNC = 'FFF_SYNC',
  MAKE_SPORTING_DECISIONS = 'MAKE_SPORTING_DECISIONS',
  RECORD_LIVE_EVENTS = 'RECORD_LIVE_EVENTS',
  VIEW_MANAGEMENT_STATS = 'VIEW_MANAGEMENT_STATS',
  RESPOND_AVAILABILITY = 'RESPOND_AVAILABILITY',
}

const permissionsByRole = new Map<string, readonly TeamPermission[]>([
  [
    TeamRole.OWNER_MANAGER,
    [
      TeamPermission.VIEW_ROSTER,
      TeamPermission.MANAGE_ROSTER,
      TeamPermission.INVITE_PLAYER,
      TeamPermission.MANAGE_TEAM_MEMBERS,
      TeamPermission.FFF_SYNC,
    ],
  ],
  [
    TeamRole.COACH,
    [
      TeamPermission.VIEW_ROSTER,
      TeamPermission.MANAGE_ROSTER,
      TeamPermission.INVITE_PLAYER,
      TeamPermission.MAKE_SPORTING_DECISIONS,
      TeamPermission.RECORD_LIVE_EVENTS,
      TeamPermission.VIEW_MANAGEMENT_STATS,
    ],
  ],
  [
    TeamRole.STAFF_ASSISTANT,
    [
      TeamPermission.VIEW_ROSTER,
      TeamPermission.RECORD_LIVE_EVENTS,
      TeamPermission.VIEW_MANAGEMENT_STATS,
    ],
  ],
  [
    TeamRole.PLAYER,
    [TeamPermission.VIEW_ROSTER, TeamPermission.RESPOND_AVAILABILITY],
  ],
]);

const permissionOrder = Object.values(TeamPermission);

export function permissionsForTeamRoles(
  roles: readonly string[],
): TeamPermission[] {
  return permissionOrder.filter((permission) =>
    roles.some((role) => permissionsByRole.get(role)?.includes(permission)),
  );
}

export function hasTeamPermission(
  roles: readonly string[] | null | undefined,
  permission: TeamPermission,
): boolean {
  return roles != null && permissionsForTeamRoles(roles).includes(permission);
}
