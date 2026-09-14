import { TeamRole } from '../../generated/prisma/enums.js';
import {
  hasTeamPermission,
  permissionsForTeamRoles,
  TeamPermission,
} from './team-permission.js';

describe('team permission matrix', () => {
  it('keeps manager administration separate from coach decisions', () => {
    const permissions = permissionsForTeamRoles([TeamRole.OWNER_MANAGER]);

    expect(permissions).toContain(TeamPermission.MANAGE_ROSTER);
    expect(permissions).toContain(TeamPermission.INVITE_PLAYER);
    expect(permissions).not.toContain(TeamPermission.MAKE_SPORTING_DECISIONS);
    expect(permissions).not.toContain(TeamPermission.VIEW_MANAGEMENT_STATS);
  });

  it('grants coach sporting decisions and roster management', () => {
    const permissions = permissionsForTeamRoles([TeamRole.COACH]);

    expect(permissions).toContain(TeamPermission.MANAGE_ROSTER);
    expect(permissions).toContain(TeamPermission.INVITE_PLAYER);
    expect(permissions).toContain(TeamPermission.MAKE_SPORTING_DECISIONS);
    expect(permissions).toContain(TeamPermission.RECORD_LIVE_EVENTS);
    expect(permissions).toContain(TeamPermission.VIEW_MANAGEMENT_STATS);
  });

  it('limits staff to authorized assistance capabilities', () => {
    const permissions = permissionsForTeamRoles([TeamRole.STAFF_ASSISTANT]);

    expect(permissions).toContain(TeamPermission.VIEW_ROSTER);
    expect(permissions).toContain(TeamPermission.RECORD_LIVE_EVENTS);
    expect(permissions).toContain(TeamPermission.VIEW_MANAGEMENT_STATS);
    expect(permissions).not.toContain(TeamPermission.MANAGE_ROSTER);
    expect(permissions).not.toContain(TeamPermission.MAKE_SPORTING_DECISIONS);
  });

  it('limits a player to participation capabilities', () => {
    const permissions = permissionsForTeamRoles([TeamRole.PLAYER]);

    expect(permissions).toEqual([
      TeamPermission.VIEW_ROSTER,
      TeamPermission.RESPOND_AVAILABILITY,
    ]);
  });

  it('unions permissions for cumulative roles without duplicates', () => {
    const permissions = permissionsForTeamRoles([
      TeamRole.COACH,
      TeamRole.PLAYER,
      TeamRole.COACH,
    ]);

    expect(permissions).toContain(TeamPermission.MAKE_SPORTING_DECISIONS);
    expect(permissions).toContain(TeamPermission.RESPOND_AVAILABILITY);
    expect(new Set(permissions).size).toBe(permissions.length);
  });

  it('denies missing memberships and ignores unknown roles', () => {
    expect(
      hasTeamPermission(null, TeamPermission.VIEW_ROSTER),
    ).toBe(false);
    expect(permissionsForTeamRoles(['UNKNOWN_ROLE'])).toEqual([]);
  });
});
