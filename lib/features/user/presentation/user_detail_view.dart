import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                  child:
                      user.profileImageUrl != null &&
                          user.profileImageUrl!.isNotEmpty
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
                          leading: Icon(
                            Icons.person_outline,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Nom'),
                          subtitle: Text(user.lastName),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Prénom'),
                          subtitle: Text(user.firstName),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.email,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Email'),
                          subtitle: Text(user.email),
                          trailing: Icon(
                            Icons.lock,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Téléphone'),
                          subtitle: Text(user.phoneNumber ?? 'Non renseigné'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.cake,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Âge'),
                          subtitle: Text(_calculateAge(user.birthDate)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.groups,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Club'),
                          subtitle: Text(user.club ?? 'Non renseigné'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.badge,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Numéro de licence'),
                          subtitle: Text(user.licenceNumber ?? 'Non renseigné'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Date de création du compte'),
                          subtitle: Text(_formatDate(user.createdAt)),
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
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
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
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
