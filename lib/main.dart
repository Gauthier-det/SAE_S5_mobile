import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'features/raids/presentation/raid_list_view.dart';
import 'features/raids/domain/raid_repository.dart';
import 'features/raids/data/repositories/raid_repository_impl.dart';
import 'features/raids/data/datasources/raid_api_sources.dart';
import 'features/raids/data/datasources/raid_local_sources.dart';
import 'features/races/domain/race_repository.dart';
import 'features/races/data/repositories/race_repository_impl.dart';
import 'features/races/data/datasources/race_api_sources.dart';
import 'features/races/data/datasources/race_local_sources.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/user/presentation/user_detail_view.dart';

/// Entry point of the Sanglier Explorer application
void main() async {
  // Ensure Flutter bindings are initialized before using async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthProvider
  final authProvider = await AuthProvider.create();
  runApp(SanglierExplorerApp(authProvider: authProvider));
}

/// Root widget of the application
///
/// Configures the MaterialApp with:
/// - Custom theme
/// - Provider for state management
/// - Navigation based on authentication status
class SanglierExplorerApp extends StatelessWidget {
  final AuthProvider authProvider;

  const SanglierExplorerApp({required this.authProvider, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _createRepositories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            Provider<RaidRepository>.value(
              value: snapshot.data!['raidRepository'],
            ),
            Provider<RacesRepository>.value(
              value: snapshot.data!['raceRepository'],
            ),
          ],
          child: MaterialApp(
            title: '${AppConfig.appName} - Course d\'Orientation',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const HomePage(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomePage(),
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _createRepositories() async {
    final db = await DatabaseHelper.database;
    return {
      'raidRepository': RaidRepositoryImpl(
        apiSources: RaidApiSources(baseUrl: AppConfig.apiBaseUrl),
        localSources: RaidLocalSources(database: db),
      ),
      'raceRepository': RacesRepositoryImpl(
        apiSources: RaceApiSources(baseUrl: AppConfig.apiBaseUrl),
        localSources: RaceLocalSources(database: db),
      ),
    };
  }
}

/// Application home page
///
/// This screen is the main landing page of the application.
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

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final isAuthenticated = authProvider.isAuthenticated;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppConfig.appName),
            actions: [
              IconButton(
                icon: Icon(
                  isAuthenticated ? Icons.account_circle : Icons.login,
                ),
                tooltip: isAuthenticated ? 'Profil' : 'Se connecter',
                onPressed: () {
                  if (isAuthenticated) {
                    // Show profile menu
                    showMenu<dynamic>(
                      context: context,
                      position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
                      items: <PopupMenuEntry<dynamic>>[
                        PopupMenuItem<dynamic>(
                          enabled: false,
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user?.fullName ?? ''),
                            subtitle: Text(user?.email ?? ''),
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<dynamic>(
                          child: const ListTile(
                            leading: Icon(Icons.visibility),
                            title: Text('Voir le profil'),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        PopupMenuItem<dynamic>(
                          child: const ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Se déconnecter'),
                          ),
                          onTap: () async {
                            await authProvider.logout();
                          },
                        ),
                      ],
                    );
                  } else {
                    // Navigate to login
                    Navigator.of(context).pushNamed('/login');
                  }
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

                  // Hero Title
                  Text(
                    isAuthenticated
                        ? 'Bienvenue ${user?.firstName}!'
                        : 'Bienvenue',
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Application de gestion de courses d\'orientation',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

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
                      // Navigate to raid list
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RaidListView(repository: repository),
                        ),
                      );
                    },
                    child: const Text('VOIR LES RAIDS'),
                  ),

                  const SizedBox(height: 16),

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
                        const SnackBar(
                          content: Text('Base de données réinitialisée !'),
                        ),
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
      },
    );
  }
}
