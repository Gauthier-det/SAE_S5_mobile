// lib/features/raids/presentation/raid_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/raid.dart';
import '../domain/raid_repository.dart';
import 'raid_detail_view.dart';
import '../../races/domain/race_repository.dart';

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
                  // Circular progress indicator using theme color
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  // Loading message
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
                    // Error icon with theme error color
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    // Error title
                    Text(
                      'Erreur de chargement',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    // Error message with actual error details
                    Text(
                      '${snapshot.error}',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Retry button - triggers a new fetch
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
          // Get the list, defaulting to empty list if null
          final raids = snapshot.data ?? [];

          // State 3a: SUCCESS but list is empty
          if (raids.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Empty state icon with semi-transparent theme color
                    Icon(
                      Icons.hiking,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    // Empty state title
                    Text(
                      'Aucun raid disponible',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    // Empty state message
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
          // RefreshIndicator: enables pull-to-refresh gesture
          return RefreshIndicator(
            onRefresh: () async {
              // Trigger a new fetch when user pulls down
              setState(() {
                _raidsFuture = widget.repository.getAllRaids();
              });
            },
            // ListView.builder: efficiently builds list items on-demand
            // Only renders visible items + a few offscreen for smooth scrolling
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: raids.length,
              itemBuilder: (context, index) {
                // Get the current raid for this list item
                final raid = raids[index];
                final isRegistrationOpen = _isRegistrationOpen(raid);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  // Card: Material Design card with elevation
                  child: Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias, // Clips child to card shape
                    // InkWell: adds ripple effect on tap
                    child: InkWell(
                      onTap: () {
                        final raceRepository = Provider.of<RacesRepository>(
                          context,
                          listen: false,
                        );
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
                          // Image section (only displayed if image URL exists)
                          if (raid.image != null)
                            // AspectRatio: maintains 16:9 ratio for consistent card heights
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                raid.image!,
                                fit: BoxFit.cover, // Fills the space, may crop
                                // Error builder: displays placeholder if image fails to load
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

                          // Content section with raid information
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Raid name - bold title
                                Text(
                                  raid.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

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
                                    ),
                                  ],
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
    );
  }

  /// Formats a DateTime to French readable date format (without time)
  /// Example: "13 janvier 2026"
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

  /// Checks if registration is currently open for a given raid
  /// Compares current date with registration start and end dates
  /// Returns true if we're between start and end dates
  bool _isRegistrationOpen(Raid raid) {
    final now = DateTime.now();
    return now.isAfter(raid.registrationStart) &&
        now.isBefore(raid.registrationEnd);
  }
}
