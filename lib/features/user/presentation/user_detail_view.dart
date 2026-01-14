import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../club/data/datasources/club_api_sources.dart';
import '../../club/data/datasources/club_local_sources.dart';
import '../../../core/config/app_config.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _clubName;
  bool _isLoadingClub = true;

  @override
  void initState() {
    super.initState();
    _loadClub();
  }

  Future<void> _loadClub() async {
    final user = context.read<AuthProvider>().currentUser;
    
    // Si le user a déjà un nom de club, l'utiliser directement
    if (user?.club != null && user!.club!.isNotEmpty) {
      setState(() {
        _clubName = user.club;
        _isLoadingClub = false;
      });
      return;
    }
    
    // Si le user a un clubId, charger le club depuis l'API ou le local
    if (user?.clubId != null) {
      try {
        // Essayer depuis l'API
        final clubApi = ClubApiSources(baseUrl: AppConfig.apiBaseUrl);
        final club = await clubApi.getClubById(user!.clubId!);
        if (club != null) {
          setState(() {
            _clubName = club.name;
            _isLoadingClub = false;
          });
          return;
        }
      } catch (e) {
        print('API non disponible pour le club, chargement local: $e');
      }
      
      try {
        // Fallback sur le local
        final clubLocal = ClubLocalSources();
        final club = await clubLocal.getClubById(user!.clubId!);
        if (club != null) {
          setState(() {
            _clubName = club.name;
            _isLoadingClub = false;
          });
          return;
        }
      } catch (e) {
        print('Erreur chargement club local: $e');
      }
    }
    
    setState(() {
      _clubName = null;
      _isLoadingClub = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            body: const Center(child: Text('Aucun utilisateur connecté')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon Profil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Se déconnecter',
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Profile Image
                CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            user.profileImageUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: theme.colorScheme.primary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: theme.colorScheme.primary,
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // User Name
                Text(
                  user.fullName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Email
                Text(
                  user.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Profile Details Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                          title: const Text('Nom'),
                          subtitle: Text(user.lastName),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.person, color: theme.colorScheme.primary),
                          title: const Text('Prénom'),
                          subtitle: Text(user.firstName),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.email, color: theme.colorScheme.primary),
                          title: const Text('Email'),
                          subtitle: Text(user.email),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.phone, color: theme.colorScheme.primary),
                          title: const Text('Téléphone'),
                          subtitle: Text(user.phoneNumber ?? 'Non renseigné'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.cake, color: theme.colorScheme.primary),
                          title: const Text('Âge'),
                          subtitle: Text(_calculateAge(user.birthDate)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.groups, color: theme.colorScheme.primary),
                          title: const Text('Club'),
                          subtitle: _isLoadingClub
                              ? const Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Chargement...'),
                                  ],
                                )
                              : Text(_clubName ?? 'Non renseigné'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.badge, color: theme.colorScheme.primary),
                          title: const Text('Numéro de licence'),
                          subtitle: Text(user.licenceNumber ?? 'Non renseigné'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.memory, color: theme.colorScheme.primary),
                          title: const Text('Numéro de puce'),
                          subtitle: Text(user.chipNumber ?? 'Non renseigné'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.location_on, color: theme.colorScheme.primary),
                          title: const Text('Adresse'),
                          subtitle: Text(user.fullAddress ?? 'Non renseignée'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                          title: const Text('Date de création du compte'),
                          subtitle: Text(
                            _formatDate(user.createdAt),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Edit Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      // Recharger le club après modification
                      _loadClub();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('MODIFIER LE PROFIL'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _calculateAge(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) {
      return 'Non renseigné';
    }
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || 
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return '$age ans';
    } catch (e) {
      return 'Non renseigné';
    }
  }
}
