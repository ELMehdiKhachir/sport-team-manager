export interface TeamSummary {
  id: string;
  name: string;
  club: { id: string; name: string } | null;
  roles: string[];
}
