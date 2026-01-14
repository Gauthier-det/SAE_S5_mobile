// lib/features/races/presentation/race_list_view.dart (VERSION SIMPLIFIÉE)
import 'package:flutter/material.dart';
import '../../../core/presentation/widgets/common_loading_view.dart';
import '../../../core/presentation/widgets/common_error_view.dart';
import '../../../core/presentation/widgets/common_empty_view.dart';
import '../../../core/presentation/widgets/common_list_header.dart';
import '../../../core/presentation/widgets/common_results_header.dart';
import '../domain/race.dart';
import '../domain/race_repository.dart';
import 'race_detail_view.dart';
import 'widgets/race_card.dart';
import 'widgets/race_filter_dialog.dart';

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

  String? _selectedType;
  String? _selectedDifficulty;
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

  void _applyFiltersAndSort() {
    setState(() {
      _filteredRaces = _allRaces.where((race) {
        if (_selectedType != null && race.type != _selectedType) return false;
        if (_selectedDifficulty != null && race.difficulty != _selectedDifficulty) {
          return false;
        }
        return true;
      }).toList();

      _filteredRaces.sort((a, b) => _sortAscending
          ? a.startDate.compareTo(b.startDate)
          : b.startDate.compareTo(a.startDate));
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => RaceFilterDialog(
        selectedType: _selectedType,
        selectedDifficulty: _selectedDifficulty,
        onApply: (type, difficulty) {
          setState(() {
            _selectedType = type;
            _selectedDifficulty = difficulty;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedDifficulty = null;
      _applyFiltersAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _selectedType != null || _selectedDifficulty != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CommonListHeader(
          title: widget.raidName != null
              ? 'Courses - ${widget.raidName}'
              : 'Courses d\'Orientation',
          hasFilters: hasActiveFilters,
          sortAscending: _sortAscending,
          onSortToggle: () {
            setState(() {
              _sortAscending = !_sortAscending;
              _applyFiltersAndSort();
            });
          },
          onFilterTap: _showFilterDialog,
        ),
      ),
      body: FutureBuilder<List<Race>>(
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
              _applyFiltersAndSort();
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
              CommonResultsHeader(
                count: _filteredRaces.length,
                itemName: 'course',
                sortLabel: 'Par date',
                sortAscending: _sortAscending,
                onSortToggle: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _applyFiltersAndSort();
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
                                label: const Text('Réinitialiser les filtres'),
                              )
                            : null,
                      )
                    : ListView.builder(
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
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Créer une nouvelle course')),
          );
        },
        backgroundColor: const Color(0xFFFF6B00),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle course'),
      ),
    );
  }
}
