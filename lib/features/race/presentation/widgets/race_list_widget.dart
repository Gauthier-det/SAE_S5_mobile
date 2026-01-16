// lib/features/raid/presentation/widgets/raid_races_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../race/domain/race.dart';
import '../../../race/domain/race_repository.dart';
import '../../../race/presentation/widgets/race_card.dart';
import '../../../race/presentation/race_detail_view.dart';
import '../../../raid/domain/raid.dart';
import '../../../../core/presentation/widgets/common_loading_view.dart';
import '../../../../core/presentation/widgets/common_empty_view.dart';

/// Filtered race list widget for raid detail screen.
///
/// Displays races for a specific raid with filtering by type (Compétitif/Rando)
/// and minimum age. Uses [FutureBuilder] for async loading and [Provider] for
/// data access [web:138][web:140].
///
/// Example:
/// ```dart
/// RaceListWidget(
///   raid: selectedRaid,
///   raidId: raidId,
/// );
/// ```
class RaceListWidget extends StatefulWidget {
  final Raid raid;
  final int raidId;

  const RaceListWidget({
    super.key,
    required this.raid,
    required this.raidId,
  });

  @override
  State<RaceListWidget> createState() => _RaceListWidgetState();
}

class _RaceListWidgetState extends State<RaceListWidget> {
  late Future<List<Race>> _racesFuture;

  List<Race> _allRaces = [];
  List<Race> _filteredRaces = [];
  String? _selectedType;
  int? _filterAgeMin;
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _racesFuture = Provider.of<RacesRepository>(context, listen: false)
        .getRacesByRaidId(widget.raidId);
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  /// Applies active filters to race list.
  void _applyFilters() {
    setState(() {
      _filteredRaces = _allRaces.where((race) {
        // Type filter
        if (_selectedType != null && race.type != _selectedType) {
          return false;
        }

        // Age filter (race.ageMin must be <= user's minimum age)
        if (_filterAgeMin != null) {
          if (race.ageMin > _filterAgeMin!) return false;
        }

        return true;
      }).toList();
    });
  }

  /// Resets all filters to default state.
  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _filterAgeMin = null;
      _ageController.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = _selectedType != null || _filterAgeMin != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        // Filter bar
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'Filtrer les courses',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (hasFilters)
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Réinitialiser'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Type filter chips [web:184]
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeFilterChip('Compétitif'),
                  _buildTypeFilterChip('Rando/Loisirs'),
                ],
              ),

              const SizedBox(height: 16),

              // Age filter input
              Row(
                children: [
                  const Icon(Icons.cake, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'Âge minimum :',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Ex: 18',
                        suffixText: 'ans',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6B00),
                            width: 2,
                          ),
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            _filterAgeMin = null;
                          } else {
                            _filterAgeMin = int.tryParse(value);
                          }
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Race list with FutureBuilder [web:140]
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List<Race>>(
            future: _racesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CommonLoadingView(
                    message: 'Chargement des courses...');
              }

              _allRaces = snapshot.data ?? [];

              if (_filteredRaces.isEmpty && _allRaces.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _applyFilters();
                });
              }

              if (_allRaces.isEmpty) {
                return CommonEmptyView(
                  icon: Icons.event_busy,
                  title: 'Aucune course',
                  subtitle: widget.raid.isFinished
                      ? 'Ce raid est terminé'
                      : 'Les courses seront bientôt disponibles',
                );
              }

              if (_filteredRaces.isEmpty && hasFilters) {
                return CommonEmptyView(
                  icon: Icons.search_off,
                  title: 'Aucune course trouvée',
                  subtitle: 'Essayez de modifier vos filtres',
                  action: ElevatedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réinitialiser'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredRaces.length,
                itemBuilder: (context, index) {
                  final race = _filteredRaces[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RaceCard(
                      race: race,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RaceDetailView(raceId: race.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds a type filter chip [web:184].
  Widget _buildTypeFilterChip(String type) {
    final isSelected = _selectedType == type;

    return FilterChip(
      label: Text(
        type,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
          _applyFilters();
        });
      },
      selectedColor: const Color(0xFFFF6B00),
      backgroundColor: Colors.grey.shade100,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFF6B00) : Colors.grey.shade300,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
