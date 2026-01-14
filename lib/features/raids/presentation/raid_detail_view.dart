// lib/features/raids/presentation/raid_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae5_g13_mobile/core/database/database_helper.dart';
import 'package:sae5_g13_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:sae5_g13_mobile/features/races/presentation/race_creation_view.dart';
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
                // Image avec overlay du titre
                Stack(
                  children: [
                    if (raid.image != null)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          raid.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported, size: 64),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        color: const Color(0xFF1B3022),
                        child: const Center(
                          child: Icon(Icons.hiking, size: 64, color: Colors.white70),
                        ),
                      ),

                    // Overlay gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Titre sur l'image
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            raid.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStatusBadge(raid),
                        ],
                      ),
                    ),
                  ],
                ),

                // Informations
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: RaidInfoSection(raid: raid),
                ),

                const Divider(height: 32, thickness: 1),

                // Section Courses
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.directions_run,
                          color: Color(0xFFFF6B00),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Courses disponibles',
                        style: theme.textTheme.titleLarge?.copyWith(
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
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: CommonEmptyView(
                          icon: Icons.event_busy,
                          title: 'Aucune course',
                          subtitle: raid.isFinished
                              ? 'Ce raid est terminé'
                              : 'Les courses seront bientôt disponibles',
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
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<Raid?>(
        future: _raidFuture,
        builder: (context, raidSnapshot) {
          final raid = raidSnapshot.data;
          if (raid == null) return const SizedBox.shrink();

          // Vérifier si le raid est terminé
          final isRaidFinished = DateTime.now().isAfter(raid.timeEnd);

          if (isRaidFinished) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Raid terminé',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<bool>(
            future: _canCreateRace(raid),
            builder: (context, snapshot) {
              if (snapshot.data != true) return const SizedBox.shrink();

              return FloatingActionButton.extended(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RaceCreationView(
                        raid: raid,
                        repository: Provider.of<RacesRepository>(context, listen: false),
                      ),
                    ),
                  );

                  if (result == true && mounted) {
                    setState(() {
                      _racesFuture = Provider.of<RacesRepository>(context, listen: false)
                          .getRacesByRaidId(widget.raidId);
                    });
                  }
                },
                backgroundColor: const Color(0xFFFF6B00),
                icon: const Icon(Icons.add),
                label: const Text('AJOUTER UNE COURSE'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(Raid raid) {
    String label;
    Color color;
    IconData icon;

    if (raid.isFinished) {
      label = 'Terminé';
      color = Colors.grey;
      icon = Icons.event_busy;
    } else if (raid.isInProgress) {
      label = 'En cours';
      color = Colors.green;
      icon = Icons.play_circle_filled;
    } else {
      label = 'À venir';
      color = Colors.blue;
      icon = Icons.upcoming;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _canCreateRace(Raid raid) async {
    try {
      // Vérifier si le raid est terminé
      if (DateTime.now().isAfter(raid.timeEnd)) {
        return false;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) return false;

      // Vérifier si l'utilisateur est le gestionnaire du raid
      final db = await DatabaseHelper.database;
      final users = await db.query(
        'SAN_USERS',
        where: 'USE_MAIL = ?',
        whereArgs: [currentUser.email],
        limit: 1,
      );

      if (users.isEmpty) return false;

      final sqliteUserId = users.first['USE_ID'] as int;

      // Vérifier si c'est le gestionnaire du raid
      return raid.userId == sqliteUserId;
    } catch (e) {
      return false;
    }
  }
}
