import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_team_manager/core/network/calendar_gateway.dart';
import 'package:sport_team_manager/features/calendar/presentation/calendar_page.dart';

void main() {
  testWidgets('refreshes an initially empty official calendar', (tester) async {
    final gateway = _ReloadableCalendarGateway();
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(gateway: gateway, teamId: 'team-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun match officiel'), findsOneWidget);
    expect(gateway.requests, 1);

    await tester.tap(find.byKey(const Key('reload-empty-calendar')));
    await tester.pumpAndSettle();

    expect(gateway.requests, 2);
    expect(find.text('D2 FUTSAL'), findsOneWidget);
    expect(find.text('Nantes Doulon'), findsOneWidget);
    expect(find.text('Pessac FC'), findsOneWidget);
  });
}

class _ReloadableCalendarGateway implements CalendarGateway {
  int requests = 0;

  @override
  Future<List<OfficialMatchSummary>> getOfficialMatches(String teamId) async {
    requests += 1;
    if (requests == 1) return const [];
    return [
      OfficialMatchSummary(
        id: 'match-1',
        provider: 'FFF',
        startsAt: DateTime.utc(2026, 10, 3, 17),
        venue: 'HOME',
        status: 'SCHEDULED',
        homeTeamName: 'Nantes Doulon',
        awayTeamName: 'Pessac FC',
        competitionName: 'D2 FUTSAL',
        seasonLabel: '2026-2027',
      ),
    ];
  }

  @override
  Future<void> configureOfficialTeamLink(
    String teamId,
    OfficialTeamLinkInput link,
  ) async {}

  @override
  Future<int> syncOfficialMatches(String teamId) async => 0;
}
