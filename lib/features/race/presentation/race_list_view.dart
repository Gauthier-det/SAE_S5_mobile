// lib/features/race/presentation/widgets/race_list_widget.dart
import 'package:flutter/material.dart';
import 'package:sae5_g13_mobile/features/race/domain/race.dart';
import 'package:sae5_g13_mobile/features/race/domain/race_repository.dart';
import 'package:sae5_g13_mobile/features/race/presentation/race_detail_view.dart';
import 'package:sae5_g13_mobile/features/race/presentation/widgets/race_card.dart';
import '../../../../core/presentation/widgets/common_loading_view.dart';
import '../../../../core/presentation/widgets/common_error_view.dart';
import '../../../../core/presentation/widgets/common_empty_view.dart';
import '../../../../core/presentation/widgets/common_results_header.dart';

/// Widget de liste de courses SANS Scaffold (pour réutilisation dans d'autres pages)
class RaceListView extends StatefulWidget {
  final RacesRepository repository;
  final int? raidId;
  final String? raidName;

  const RaceListView({
    super.key,
    required this.repository,
    this.raidId,
    this.raidName,
  });

  @override
  State<RaceListView> createState() => _RaceListViewState();
}

class _RaceListViewState extends State<RaceListView> {
  late Future<List<Race>> _racesFuture;
  List<Race> _allRaces = [];
  List<Race> _filteredRaces = [];

  // Filtres
  String? _selectedType;
  int? _filterAgeMin;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  void _loadRaces() {
    _racesFuture = widget.raidId != null
        ? widget.repository.getRacesByRaidId(widget.raidId!)
        : widget.repository.getRaces();
  }

  void _applyFilters() {
    setState(() {
      _filteredRaces = _allRaces.where((race) {
        if (_selectedType != null && race.type != _selectedType) {
          return false;
        }
        
        if (_filterAgeMin != null) {
          if (race.ageMin == null) {
            return false;
          }
          if (race.ageMin! > _filterAgeMin!) {
            return false;
          }
        }
        
        return true;
      }).toList();

      _filteredRaces.sort((a, b) => _sortAscending
          ? a.startDate.compareTo(b.startDate)
          : b.startDate.compareTo(a.startDate));
    });
  }

  Future<void> _selectAgeMin() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Âge minimum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sélectionnez l\'âge minimum requis :'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int age in [6, 8, 10, 12, 14, 16, 18, 21])
                  ChoiceChip(
                    label: Text('$age ans'),
                    selected: _filterAgeMin == age,
                    onSelected: (selected) {
                      Navigator.pop(context, selected ? age : null);
                    },
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, -1),
            child: const Text('Effacer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _filterAgeMin = result == -1 ? null : result;
        _applyFilters();
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _filterAgeMin = null;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _selectedType != null || _filterAgeMin != null;

    return FutureBuilder<List<Race>>(
      future: _racesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CommonLoadingView(message: 'Chargement des courses...');
        }

        if (snapshot.hasError) {
          return CommonErrorView(
            error: '${snapshot.error}',
            onRetry: () {
              setState(() {
                _loadRaces();
              });
            },
          );
        }

        _allRaces = snapshot.data ?? [];
        if (_filteredRaces.isEmpty || _filteredRaces.length != _allRaces.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _applyFilters();
          });
        }

        if (_allRaces.isEmpty) {
          return const CommonEmptyView(
            icon: Icons.event_busy,
            title: 'Aucune course disponible',
          );
        }

        return Column(
          children: [
            // Barre de filtres
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filtrer les courses',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (hasActiveFilters)
                        TextButton(
                          onPressed: _resetFilters,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text(
                            'Réinitialiser',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTypeFilterChip('Compétitif'),
                        const SizedBox(width: 8),
                        _buildTypeFilterChip('Rando/Loisirs'),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _selectAgeMin,
                          icon: Icon(
                            Icons.cake,
                            size: 16,
                            color: _filterAgeMin != null 
                                ? const Color(0xFFFF6B00) 
                                : Colors.grey,
                          ),
                          label: Text(
                            _filterAgeMin != null 
                                ? 'Âge min: ${_filterAgeMin}+' 
                                : 'Âge min',
                            style: TextStyle(
                              fontSize: 12,
                              color: _filterAgeMin != null 
                                  ? const Color(0xFFFF6B00) 
                                  : Colors.grey,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                            side: BorderSide(
                              color: _filterAgeMin != null
                                  ? const Color(0xFFFF6B00)
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Badge filtres actifs
            if (hasActiveFilters)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_filteredRaces.length} course${_filteredRaces.length > 1 ? 's' : ''} trouvée${_filteredRaces.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            CommonResultsHeader(
              count: _filteredRaces.length,
              itemName: 'course',
              sortLabel: 'Par date',
              sortAscending: _sortAscending,
              onSortToggle: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                  _applyFilters();
                });
              },
            ),

            Expanded(
              child: _filteredRaces.isEmpty
                  ? CommonEmptyView(
                      icon: Icons.search_off,
                      title: 'Aucune course trouvée',
                      subtitle: 'Essayez de modifier vos filtres',
                      action: hasActiveFilters
                          ? ElevatedButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réinitialiser'),
                            )
                          : null,
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _loadRaces();
                        });
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredRaces.length,
                        itemBuilder: (context, index) {
                          return RaceCard(
                            race: _filteredRaces[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RaceDetailView(
                                    raceId: _filteredRaces[index].id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeFilterChip(String type) {
    final isSelected = _selectedType == type;
    
    return FilterChip(
      label: Text(
        type,
        style: TextStyle(
          fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
      side: BorderSide(
        color: isSelected ? const Color(0xFFFF6B00) : Colors.grey.shade300,
      ),
    );
  }
}
