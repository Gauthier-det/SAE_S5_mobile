// lib/features/raids/presentation/RaidDetailView.dart
import 'package:flutter/material.dart';
import '../domain/raid.dart';
import '../domain/raid_repository.dart';
import '../../races/presentation/widgets/race_card.dart';
import '../../races/domain/race_repository.dart';
import '../../races/domain/models/race.dart';

/// StatefulWidget that displays complete details of a raid
///
/// Takes as parameters:
/// - raidId: the ID of the raid to display
/// - repository: the repository to fetch data (follows clean architecture pattern)
class RaidDetailView extends StatefulWidget {
  final int raidId;
  final RaidRepository repository;
  final RacesRepository raceRepository;

  const RaidDetailView({
    Key? key,
    required this.raidId,
    required this.repository,
    required this.raceRepository,
  }) : super(key: key);

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
    _racesFuture = widget.raceRepository.getRacesByRaidId(widget.raidId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du Raid')),
      body: FutureBuilder<Raid?>(
        future: _raidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _raidFuture = widget.repository.getRaidById(
                          widget.raidId,
                        );
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Raid introuvable'));
          }

          final raid = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (raid.image != null)
                  Image.network(
                    raid.image!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        raid.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Dates de l\'événement',
                        children: [
                          _buildInfoRow(
                            'Début',
                            _formatDateTime(raid.timeStart),
                          ),
                          _buildInfoRow('Fin', _formatDateTime(raid.timeEnd)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.app_registration,
                        title: 'Inscriptions',
                        children: [
                          _buildInfoRow(
                            'Ouverture',
                            _formatDateTime(raid.registrationStart),
                          ),
                          _buildInfoRow(
                            'Clôture',
                            _formatDateTime(raid.registrationEnd),
                          ),
                          _buildInfoRow(
                            'Statut',
                            _getRegistrationStatus(raid),
                            valueColor: _getRegistrationStatusColor(raid),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.contact_mail,
                        title: 'Contact',
                        children: [
                          if (raid.email != null)
                            _buildInfoRow('Email', raid.email!),
                          if (raid.phoneNumber != null)
                            _buildInfoRow('Téléphone', raid.phoneNumber!),
                          if (raid.website != null)
                            _buildInfoRow('Site web', raid.website!),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Courses disponibles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<Race>>(
                        future: _racesFuture,
                        builder: (context, raceSnapshot) {
                          if (raceSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (raceSnapshot.hasError) {
                            return Center(
                              child: Text(
                                'Erreur: ${raceSnapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (!raceSnapshot.hasData ||
                              raceSnapshot.data!.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('Aucune course disponible'),
                              ),
                            );
                          }

                          final races = raceSnapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: races.length,
                            itemBuilder: (context, index) {
                              return RaceCard(
                                race: races[index],
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Détails de la course #${races[index].id}',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
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

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
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
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} à ${dateTime.hour}h${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getRegistrationStatus(Raid raid) {
    final now = DateTime.now();
    if (now.isBefore(raid.registrationStart)) {
      return 'Pas encore ouvertes';
    } else if (now.isAfter(raid.registrationEnd)) {
      return 'Clôturées';
    } else {
      return 'Ouvertes';
    }
  }

  Color _getRegistrationStatusColor(Raid raid) {
    final now = DateTime.now();
    if (now.isBefore(raid.registrationStart)) {
      return Colors.orange;
    } else if (now.isAfter(raid.registrationEnd)) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }
}
