import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/races/presentation/RaceListView.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

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

  const SanglierExplorerApp({
    required this.authProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
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
  }
}

/// Application home page
///
/// This screen is the main landing page of the application.
/// Displays:
/// - Welcome message
/// - Information about the app
/// - Login/Profile icon in AppBar
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

                  const SizedBox(height: 8),

                  // Additional info
                  Text(
                    'Explorez la nature, défiez-vous et progressez',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

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
                  const SizedBox(height: 48),

                  // User info (only if authenticated)
                  if (isAuthenticated) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil utilisateur',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nom: ${user?.fullName}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email: ${user?.email}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],

                  // Primary CTA Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to races
                    },
                    child: const Text('VOIR LES COURSES'),
                  ),

                  // Tertiary Button
                  TextButton(
                    onPressed: () {
                      // Navigate to info
                    },
                    child: const Text('EN SAVOIR PLUS'),
                  ),

                  // Login button if not authenticated
                  if (!isAuthenticated) ...[
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Se connecter'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
