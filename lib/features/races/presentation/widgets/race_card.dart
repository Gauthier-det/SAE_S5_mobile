import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/Race.dart';

/// Card pour afficher une course dans la liste
class RaceCard extends StatelessWidget {
  final Race race;
  final VoidCallback onTap;

  const RaceCard({super.key, required this.race, required this.onTap});

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Facile':
        return Colors.green;
      case 'Moyen':
        return Colors.orange.shade300;
      case 'Difficile':
        return Colors.orange.shade600;
      case 'Expert':
        return Colors.red.shade400;
      case 'Très Expert':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec titre et type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge difficulté
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(race.difficulty),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      race.difficultyLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Titre de la course
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Course #${race.id}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Raid ID: ${race.raidId}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  // Badge type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: race.type == 'Compétitif'
                          ? const Color(0xFFFF6B00)
                          : const Color(0xFF2D5A27),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      race.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Informations détaillées
              Row(
                children: [
                  // Date
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateFormat.format(race.startDate),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Âge
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        '${race.ageMin}+ ans',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Durée
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Durée: ${race.formattedDuration}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Participants
                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        '${race.minParticipants}-${race.maxParticipants}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Équipes et bouton détails
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Info équipes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Équipes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${race.minTeams}-${race.maxTeams} (${race.teamMembers} membres)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D5A27),
                            ),
                      ),
                    ],
                  ),
                  // Bouton détails
                  ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Détails'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3022),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
