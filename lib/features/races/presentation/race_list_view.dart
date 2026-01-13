import 'package:flutter/material.dart';
import '../domain/Race.dart';
import '../domain/RaceRepository.dart';
import 'widgets/race_card.dart';

/// Vue de la liste des courses avec filtres et tri
class RaceListView extends StatefulWidget {
  final RacesRepository repository;
  final int? raidId; // ID du raid pour filtrer les courses (optionnel)
  final String? raidName; // Nom du raid pour l'affichage (optionnel)

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
  String? _selectedDifficulty;

  // Tri
  bool _sortByDate = true;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  void _loadRaces() {
    // Si un raidId est fourni, charger les courses de ce raid uniquement
    _racesFuture = widget.raidId != null
        ? widget.repository.getRacesByRaidId(widget.raidId!)
        : widget.repository.getRaces();
  }

  void _applyFiltersAndSort() {
    setState(() {
      _filteredRaces = _allRaces.where((race) {
        if (_selectedType != null && race.type != _selectedType) {
          return false;
        }
        if (_selectedDifficulty != null &&
            race.difficulty != _selectedDifficulty) {
          return false;
        }
        return true;
      }).toList();

      // Tri
      if (_sortByDate) {
        _filteredRaces.sort(
          (a, b) => _sortAscending
              ? a.startDate.compareTo(b.startDate)
              : b.startDate.compareTo(a.startDate),
        );
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedDifficulty = null;
      _applyFiltersAndSort();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempType = _selectedType;
        String? tempDifficulty = _selectedDifficulty;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filtres'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtre par type
                    const Text(
                      'Type de course',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Tous'),
                          selected: tempType == null,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempType = null;
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Compétitif'),
                          selected: tempType == 'Compétitif',
                          onSelected: (selected) {
                            setDialogState(() {
                              tempType = selected ? 'Compétitif' : null;
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Rando/Loisirs'),
                          selected: tempType == 'Rando/Loisirs',
                          onSelected: (selected) {
                            setDialogState(() {
                              tempType = selected ? 'Rando/Loisirs' : null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Filtre par difficulté
                    const Text(
                      'Difficulté',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Toutes'),
                          selected: tempDifficulty == null,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempDifficulty = null;
                            });
                          },
                        ),
                        for (var difficulty in [
                          'Facile',
                          'Moyen',
                          'Difficile',
                          'Expert',
                          'Très Expert',
                        ])
                          FilterChip(
                            label: Text(difficulty),
                            selected: tempDifficulty == difficulty,
                            onSelected: (selected) {
                              setDialogState(() {
                                tempDifficulty = selected ? difficulty : null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = tempType;
                      _selectedDifficulty = tempDifficulty;
                      _applyFiltersAndSort();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Appliquer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _selectedType != null || _selectedDifficulty != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFDCF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3022),
        foregroundColor: Colors.white,
        title: Text(
          widget.raidName != null
              ? 'Courses - ${widget.raidName}'
              : 'Courses d\'Orientation',
        ),
        actions: [
          // Bouton tri
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            tooltip: 'Inverser le tri',
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
                _applyFiltersAndSort();
              });
            },
          ),
          // Bouton filtres
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtres',
                onPressed: _showFilterDialog,
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B00),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Race>>(
        future: _racesFuture,
        builder: (context, snapshot) {
          // État: Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // État: Erreur
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
                        _loadRaces();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // État: Pas de données
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune course disponible',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          // État: Données disponibles
          _allRaces = snapshot.data!;
          if (_filteredRaces.isEmpty ||
              _filteredRaces.length != _allRaces.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _applyFiltersAndSort();
            });
          }

          return Column(
            children: [
              // Barre de filtres actifs
              if (hasActiveFilters)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_selectedType != null)
                              Chip(
                                label: Text(_selectedType!),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _selectedType = null;
                                    _applyFiltersAndSort();
                                  });
                                },
                              ),
                            if (_selectedDifficulty != null)
                              Chip(
                                label: Text(_selectedDifficulty!),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _selectedDifficulty = null;
                                    _applyFiltersAndSort();
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('Tout effacer'),
                      ),
                    ],
                  ),
                ),
              // Info résultats
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredRaces.length} course(s) trouvée(s)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _sortByDate = !_sortByDate;
                          _applyFiltersAndSort();
                        });
                      },
                      icon: const Icon(Icons.sort),
                      label: Text(_sortByDate ? 'Par date' : 'Par défaut'),
                    ),
                  ],
                ),
              ),
              // Liste des courses
              Expanded(
                child: _filteredRaces.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune course trouvée',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Essayez de modifier vos filtres',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 24),
                            if (hasActiveFilters)
                              ElevatedButton.icon(
                                onPressed: _resetFilters,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réinitialiser les filtres'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredRaces.length,
                        itemBuilder: (context, index) {
                          final race = _filteredRaces[index];
                          return RaceCard(
                            race: race,
                            onTap: () {
                              // TODO: Navigation vers les détails de la course
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Détails de la course #${race.id}',
                                  ),
                                  duration: const Duration(seconds: 2),
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
          // TODO: Navigation vers la création de course
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Créer une nouvelle course'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: const Color(0xFFFF6B00),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle course'),
      ),
    );
  }
}
