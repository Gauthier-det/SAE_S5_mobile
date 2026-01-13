import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/races/presentation/RaceListView.dart';

/// Entry point of the Sanglier Explorer application
void main() {
  runApp(const SanglierExplorerApp());
}

/// Root widget of the application
///
/// Configures the MaterialApp with:
/// - Custom theme
/// - Navigation
/// - Home page
class SanglierExplorerApp extends StatelessWidget {
  const SanglierExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConfig.appName} - Course d\'Orientation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

/// Application home page (temporary placeholder/demo)
///
/// This screen is a simple landing page used to showcase the current
/// theme setup (typography, colors, buttons, and AppBar styling) while
/// the real navigation flow is being implemented.
///
/// Displays:
/// - Welcome message with hero title
/// - Description text
/// - Call-to-action buttons showcasing theme
/// - AppBar with Sanglier Explorer branding
///
/// Note: The navigation actions (profile icon and CTA buttons) are
/// currently placeholders and will be wired to real routes in a later
/// iteration.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Hero Title - Archivo Black
              Text(
                'Bienvenue',
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle - Inter
              Text(
                'Application de gestion de courses d\'orientation',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Additional info
              Text(
                'Explorez la nature, défiez-vous et progressez',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Primary CTA Button - Orange Balise
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RaceListView(),
                    ),
                  );
                },
                child: const Text('VOIR LES COURSES'),
              ),

              // Tertiary Button - Text
              TextButton(
                onPressed: () {
                  // Navigate to info
                },
                child: const Text('EN SAVOIR PLUS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
