// lib/features/teams/presentation/team_race_registration_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/database/database_helper.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/team.dart';
import '../domain/team_repository.dart';
import '../../user/domain/user.dart';
import 'widgets/user_autocomplete_selector.dart';

class TeamRaceRegistrationView extends StatefulWidget {
  final TeamRepository repository;
  final int raceId;
  final String raceName;

  const TeamRaceRegistrationView({
    super.key,
    required this.repository,
    required this.raceId,
    required this.raceName,
  });

  @override
  State<TeamRaceRegistrationView> createState() => _TeamRaceRegistrationViewState();
}

class _TeamRaceRegistrationViewState extends State<TeamRaceRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  List<User> _availableUsers = [];
  List<User> _selectedMembers = [];
  bool _isLoading = false;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    
    try {
      final users = await widget.repository.getAvailableUsersForRace(widget.raceId);
      
      if (mounted) {
        setState(() {
          _availableUsers = users;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription en équipe'),
        backgroundColor: const Color(0xFF1B3022),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info course
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52B788).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF52B788),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.directions_run,
                            color: Color(0xFF52B788),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Inscription à la course',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  widget.raceName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info équipe
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Créez votre équipe pour vous inscrire',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Maximum 5 membres par équipe\n'
                            '• Tous les membres doivent avoir au moins 12 ans\n'
                            '• L\'équipe sera soumise à validation',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nom de l'équipe
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'équipe *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                        hintText: 'Les Aventuriers',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        if (value.length < 3) {
                          return 'Le nom doit contenir au moins 3 caractères';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Sélection des membres
                    Text(
                      'Membres de l\'équipe *',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    UserAutocompleteSelector(
                      availableUsers: _availableUsers,
                      selectedMembers: _selectedMembers,
                      onUserSelected: (user) {
                        setState(() {
                          if (_selectedMembers.any((m) => m.id == user.id)) {
                            _selectedMembers.removeWhere((m) => m.id == user.id);
                          } else {
                            _selectedMembers.add(user);
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Bouton créer et s'inscrire
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52B788),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'CRÉER L\'ÉQUIPE ET S\'INSCRIRE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un membre'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final db = await DatabaseHelper.database;
      final users = await db.query(
        'SAN_USERS',
        where: 'USE_MAIL = ?',
        whereArgs: [currentUser.email],
        limit: 1,
      );

      if (users.isEmpty) {
        throw Exception('Utilisateur introuvable');
      }

      final userId = users.first['USE_ID'] as int;

      final team = Team(
        id: DateTime.now().millisecondsSinceEpoch,
        managerId: userId,
        name: _nameController.text,
      );

      final memberIds = _selectedMembers.map((m) => m.id).toList();
      
      await widget.repository.createTeamAndRegisterToRace(
        team: team,
        memberIds: memberIds,
        raceId: widget.raceId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Équipe créée et inscrite avec succès !'),
            backgroundColor: Color(0xFF52B788),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
