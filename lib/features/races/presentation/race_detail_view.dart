// lib/features/races/presentation/race_detail_view.dart (VERSION SIMPLIFIÉE)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/presentation/widgets/common_loading_view.dart';
import '../../../core/presentation/widgets/common_error_view.dart';
import '../../../core/presentation/widgets/common_empty_view.dart';
import '../../../core/presentation/widgets/common_info_card.dart';
import '../../../shared/utils/date_formatter.dart';
import '../domain/race.dart';
import '../domain/race_repository.dart';
import 'widgets/race_header.dart';
import 'widgets/race_participants_section.dart';
import 'widgets/race_ages_section.dart';

class RaceDetailView extends StatefulWidget {
  final int raceId;

  const RaceDetailView({super.key, required this.raceId});

  @override
  State<RaceDetailView> createState() => _RaceDetailViewState();
}

class _RaceDetailViewState extends State<RaceDetailView> {
  late Future<Race?> _raceFuture;
  late Future<int> _teamsCountFuture;

  @override
  void initState() {
    super.initState();
    final repository = Provider.of<RacesRepository>(context, listen: false);
    _raceFuture = repository.getRaceById(widget.raceId);
    _teamsCountFuture = repository.getRegisteredTeamsCount(widget.raceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la course'),
        backgroundColor: const Color(0xFF1B3022),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Race?>(
        future: _raceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CommonLoadingView(message: 'Chargement...');
          }

          if (snapshot.hasError) {
            return CommonErrorView(error: '${snapshot.error}');
          }

          final race = snapshot.data;
          if (race == null) {
            return const CommonEmptyView(
              icon: Icons.search_off,
              title: 'Course introuvable',
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RaceHeader(race: race),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Informations', Icons.info_outline, context),
                      const SizedBox(height: 12),
                      CommonInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Dates',
                        content:
                            '${DateFormatter.formatDateTime(race.startDate)}\n→ ${DateFormatter.formatDateTime(race.endDate)}',
                      ),
                      const SizedBox(height: 12),
                      CommonInfoCard(
                        icon: Icons.timer,
                        title: 'Durée',
                        content: '${race.duration} minutes',
                      ),
                      const SizedBox(height: 12),
                      CommonInfoCard(
                        icon: Icons.terrain,
                        title: 'Difficulté',
                        content: race.difficulty,
                        color: _getDifficultyColor(race.difficulty),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Participants', Icons.groups, context),
                      const SizedBox(height: 12),
                      RaceParticipantsSection(race: race),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Catégories d\'âge', Icons.cake, context),
                      const SizedBox(height: 12),
                      RaceAgesSection(race: race),
                      const SizedBox(height: 32),
                      _buildRegistrationButton(context, race),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildRegistrationButton(BuildContext context, Race race) {
    return FutureBuilder<int>(
      future: _teamsCountFuture,
      builder: (context, snapshot) {
        final registeredTeams = snapshot.data ?? 0;
        final isFullyBooked = registeredTeams >= race.maxTeams;
        final isBeforeStart = DateTime.now().isBefore(race.startDate);

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isFullyBooked || !isBeforeStart
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inscription en cours de développement'),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              isFullyBooked
                  ? Icons.block
                  : !isBeforeStart
                      ? Icons.event_busy
                      : Icons.app_registration,
            ),
            label: Text(
              isFullyBooked
                  ? 'COURSE COMPLÈTE'
                  : !isBeforeStart
                      ? 'INSCRIPTIONS FERMÉES'
                      : 'S\'INSCRIRE',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

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
}
