// lib/features/teams/presentation/team_race_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae5_g13_mobile/features/team/presentation/team_race_registration.dart';
import '../../../core/database/database_helper.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/team.dart';
import '../domain/team_repository.dart';
import 'team_detail_view.dart';

/// Screen displaying teams registered to a specific race [web:281][web:283][web:287].
///
/// Shows team list with validation badges, member counts, and race info header.
/// Implements multiple UI states (loading, error, empty, loaded) and access
/// control before navigation [web:281][web:285][web:288].
///
/// **UI States [web:281][web:283]:**
/// - Loading: CircularProgressIndicator
/// - Error: Error message with retry button
/// - Empty: Empty state with illustration
/// - Loaded: List with pull-to-refresh [web:284][web:287]
///
/// **Features:**
/// - Access control check before opening team details [web:285][web:288]
/// - Race manager detection via DB query
/// - Network image with fallback to initials
/// - Async member count loading per team
/// - FAB to register new team
///
/// **Permission Checks:**
/// - Determines if user is race manager (for detail view actions)
/// - Checks canAccessTeamDetail before navigation [web:285]
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => TeamRaceListView(
///       repository: teamRepository,
///       raceId: 123,
///       raceName: 'Trail des Montagnes',
///     ),
///   ),
/// );
/// ```
class TeamRaceListView extends StatefulWidget {
  final TeamRepository repository;
  final int raceId;
  final String raceName;

  const TeamRaceListView({
    super.key,
    required this.repository,
    required this.raceId,
    required this.raceName,
  });

  @override
  State<TeamRaceListView> createState() => _TeamRaceListViewState();
}

class _TeamRaceListViewState extends State<TeamRaceListView> {
  List<Team> _teams = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRaceManager = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  /// Loads teams and determines user's race manager status [web:281].
  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Get user ID from auth provider
      _currentUserId = int.parse(currentUser.id);

      // Check if user is race manager via DB query
      final db = await DatabaseHelper.database;
      final race = await db.query(
        'SAN_RACES',
        where: 'RAC_ID = ? AND USE_ID = ?',
        whereArgs: [widget.raceId, _currentUserId],
      );

      _isRaceManager = race.isNotEmpty;

      // Load teams
      final teams = await widget.repository.getRaceTeams(widget.raceId);

      if (mounted) {
        setState(() {
          _teams = teams;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Équipes inscrites'),
        backgroundColor: const Color(0xFF1B3022),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamRaceRegistrationView(
                repository: widget.repository,
                raceId: widget.raceId,
                raceName: widget.raceName,
              ),
            ),
          );

          if (result == true) {
            _loadTeams();
          }
        },
        backgroundColor: const Color(0xFF52B788),
        icon: const Icon(Icons.add),
        label: const Text('Inscrire une équipe'),
      ),
    );
  }

  /// Builds body with state-based rendering [web:281][web:283].
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTeams,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Aucune équipe inscrite',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Soyez la première équipe à vous inscrire !',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTeams,
      child: Column(
        children: [
          // Race info header with team count
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF52B788).withOpacity(0.1),
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
                      Text(
                        widget.raceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_teams.length} équipe${_teams.length > 1 ? 's' : ''} inscrite${_teams.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Team list [web:284][web:287]
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _teams.length,
              itemBuilder: (context, index) {
                final team = _teams[index];
                return _buildTeamCard(team);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds team card with access control on tap [web:285][web:288].
  Widget _buildTeamCard(Team team) {
    final isValid = team.isValid ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          // Check access before navigation [web:285][web:288]
          final canAccess = await widget.repository.canAccessTeamDetail(
            teamId: team.id,
            raceId: widget.raceId,
            userId: _currentUserId!,
          );

          if (!canAccess) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vous n\'avez pas accès à cette équipe'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }

          if (mounted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailView(
                  repository: widget.repository,
                  teamId: team.id,
                  raceId: widget.raceId,
                  isRaceManager: _isRaceManager,
                  currentUserId: _currentUserId!,
                ),
              ),
            );

            if (result == true) {
              _loadTeams();
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Team avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF52B788).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: team.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          team.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultTeamIcon(team.name);
                          },
                        ),
                      )
                    : _buildDefaultTeamIcon(team.name),
              ),

              const SizedBox(width: 16),

              // Team info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            team.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Validation badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isValid
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isValid ? Icons.check_circle : Icons.pending,
                                size: 14,
                                color: isValid
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isValid ? 'Validée' : 'En attente',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isValid
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 4),
                    // Use membersCount from API if available, otherwise check local (fallback)
                    if (team.membersCount != null)
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${team.membersCount} membre${(team.membersCount ?? 0) > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    else
                      FutureBuilder<int>(
                        future: _getTeamMemberCount(team.id),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$count membre${count > 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Chevron icon
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  /// Fallback team avatar showing first letter.
  Widget _buildDefaultTeamIcon(String teamName) {
    return Center(
      child: Text(
        teamName.isNotEmpty ? teamName[0].toUpperCase() : 'T',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF52B788),
        ),
      ),
    );
  }

  /// Async loads member count for team card.
  Future<int> _getTeamMemberCount(int teamId) async {
    try {
      final members = await widget.repository.getTeamMembers(teamId);
      return members.length;
    } catch (e) {
      return 0;
    }
  }
}
