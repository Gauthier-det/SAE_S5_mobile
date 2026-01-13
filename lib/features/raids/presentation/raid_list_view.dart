// lib/features/raids/presentation/raid_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/raid.dart';
import '../domain/raid_repository.dart';
import 'raid_detail_view.dart';
<<<<<<< HEAD
import 'raid_creation_view.dart';
=======
import '../../races/domain/race_repository.dart';
>>>>>>> main

/// StatefulWidget that displays a scrollable list of available raids
///
/// Takes as parameter:
/// - repository: the repository to fetch raids data (follows clean architecture pattern)
class RaidListView extends StatefulWidget {
  final RaidRepository repository;

  const RaidListView({super.key, required this.repository});

  @override
  State<RaidListView> createState() => _RaidListViewState();
}

/// State associated with RaidListView
/// Manages the list data and handles refresh interactions
class _RaidListViewState extends State<RaidListView> {
  /// Future that will contain the list of raids fetched from the repository
  /// Allows handling async states (loading, success, error)
  late Future<List<Raid>> _raidsFuture;

  /// Method called once when the widget is created
  /// Initiates the fetch of all raids from the repository
  @override
  void initState() {
    super.initState();
    _raidsFuture = widget.repository.getAllRaids();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme to use consistent colors and text styles
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar at the top of the screen
      appBar: AppBar(title: const Text('Raids Disponibles')),

      // FutureBuilder: widget that rebuilds based on Future state
      // Handles 3 main states: loading, error, and success
      body: FutureBuilder<List<Raid>>(
        future: _raidsFuture,
        builder: (context, snapshot) {
          // State 1: LOADING - While data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
<<<<<<< HEAD
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
=======
                  // Circular progress indicator using theme color
                  CircularProgressIndicator(color: theme.colorScheme.primary),
>>>>>>> main
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des raids...',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          // State 2: ERROR - In case of error during fetch
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _raidsFuture = widget.repository.getAllRaids();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('RÉESSAYER'),
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3: SUCCESS - Data is available
          final raids = snapshot.data ?? [];

          // State 3a: SUCCESS but list is empty
          if (raids.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hiking,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun raid disponible',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Revenez plus tard pour découvrir de nouvelles courses',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3b: SUCCESS with data - Display the list
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _raidsFuture = widget.repository.getAllRaids();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: raids.length,
              itemBuilder: (context, index) {
                final raid = raids[index];
<<<<<<< HEAD
                final raidStatus = _getRaidStatus(raid);
                final registrationStatus = _getRegistrationStatus(raid);
                
=======
                final isRegistrationOpen = _isRegistrationOpen(raid);

>>>>>>> main
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
<<<<<<< HEAD
=======
                        final raceRepository = Provider.of<RacesRepository>(
                          context,
                          listen: false,
                        );
>>>>>>> main
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RaidDetailView(
                              raidId: raid.id,
                              repository: widget.repository,
                              raceRepository: raceRepository,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image section
                          if (raid.image != null)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                raid.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: theme.colorScheme.surfaceVariant,
                                    child: Icon(
                                      Icons.landscape,
                                      size: 64,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            ),
<<<<<<< HEAD
                          
                          // Content section
=======

                          // Content section with raid information
>>>>>>> main
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Raid name
                                Text(
                                  raid.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
<<<<<<< HEAD
                                
                                const SizedBox(height: 12),
                                
                                // Status badges row
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildStatusChip(
                                      label: raidStatus.label,
                                      color: raidStatus.color,
                                      icon: Icons.event,
                                    ),
                                    _buildStatusChip(
                                      label: registrationStatus.label,
                                      color: registrationStatus.color,
                                      icon: Icons.app_registration,
=======

                                const SizedBox(height: 8),

                                // Date row with icon
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(raid.timeStart),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                // Location row with icon
                                // Currently just says "Voir détails" - could be enhanced to show actual location
                                Row(
                                  children: [
                                    Icon(
                                      Icons.place,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Voir détails',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Status badge - shows if registration is open or upcoming
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      // Decoration with rounded corners and conditional colors
                                      decoration: BoxDecoration(
                                        color: isRegistrationOpen
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        isRegistrationOpen
                                            ? 'INSCRIPTIONS OUVERTES'
                                            : 'À VENIR',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: isRegistrationOpen
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
>>>>>>> main
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Location
                                _buildInfoRow(
                                  icon: Icons.place,
                                  label: 'Lieu',
                                  value: raid.address?.cityName ?? 'Non spécifié', // ✅ Affiche la ville
                                  theme: theme,
                                ),

                                
                                const SizedBox(height: 8),
                                
                                // Event dates
                                _buildInfoRow(
                                  icon: Icons.calendar_today,
                                  label: 'Dates',
                                  value: '${_formatDate(raid.timeStart)} - ${_formatDate(raid.timeEnd)}',
                                  theme: theme,
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Registration period
                                _buildInfoRow(
                                  icon: Icons.edit_calendar,
                                  label: 'Inscriptions',
                                  value: '${_formatDate(raid.registrationStart)} - ${_formatDate(raid.registrationEnd)}',
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      
      // FloatingActionButton to create new raid
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RaidCreateView(
                repository: widget.repository,
              ),
            ),
          );
          
          if (result == true && mounted) {
            setState(() {
              _raidsFuture = widget.repository.getAllRaids();
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('CRÉER UN RAID'),
      ),
    );
  }

  /// Builds a reusable info row with icon, label and value
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a status chip with icon, label and color
  Widget _buildStatusChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a DateTime to French readable date format (without time)
  /// Example: "13 janvier 2026"
  String _formatDate(DateTime date) {
    final months = [
<<<<<<< HEAD
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
=======
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
>>>>>>> main
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Returns raid status (À venir, En cours, Terminé)
  /// Based on event start and end dates
  _StatusInfo _getRaidStatus(Raid raid) {
    final now = DateTime.now();
    
    if (now.isBefore(raid.timeStart)) {
      return _StatusInfo(
        label: 'À VENIR',
        color: Colors.blue,
      );
    } else if (now.isAfter(raid.timeEnd)) {
      return _StatusInfo(
        label: 'TERMINÉ',
        color: Colors.grey,
      );
    } else {
      return _StatusInfo(
        label: 'EN COURS',
        color: Colors.green,
      );
    }
  }

  /// Returns registration status (À venir, Ouvertes, Closes)
  /// Based on registration start and end dates
  _StatusInfo _getRegistrationStatus(Raid raid) {
    final now = DateTime.now();
    
    if (now.isBefore(raid.registrationStart)) {
      return _StatusInfo(
        label: 'À VENIR',
        color: Colors.orange,
      );
    } else if (now.isAfter(raid.registrationEnd)) {
      return _StatusInfo(
        label: 'CLOSES',
        color: Colors.red,
      );
    } else {
      return _StatusInfo(
        label: 'OUVERTES',
        color: Colors.green,
      );
    }
  }

  /// Checks if registration is currently open for a given raid
  bool _isRegistrationOpen(Raid raid) {
    final now = DateTime.now();
    return now.isAfter(raid.registrationStart) &&
        now.isBefore(raid.registrationEnd);
  }
}

/// Helper class to store status information (label and color)
class _StatusInfo {
  final String label;
  final Color color;

  _StatusInfo({required this.label, required this.color});
}
