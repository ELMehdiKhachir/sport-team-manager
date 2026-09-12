import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sport Team Manager')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Le terrain est prêt.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Le socle mobile est initialisé. Les fonctionnalités seront ajoutées après validation.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: Icon(Icons.sports_soccer, color: colors.primary),
                  title: const Text('Thème du club'),
                  subtitle: const Text(
                      'Clair, sombre et prêt pour des couleurs dynamiques'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
