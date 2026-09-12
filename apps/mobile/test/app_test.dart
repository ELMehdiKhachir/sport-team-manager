import 'package:flutter_test/flutter_test.dart';
import 'package:sport_team_manager/app/app.dart';

void main() {
  testWidgets('shows the bootstrap home page', (tester) async {
    await tester.pumpWidget(const SportTeamManagerApp());

    expect(find.text('Le terrain est prêt.'), findsOneWidget);
    expect(find.text('Thème du club'), findsOneWidget);
  });
}
