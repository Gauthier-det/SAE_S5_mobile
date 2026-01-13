import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'features/raids/data/datasources/raid_api_sources.dart';
import 'features/raids/data/datasources/raid_local_sources.dart';
import 'features/raids/data/repositories/raid_repository_impl.dart';
import 'features/raids/domain/raid_repository.dart';
import 'features/raids/presentation/raid_list_view.dart';

/// Entry point of the Sanglier Explorer application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser la base de données
  final database = await DatabaseHelper.database;
  
  // Créer les datasources
  final apiSources = RaidApiSources(
    baseUrl: AppConfig.apiBaseUrl, // Ajoute cette constante dans AppConfig
  );
  
  final localSources = RaidLocalSources(
    database: database,
  );
  
  // Créer le repository
  final raidRepository = RaidRepositoryImpl(
    apiSources: apiSources,
    localSources: localSources,
  );
  
  runApp(SanglierExplorerApp(raidRepository: raidRepository));
}

/// Root widget of the application
///
/// Configures the MaterialApp with:
/// - Custom theme
/// - Navigation
/// - Home page
/// - Dependency injection via Provider
class SanglierExplorerApp extends StatelessWidget {
  final RaidRepository raidRepository;
  
  const SanglierExplorerApp({
    super.key,
    required this.raidRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<RaidRepository>.value(
      value: raidRepository,
      child: MaterialApp(
        title: '${AppConfig.appName} - Course d\'Orientation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
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
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = Provider.of<RaidRepository>(context, listen: false);

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
                  color: theme.colorScheme.onSurface.withValues(),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Primary CTA Button - Orange Balise
              ElevatedButton(
                onPressed: () {
                  // Navigate to raid list
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RaidListView(repository: repository),
                    ),
                  );
                },
                child: const Text('VOIR LES RAIDS'),
              ),

              // Tertiary Button - Text
              TextButton(
                onPressed: () {
                  // Navigate to info
                },
                child: const Text('EN SAVOIR PLUS'),

              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await DatabaseHelper.resetDatabase();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Base de données réinitialisée !')),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('RESET DATABASE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
