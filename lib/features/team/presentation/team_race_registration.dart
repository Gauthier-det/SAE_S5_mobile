// lib/features/teams/presentation/team_race_registration_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/team.dart';
import '../domain/team_repository.dart';
import '../../user/domain/user.dart';
import 'widgets/user_autocomplete_selector.dart';

/// Form screen for creating and registering a team to a race [web:289][web:290][web:296].
///
/// Two-part form: team name input + multi-select member autocomplete.
/// Validates business rules (team size, age, gender, conflicts) and performs
/// atomic team creation + race registration [web:298].
///
/// **Business Rules (enforced via filtered user list):**
/// - Max team size (configurable per race, default 5)
/// - Members must be ≥12 years old
/// - Gender matching if race requires specific gender (not Mixte)
/// - No time conflicts with other races
/// - Users already in teams excluded
///
/// **Form Validation [web:289][web:290]:**
/// - Team name: Required, min 3 characters
/// - Members: At least 1 member required
/// - Real-time feedback on member count vs max size
///
/// **Atomic Operation [web:298]:**
/// - Creates team
/// - Registers team to race (generates dossard)
/// - Registers all members individually
/// - All steps succeed or all fail together
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => TeamRaceRegistrationView(
///       repository: teamRepository,
///       raceId: 123,
///       raceName: 'Trail des Montagnes',
///     ),
///   ),
/// );
/// ```
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
  State<TeamRaceRegistrationView> createState() =>
      _TeamRaceRegistrationViewState();
}

class _TeamRaceRegistrationViewState extends State<TeamRaceRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  List<User> _availableUsers = [];
  final List<User> _selectedMembers = [];
  bool _isLoading = false;
  bool _isLoadingUsers = true;

  int _maxTeamSize = 5;
  String? _requiredGender;

  @override
  void initState() {
    super.initState();
    _loadRaceDetails();
    _loadUsers();
  }

  /// Loads race configuration (max team size, gender requirement).
  Future<void> _loadRaceDetails() async {
      final details = await widget.repository.getRaceDetails(widget.raceId);

      if (mounted && details != null) {
        setState(() {
          _maxTeamSize = details['RAC_MAX_TEAM_MEMBERS'] as int? ?? 5;
          _requiredGender = details['RAC_GENDER']?.toString();
        });
      }
  }

  /// Loads pre-filtered eligible users (age, gender, conflicts checked).
  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);

    try {
      final users = await widget.repository.getAvailableUsersForRace(
        widget.raceId,
      );

      if (mounted) {
        setState(() {
          _availableUsers = users;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
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
                    // Race info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52B788),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF52B788)),
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
                                if (_requiredGender != null &&
                                    _requiredGender != 'Mixte')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Course $_requiredGender uniquement',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Team requirements info card
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
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
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
                            '• Maximum $_maxTeamSize membres par équipe\n'
                            '• Tous les membres doivent avoir au moins 12 ans\n'
                            '• Les personnes affichées sont déjà filtrées selon les critères',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Team name field [web:289][web:290]
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

                    // Member selection section
                    Text(
                      'Membres de l\'équipe * (${_selectedMembers.length}/$_maxTeamSize)',
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
                            // Remove member
                            _selectedMembers.removeWhere(
                              (m) => m.id == user.id,
                            );
                          } else {
                            // Check team size limit
                            if (_selectedMembers.length >= _maxTeamSize) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Nombre maximum de membres atteint ($_maxTeamSize)',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            // Add member
                            _selectedMembers.add(user);
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Submit button with loading state [web:289]
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

  /// Validates and submits form with atomic team creation [web:289][web:298].
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

      // Parse userId from auth provider (String → int)
      final userId = int.tryParse(currentUser.id);

      if (userId == null || userId == 0) {
        throw Exception('ID utilisateur invalide (non numérique)');
      }

      final team = Team(
        id: DateTime.now().millisecondsSinceEpoch,
        managerId: userId,
        name: _nameController.text,
      );

      final memberIds = _selectedMembers.map((m) => m.id).toList();

      // Atomic operation: create team + register to race + register members [web:298]
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
