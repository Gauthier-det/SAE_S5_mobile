// lib/features/raids/presentation/raid_detail_view.dart (VERSION SIMPLIFIÉE)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/presentation/widgets/common_loading_view.dart';
import '../../../core/presentation/widgets/common_error_view.dart';
import '../../../core/presentation/widgets/common_empty_view.dart';
import '../domain/raid.dart';
import '../domain/raid_repository.dart';
import '../../races/domain/race.dart';
import '../../races/domain/race_repository.dart';
import '../../races/presentation/widgets/race_card.dart';
import '../../races/presentation/race_detail_view.dart';
import 'widgets/raid_info_section.dart';

class RaidDetailView extends StatefulWidget {
  final int raidId;
  final RaidRepository repository;

  const RaidDetailView({
    super.key,
    required this.raidId,
    required this.repository,
  });

  @override
  State<RaidDetailView> createState() => _RaidDetailViewState();
}

class _RaidDetailViewState extends State<RaidDetailView> {
  late Future<Raid?> _raidFuture;
  late Future<List<Race>> _racesFuture;

  @override
  void initState() {
    super.initState();
    _raidFuture = widget.repository.getRaidById(widget.raidId);
    final racesRepo = Provider.of<RacesRepository>(context, listen: false);
    _racesFuture = racesRepo.getRacesByRaidId(widget.raidId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du Raid')),
      body: FutureBuilder<Raid?>(
        future: _raidFuture,
        builder: (context, raidSnapshot) {
          if (raidSnapshot.connectionState == ConnectionState.waiting) {
            return const CommonLoadingView(message: 'Chargement...');
          }

          if (raidSnapshot.hasError) {
            return CommonErrorView(error: '${raidSnapshot.error}');
          }

          final raid = raidSnapshot.data;
          if (raid == null) {
            return const CommonEmptyView(
              icon: Icons.search_off,
              title: 'Raid introuvable',
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (raid.image != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(raid.image!, fit: BoxFit.cover),
                  ),

                // Infos
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        raid.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RaidInfoSection(raid: raid),
                    ],
                  ),
                ),

                const Divider(height: 32, thickness: 2),

                // Courses
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.directions_run, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Courses du raid',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                FutureBuilder<List<Race>>(
                  future: _racesFuture,
                  builder: (context, racesSnapshot) {
                    if (racesSnapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: CommonLoadingView(),
                      );
                    }

                    final races = racesSnapshot.data ?? [];
                    if (races.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: CommonEmptyView(
                          icon: Icons.event_busy,
                          title: 'Aucune course',
                          subtitle: 'Ce raid n\'a pas encore de courses',
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: races.length,
                      itemBuilder: (context, index) {
                        return RaceCard(
                          race: races[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RaceDetailView(
                                  raceId: races[index].id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
