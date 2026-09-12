import 'package:flutter/material.dart';
import 'package:sport_team_manager/app/theme/app_theme.dart';
import 'package:sport_team_manager/features/home/presentation/home_page.dart';

class SportTeamManagerApp extends StatelessWidget {
  const SportTeamManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const clubPalette = ClubPalette(primary: Color(0xFF145A3A));

    return MaterialApp(
      title: 'Sport Team Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(clubPalette),
      darkTheme: AppTheme.dark(clubPalette),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

