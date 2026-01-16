import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sae5_g13_mobile/features/auth/presentation/providers/auth_provider.dart';

import 'package:sae5_g13_mobile/features/race/domain/race_repository.dart';
import 'package:sae5_g13_mobile/features/race/presentation/race_creation_view.dart';
import 'package:sae5_g13_mobile/features/raid/domain/raid.dart';
import '../../../core/presentation/widgets/common_loading_view.dart';
import '../../../core/presentation/widgets/common_error_view.dart';
import '../../../core/presentation/widgets/common_empty_view.dart';
import '../domain/raid_repository.dart';
import 'widgets/raid_info_section.dart';
import '../../race/presentation/widgets/race_list_widget.dart';

/// Raid detail screen with race list and conditional creation FAB.
///
/// Displays raid information, embedded race list, and floating action button
/// for race creation. FAB visibility and state depend on event status, user
/// permissions, and race count limit [web:138][web:140].
///
/// **FAB States:**
/// - Hidden: Raid finished or user not raid manager
/// - Badge: Race limit reached (shows "Limite atteinte X/Y")
/// - Button: Enabled with counter (shows "AJOUTER X/Y")
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => RaidDetailView(
///       raidId: raid.id,
///       repository: raidRepo,
///     ),
///   ),
/// );
/// ```
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

  @override
  void initState() {
    super.initState();
    _raidFuture = widget.repository.getRaidById(widget.raidId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du Raid')),
      body: FutureBuilder<Raid?>(
        future: _raidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CommonLoadingView(message: 'Chargement...');
          }

          if (snapshot.hasError) {
            return CommonErrorView(error: '${snapshot.error}');
          }

          final raid = snapshot.data;
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
                _buildHeader(raid),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: RaidInfoSection(raid: raid),
                ),
                const Divider(height: 32),
                RaceListWidget(raid: raid, raidId: widget.raidId),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<Raid?>(
        future: _raidFuture,
        builder: (context, snapshot) {
          final raid = snapshot.data;
          if (raid == null) return const SizedBox.shrink();

          return _buildFab(context, raid);
        },
      ),
    );
  }

  /// Builds hero header with image, gradient overlay, and status badge [web:138].
  Widget _buildHeader(Raid raid) {
    return Stack(
      children: [
        if (raid.image != null)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              raid.image!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 64),
              ),
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
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
        ),
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
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusBadge(raid),
            ],
          ),
        ),
      ],
    );
  }

  /// Determines and builds status badge based on raid timing.
  Widget _buildStatusBadge(Raid raid) {
    if (raid.isFinished) {
      return _badge('Terminé', Icons.event_busy, Colors.grey);
    }
    if (raid.isInProgress) {
      return _badge('En cours', Icons.play_circle_filled, Colors.green);
    }
    return _badge('À venir', Icons.upcoming, Colors.blue);
  }

  /// Builds colored status badge with icon.
  Widget _badge(String label, IconData icon, Color color) {
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

  /// Builds conditional FAB with race count limit logic [web:140].
  ///
  /// States: Hidden (finished/no permission), Badge (limit reached), Button (enabled).
  Widget _buildFab(BuildContext context, Raid raid) {
    // Hide if raid finished
    if (DateTime.now().isAfter(raid.timeEnd)) {
      return const SizedBox.shrink();
    }

    // Check user permissions
    return FutureBuilder<bool>(
      future: _canCreateRace(context, raid),
      builder: (context, canCreateSnapshot) {
        if (canCreateSnapshot.data != true) {
          return const SizedBox.shrink();
        }

        // Check race count limit
        return FutureBuilder<int>(
          future: _getRaceCount(raid.id),
          builder: (context, raceCountSnapshot) {
            final currentCount = raceCountSnapshot.data ?? 0;
            final maxCount = raid.nbRaces;
            final isLimitReached = currentCount >= maxCount;

            // Show limit badge if reached
            if (isLimitReached) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.red.shade300, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Limite atteinte ($currentCount/$maxCount)',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show add button with counter
            return FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFF6B00),
              icon: const Icon(Icons.add),
              label: Text(
                'AJOUTER ($currentCount/$maxCount)',
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RaceCreationView(
                      raid: raid,
                      repository: Provider.of<RacesRepository>(
                        context,
                        listen: false,
                      ),
                    ),
                  ),
                );

                // Reload raid data after creation
                if (result == true && mounted) {
                  setState(() {
                    _raidFuture = widget.repository.getRaidById(widget.raidId);
                  });
                }
              },
            );
          },
        );
      },
    );
  }

  /// Fetches current race count for raid.
  Future<int> _getRaceCount(int raidId) async {
    try {
      final raceRepository = Provider.of<RacesRepository>(
        context,
        listen: false,
      );
      final races = await raceRepository.getRacesByRaidId(raidId);
      return races.length;
    } catch (_) {
      return 0;
    }
  }

  /// Checks if current user is raid manager.
  Future<bool> _canCreateRace(BuildContext context, Raid raid) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;
      if (user == null) return false;

      final currentUserId = int.tryParse(user.id);
      if (currentUserId == null) return false;

      return raid.userId == currentUserId;
    } catch (_) {
      return false;
    }
  }
}
