// lib/features/races/presentation/widgets/race_participants_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/presentation/widgets/common_info_card.dart';
import '../../domain/race.dart';
import '../../domain/race_repository.dart';

/// Race participants and capacity section.
///
/// Displays team registration count with progress bar, team size, and expected
/// participant range. Fetches live registration data via [Provider] [web:138].
///
/// Example:
/// ```dart
/// RaceParticipantsSection(race: selectedRace);
/// ```
class RaceParticipantsSection extends StatelessWidget {
  final Race race;

  const RaceParticipantsSection({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<RacesRepository>(context, listen: false);

    return FutureBuilder<int>(
      future: repository.getRegisteredTeamsCount(race.id),
      builder: (context, snapshot) {
        final registeredTeams = snapshot.data ?? 0;
        final isFullyBooked = registeredTeams >= race.maxTeams;

        return Column(
          children: [
            // Registered teams count with "COMPLET" badge
            CommonInfoCard(
              icon: Icons.group,
              title: 'Équipes inscrites',
              content: '$registeredTeams / ${race.maxTeams} équipes',
              trailing: isFullyBooked
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'COMPLET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),

            // Capacity progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: registeredTeams / race.maxTeams,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFullyBooked ? Colors.red : const Color(0xFF52B788),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Team size info
            CommonInfoCard(
              icon: Icons.people,
              title: 'Membres par équipe',
              content: '${race.teamMembers} personnes',
            ),
            const SizedBox(height: 12),

            // Expected participant range
            CommonInfoCard(
              icon: Icons.person,
              title: 'Participants attendus',
              content:
                  '${race.minParticipants} - ${race.maxParticipants} personnes',
            ),
          ],
        );
      },
    );
  }
}
