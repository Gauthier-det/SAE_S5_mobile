// lib/features/races/presentation/race_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae5_g13_mobile/core/config/app_config.dart';
import 'package:sae5_g13_mobile/features/team/data/datasources/team_api_sources.dart';
import 'package:sae5_g13_mobile/features/team/data/datasources/team_local_sources.dart';
import 'package:sae5_g13_mobile/features/team/data/repositories/team_repository_impl.dart';
import 'package:sae5_g13_mobile/features/team/domain/team_repository.dart';
import 'package:sae5_g13_mobile/features/team/presentation/team_list_view.dart';
import 'package:sae5_g13_mobile/features/team/presentation/team_race_registration.dart';
import '../../../core/presentation/widgets/common_loading_view.dart';
import '../../../core/presentation/widgets/common_error_view.dart';
import '../../../core/presentation/widgets/common_empty_view.dart';
import '../../../shared/utils/date_formatter.dart';
import '../domain/race.dart';
import '../domain/race_repository.dart';
import 'widgets/race_header.dart';
import 'widgets/race_quick_stats.dart';
import 'widgets/race_participants_section.dart';
import 'widgets/race_ages_section.dart';
import 'widgets/race_pricing_section.dart';
import 'widgets/race_detail_section.dart';

class RaceDetailView extends StatefulWidget {
  final int raceId;

  const RaceDetailView({super.key, required this.raceId});

  @override
  State<RaceDetailView> createState() => _RaceDetailViewState();
}

class _RaceDetailViewState extends State<RaceDetailView> {
  late Future<Race?> _raceFuture;
  late Future<int> _teamsCountFuture;
  late TeamRepository _teamRepository;

  @override
  void initState() {
    super.initState();
    final repository = Provider.of<RacesRepository>(context, listen: false);
    _raceFuture = repository.getRaceById(widget.raceId);
    _teamsCountFuture = repository.getRegisteredTeamsCount(widget.raceId);
    final teamRepository = Provider.of<TeamRepository>(context, listen: false);
    _teamRepository = teamRepository;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
            return Scaffold(
              appBar: AppBar(title: const Text('Course introuvable')),
              body: const CommonEmptyView(
                icon: Icons.search_off,
                title: 'Course introuvable',
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // AppBar simple
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: race.type == 'Compétitif'
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFF52B788),
                flexibleSpace: FlexibleSpaceBar(
                  background: RaceHeader(race: race),
                ),
                actions: [
                  // Bouton pour voir les équipes inscrites
                  IconButton(
                    icon: const Icon(Icons.groups),
                    tooltip: 'Équipes inscrites',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamRaceListView(
                            repository: _teamRepository,
                            raceId: widget.raceId,
                            raceName: _getRaceName(race),
                          ),
                        ),
                      ).then((_) {
                        // Recharger le nombre d'équipes après retour
                        setState(() {
                          final repository = Provider.of<RacesRepository>(
                            context,
                            listen: false,
                          );
                          _teamsCountFuture = repository
                              .getRegisteredTeamsCount(widget.raceId);
                        });
                      });
                    },
                  ),
                ],
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Stats rapides
                    RaceQuickStats(race: race),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Section Dates
                          RaceDetailSection(
                            title: 'Dates',
                            icon: Icons.schedule,
                            color: const Color(0xFFFF6B00),
                            child: Column(
                              children: [
                                _buildSimpleRow(
                                  'Début',
                                  DateFormatter.formatDateTime(race.startDate),
                                ),
                                const Divider(height: 20),
                                _buildSimpleRow(
                                  'Fin',
                                  DateFormatter.formatDateTime(race.endDate),
                                ),
                              ],
                            ),
                          ),

                          // Section Participants
                          RaceDetailSection(
                            title: 'Participants',
                            icon: Icons.groups,
                            color: const Color(0xFF52B788),
                            child: RaceParticipantsSection(race: race),
                          ),

                          // Section Âges
                          RaceDetailSection(
                            title: 'Catégories d\'âge',
                            icon: Icons.cake,
                            color: const Color(0xFF1B3022),
                            child: RaceAgesSection(race: race),
                          ),

                          // Section Tarifs
                          RaceDetailSection(
                            title: 'Tarifs',
                            icon: Icons.euro,
                            color: Colors.blue,
                            child: RacePricingSection(raceId: widget.raceId),
                          ),

                          const SizedBox(height: 16),

                          // Bouton voir les équipes
                          _buildTeamsButton(race),

                          const SizedBox(height: 12),

                          // Bouton inscription
                          _buildRegistrationButton(race),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTeamsButton(Race race) {
    return FutureBuilder<int>(
      future: _teamsCountFuture,
      builder: (context, snapshot) {
        final registeredTeams = snapshot.data ?? 0;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamRaceListView(
                    repository: _teamRepository,
                    raceId: widget.raceId,
                    raceName: _getRaceName(race),
                  ),
                ),
              ).then((_) {
                // Recharger après retour
                setState(() {
                  final repository = Provider.of<RacesRepository>(
                    context,
                    listen: false,
                  );
                  _teamsCountFuture = repository.getRegisteredTeamsCount(
                    widget.raceId,
                  );
                });
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: race.type == 'Compétitif'
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFF52B788),
                width: 2,
              ),
              foregroundColor: race.type == 'Compétitif'
                  ? const Color(0xFFFF6B00)
                  : const Color(0xFF52B788),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.groups),
            label: Text(
              'VOIR LES ÉQUIPES ($registeredTeams/${race.maxTeams})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegistrationButton(Race race) {
    return FutureBuilder<int>(
      future: _teamsCountFuture,
      builder: (context, snapshot) {
        final registeredTeams = snapshot.data ?? 0;
        final isFullyBooked = registeredTeams >= race.maxTeams;
        final isBeforeStart = DateTime.now().isBefore(race.startDate);

        String buttonText;
        IconData buttonIcon;
        Color? buttonColor;
        bool isEnabled = false;

        if (isFullyBooked) {
          buttonText = 'COMPLET';
          buttonIcon = Icons.block;
          buttonColor = Colors.grey;
        } else if (!isBeforeStart) {
          buttonText = 'FERMÉ';
          buttonIcon = Icons.lock;
          buttonColor = Colors.grey;
        } else {
          buttonText = 'S\'INSCRIRE EN ÉQUIPE';
          buttonIcon = Icons.check_circle;
          buttonColor = race.type == 'Compétitif'
              ? const Color(0xFFFF6B00)
              : const Color(0xFF52B788);
          isEnabled = true;
        }

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: !isEnabled
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamRaceRegistrationView(
                          repository: _teamRepository,
                          raceId: widget.raceId,
                          raceName: _getRaceName(race),
                        ),
                      ),
                    );

                    // Si une inscription a été faite, recharger
                    if (result == true && mounted) {
                      setState(() {
                        final repository = Provider.of<RacesRepository>(
                          context,
                          listen: false,
                        );
                        _teamsCountFuture = repository.getRegisteredTeamsCount(
                          widget.raceId,
                        );
                      });
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: isEnabled ? 3 : 0,
            ),
            icon: Icon(buttonIcon),
            label: Text(
              buttonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  String _getRaceName(Race race) {
    return race.name;
  }
}
