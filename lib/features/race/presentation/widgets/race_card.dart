// lib/features/races/presentation/widgets/race_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/race.dart';
import '../../domain/race_repository.dart';

/// Race list card widget.
///
/// Displays race summary with type badge, difficulty, dates, and team capacity
/// with live registration count. Shows "COMPLET" badge when fully booked [web:138].
///
/// Example:
/// ```dart
/// RaceCard(
///   race: race,
///   onTap: () => Navigator.push(...),
/// );
/// ```
class RaceCard extends StatelessWidget {
  final Race race;
  final VoidCallback onTap;

  const RaceCard({super.key, required this.race, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = Provider.of<RacesRepository>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type badge and difficulty
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: race.type == 'Compétitif'
                    ? const Color(0xFFFF6B00).withOpacity(0.1)
                    : const Color(0xFF52B788).withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: race.type == 'Compétitif'
                              ? const Color(0xFFFF6B00)
                              : const Color(0xFF52B788),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          race.type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getDifficultyIcon(race.difficulty),
                        size: 18,
                        color: _getDifficultyColor(race.difficulty),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        race.difficulty,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _getDifficultyColor(race.difficulty),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content: Name, date, capacity
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B3022),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDate(race.startDate),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Team capacity with live count [web:138]
                  FutureBuilder<int>(
                    future: repository.getRegisteredTeamsCount(race.id),
                    builder: (context, snapshot) {
                      final registeredTeams = snapshot.data ?? 0;
                      final percentage = (registeredTeams / race.maxTeams * 100)
                          .round();
                      final isFullyBooked = registeredTeams >= race.maxTeams;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.groups, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '$registeredTeams / ${race.maxTeams} équipes',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isFullyBooked)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'COMPLET',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: registeredTeams / race.maxTeams,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFullyBooked
                                    ? Colors.red
                                    : percentage > 75
                                        ? Colors.orange
                                        : const Color(0xFF52B788),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Team size
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${race.teamMembers} personnes par équipe',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns icon for difficulty level.
  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facile':
        return Icons.trending_up;
      case 'moyen':
        return Icons.show_chart;
      case 'difficile':
        return Icons.terrain;
      default:
        return Icons.landscape;
    }
  }

  /// Returns color for difficulty level.
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facile':
        return Colors.green;
      case 'moyen':
        return Colors.orange;
      case 'difficile':
        return Colors.red;
      case 'expert':
      case 'très expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Formats date as "1 jan 2024".
  String _formatDate(DateTime date) {
    final months = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
