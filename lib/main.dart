import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sae5_g13_mobile/features/address/data/datasources/address_local_sources.dart';
import 'package:sae5_g13_mobile/features/address/data/repositories/address_repository_impl.dart';
import 'package:sae5_g13_mobile/features/address/domain/address_repository.dart';
import 'package:sae5_g13_mobile/features/club/data/datasources/club_api_sources.dart';
import 'package:sae5_g13_mobile/features/club/data/datasources/club_local_sources.dart';
import 'package:sae5_g13_mobile/features/club/data/repositories/club_repository_impl.dart';
import 'package:sae5_g13_mobile/features/club/domain/club_repository.dart';
import 'package:sae5_g13_mobile/features/team/data/datasources/team_api_sources.dart';
import 'package:sae5_g13_mobile/features/team/data/datasources/team_local_sources.dart';
import 'package:sae5_g13_mobile/features/team/data/repositories/team_repository_impl.dart';
import 'package:sae5_g13_mobile/features/team/domain/team_repository.dart';
import 'package:sae5_g13_mobile/features/user/data/datasources/user_api_sources.dart';
import 'package:sae5_g13_mobile/features/user/data/datasources/user_local_sources.dart';
import 'package:sae5_g13_mobile/features/user/data/repositories/user_repository_impl.dart';
import 'package:sae5_g13_mobile/features/user/domain/user_repository.dart';
import 'core/config/app_config.dart';
import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_sources.dart';
import 'features/raid/presentation/raid_list_view.dart';
import 'features/raid/domain/raid_repository.dart';
import 'features/raid/data/repositories/raid_repository_impl.dart';
import 'features/raid/data/datasources/raid_api_sources.dart';
import 'features/raid/data/datasources/raid_local_sources.dart';
import 'features/race/domain/race_repository.dart';
import 'features/race/data/repositories/race_repository_impl.dart';
import 'features/race/data/datasources/race_api_sources.dart';
import 'features/race/data/datasources/race_local_sources.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/user/presentation/user_detail_view.dart';
import 'features/club/presentation/providers/club_provider.dart';
import 'features/club/presentation/screens/club_list_screen.dart';
import 'features/home.dart';

/// Entry point of the Orient'\Action application
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
            ChangeNotifierProvider<ClubProvider>(create: (_) => ClubProvider()),
            Provider<RaidRepository>.value(
              value: snapshot.data!['raidRepository'],
            ),
            Provider<RacesRepository>.value(
              value: snapshot.data!['raceRepository'],
            ),
            Provider<UserRepository>.value(
              value: snapshot.data!['userRepository'],
            ),
            Provider<ClubRepository>.value(
              value: snapshot.data!['clubRepository'],
            ),
            Provider<AddressRepository>.value(
              value: snapshot.data!['addressRepository'],
            ),
            Provider<TeamRepository>.value(
              value: snapshot.data!['teamRepository'],
            ),
          ],
          child: MaterialApp(
            title: '${AppConfig.appName} - Course d\'Orientation',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: const Locale('fr', 'FR'),
            supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const MainScreen(),
              '/raids': (context) => const RaidsScreen(),
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _createRepositories() async {
    final db = await DatabaseHelper.database;
    final prefs = await SharedPreferences.getInstance();
    final authLocalSources = AuthLocalSources(prefs);

    return {
      'raidRepository': RaidRepositoryImpl(
        apiSources: RaidApiSources(baseUrl: AppConfig.apiBaseUrl),
        localSources: RaidLocalSources(),
        authLocalSources: authLocalSources,
      ),
      'raceRepository': RacesRepositoryImpl(
        apiSources: RaceApiSources(baseUrl: AppConfig.apiBaseUrl),
        localSources: RaceLocalSources(database: db),
      ),
      'userRepository': UserRepositoryImpl(
        apiSources: UserApiSources(baseUrl: AppConfig.apiBaseUrl),
        localSources: UserLocalSources(),
      ),
      'clubRepository': ClubRepositoryImpl(
        apiSources: ClubApiSources(baseUrl: AppConfig.apiBaseUrl),
        localSources: ClubLocalSources(),
      ),
      'addressRepository': AddressRepositoryImpl(
        localSources: AddressLocalSources(),
      ),
      'teamRepository': TeamRepositoryImpl(
        localSources: TeamLocalSources(),
        apiSources: TeamApiSources(baseUrl: AppConfig.apiBaseUrl),
      ),
    };
  }
}

/// Main screen with drawer navigation
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final isAuthenticated = authProvider.isAuthenticated;

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF1B4332)),
                  accountName: Text(
                    isAuthenticated
                        ? user?.fullName ?? 'Utilisateur'
                        : 'Visiteur',
                  ),
                  accountEmail: Text(
                    isAuthenticated ? user?.email ?? '' : 'Non connecté',
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      isAuthenticated ? Icons.person : Icons.person_outline,
                      size: 40,
                      color: const Color(0xFF1B4332),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Accueil'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Voir les Raids'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/raids');
                  },
                ),

                const Divider(), // Séparateur visuel
                // Menu Clubs visible uniquement pour les administrateurs de site
                if (isAuthenticated && user != null && user.isSiteManager)
                  ListTile(
                    leading: const Icon(Icons.groups),
                    title: const Text('Clubs'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClubListScreen(),
                        ),
                      );
                    },
                  ),
                const Divider(),
                if (!isAuthenticated) ...[
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Se connecter'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('S\'inscrire'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ],
                if (isAuthenticated) ...[
                  ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('Mon profil'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Se déconnecter'),
                    onTap: () async {
                      Navigator.pop(context);
                      await authProvider.logout();
                    },
                  ),
                ],
              ],
            ),
          ),
          body: const Home(),
        );
      },
    );
  }
}

/// Screen for displaying raids list
class RaidsScreen extends StatelessWidget {
  const RaidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<RaidRepository>(context, listen: false);
    return RaidListView(repository: repository);
  }
}
