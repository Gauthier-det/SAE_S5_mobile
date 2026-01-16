// lib/features/raid/presentation/raid_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/presentation/widgets/common_loading_view.dart';
import '../../../core/presentation/widgets/common_error_view.dart';
import '../../../core/presentation/widgets/common_empty_view.dart';
import '../../../core/presentation/widgets/common_list_header.dart';
import '../../../core/presentation/widgets/common_results_header.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../club/presentation/providers/club_provider.dart';

import '../../raid/domain/raid.dart';
import '../domain/raid_repository.dart';
import 'raid_detail_view.dart';
import 'raid_creation_view.dart';
import 'widgets/raid_card.dart';
import 'widgets/raid_filter_dialog.dart';

class RaidListView extends StatefulWidget {
  final RaidRepository repository;

  const RaidListView({super.key, required this.repository});

  @override
  State<RaidListView> createState() => _RaidListViewState();
}

class _RaidListViewState extends State<RaidListView> {
  late Future<List<Raid>> _raidsFuture;
  List<Raid> _allRaids = [];
  List<Raid> _filteredRaids = [];

  // Filtres
  String? _selectedStatus;
  String? _selectedRegistrationStatus;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  final _searchController =
      TextEditingController(); // ← NOUVEAU: Recherche par nom

  // Tri
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _raidsFuture = widget.repository.getAllRaids();
    _searchController.addListener(_applyFiltersAndSort); // ← NOUVEAU
  }

  @override
  void dispose() {
    _searchController.dispose(); // ← NOUVEAU
    super.dispose();
  }

  void _applyFiltersAndSort() {
    setState(() {
      _filteredRaids = _allRaids.where((raid) {
        // ← NOUVEAU: Filtre par nom
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          if (!raid.name.toLowerCase().contains(searchLower)) {
            return false;
          }
        }

        if (_selectedStatus != null &&
            !_matchesStatus(raid, _selectedStatus!)) {
          return false;
        }
        if (_selectedRegistrationStatus != null &&
            !_matchesRegistrationStatus(raid, _selectedRegistrationStatus!)) {
          return false;
        }

        // Filtres par date
        if (_filterStartDate != null &&
            raid.timeEnd.isBefore(_filterStartDate!)) {
          return false;
        }
        if (_filterEndDate != null && raid.timeStart.isAfter(_filterEndDate!)) {
          return false;
        }

        return true;
      }).toList();

      // Tri intelligent
      _filteredRaids.sort((a, b) {
        final now = DateTime.now();
        final aIsUpcoming = now.isBefore(a.timeStart);
        final bIsUpcoming = now.isBefore(b.timeStart);
        final aIsFinished = now.isAfter(a.timeEnd);
        final bIsFinished = now.isAfter(b.timeEnd);

        if (aIsUpcoming && !bIsUpcoming) return -1;
        if (!aIsUpcoming && bIsUpcoming) return 1;
        if (!aIsFinished && bIsFinished) return -1;
        if (aIsFinished && !bIsFinished) return 1;

        if (aIsUpcoming && bIsUpcoming) {
          return _sortAscending
              ? a.timeStart.compareTo(b.timeStart)
              : b.timeStart.compareTo(a.timeStart);
        } else {
          return _sortAscending
              ? b.timeEnd.compareTo(a.timeEnd)
              : a.timeEnd.compareTo(b.timeEnd);
        }
      });
    });
  }

  bool _matchesStatus(Raid raid, String status) {
    final now = DateTime.now();
    switch (status) {
      case 'upcoming':
        return now.isBefore(raid.timeStart);
      case 'ongoing':
        return now.isAfter(raid.timeStart) && now.isBefore(raid.timeEnd);
      case 'finished':
        return now.isAfter(raid.timeEnd);
      default:
        return true;
    }
  }

  bool _matchesRegistrationStatus(Raid raid, String status) {
    final now = DateTime.now();
    switch (status) {
      case 'upcoming':
        return now.isBefore(raid.registrationStart);
      case 'open':
        return now.isAfter(raid.registrationStart) &&
            now.isBefore(raid.registrationEnd);
      case 'closed':
        return now.isAfter(raid.registrationEnd);
      default:
        return true;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => RaidFilterDialog(
        selectedStatus: _selectedStatus,
        selectedRegistrationStatus: _selectedRegistrationStatus,
        onApply: (status, registrationStatus) {
          setState(() {
            _selectedStatus = status;
            _selectedRegistrationStatus = registrationStatus;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _filterStartDate = picked;
        _applyFiltersAndSort();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterEndDate ?? DateTime.now(),
      firstDate: _filterStartDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _filterEndDate = picked;
        _applyFiltersAndSort();
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedRegistrationStatus = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _searchController.clear(); // ← NOUVEAU
      _applyFiltersAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _selectedStatus != null ||
        _selectedRegistrationStatus != null ||
        _filterStartDate != null ||
        _filterEndDate != null ||
        _searchController.text.isNotEmpty; // ← NOUVEAU

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CommonListHeader(
          title: 'Raids Disponibles',
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
      body: FutureBuilder<List<Raid>>(
        future: _raidsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CommonLoadingView(message: 'Chargement des raids...');
          }

          if (snapshot.hasError) {
            return CommonErrorView(
              error: '${snapshot.error}',
              onRetry: () {
                setState(() {
                  _raidsFuture = widget.repository.getAllRaids();
                });
              },
            );
          }

          _allRaids = snapshot.data ?? [];
          if (_filteredRaids.isEmpty ||
              _filteredRaids.length != _allRaids.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _applyFiltersAndSort();
            });
          }

          if (_allRaids.isEmpty) {
            return const CommonEmptyView(
              icon: Icons.hiking,
              title: 'Aucun raid disponible',
              subtitle: 'Revenez plus tard pour découvrir de nouvelles courses',
            );
          }

          return Column(
            children: [
              // ← NOUVEAU: Barre de recherche par nom
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un raid par nom...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),

              // Filtres par date
              if (_filterStartDate != null || _filterEndDate != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _filterStartDate != null && _filterEndDate != null
                              ? 'Du ${_filterStartDate!.day}/${_filterStartDate!.month}/${_filterStartDate!.year} au ${_filterEndDate!.day}/${_filterEndDate!.month}/${_filterEndDate!.year}'
                              : _filterStartDate != null
                              ? 'À partir du ${_filterStartDate!.day}/${_filterStartDate!.month}/${_filterStartDate!.year}'
                              : 'Jusqu\'au ${_filterEndDate!.day}/${_filterEndDate!.month}/${_filterEndDate!.year}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        color: Colors.blue,
                        onPressed: () {
                          setState(() {
                            _filterStartDate = null;
                            _filterEndDate = null;
                            _applyFiltersAndSort();
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // Boutons de sélection de dates
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectStartDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _filterStartDate != null
                              ? '${_filterStartDate!.day}/${_filterStartDate!.month}/${_filterStartDate!.year}'
                              : 'Date début',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: _filterStartDate != null
                              ? const Color(0xFFFF6B00)
                              : Colors.grey,
                          side: BorderSide(
                            color: _filterStartDate != null
                                ? const Color(0xFFFF6B00)
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectEndDate,
                        icon: const Icon(Icons.event, size: 18),
                        label: Text(
                          _filterEndDate != null
                              ? '${_filterEndDate!.day}/${_filterEndDate!.month}/${_filterEndDate!.year}'
                              : 'Date fin',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: _filterEndDate != null
                              ? const Color(0xFFFF6B00)
                              : Colors.grey,
                          side: BorderSide(
                            color: _filterEndDate != null
                                ? const Color(0xFFFF6B00)
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              CommonResultsHeader(
                count: _filteredRaids.length,
                itemName: 'raid',
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
                child: _filteredRaids.isEmpty
                    ? CommonEmptyView(
                        icon: Icons.search_off,
                        title: 'Aucun raid trouvé',
                        subtitle: 'Essayez de modifier vos filtres',
                        action: hasActiveFilters
                            ? ElevatedButton.icon(
                                onPressed: _resetFilters,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réinitialiser les filtres'),
                              )
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _raidsFuture = widget.repository.getAllRaids();
                          });
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredRaids.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: RaidCard(
                                raid: _filteredRaids[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RaidDetailView(
                                        raidId: _filteredRaids[index].id,
                                        repository: widget.repository,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _canCreateRaid(),
        builder: (context, snapshot) {
          if (snapshot.data != true) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RaidCreateView(repository: widget.repository),
                ),
              );
              if (result == true && mounted) {
                setState(() {
                  _raidsFuture = widget.repository.getAllRaids();
                });
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('CRÉER UN RAID'),
          );
        },
      ),
    );
  }

  Future<bool> _canCreateRaid() async {
    try {
      if (!mounted) return false;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) return false;

      final userId = int.tryParse(currentUser.id);
      if (userId == null) return false;

      // Check if user is responsible for any club using ClubProvider (public data)
      // This avoids the 403 Forbidden error on /users/{id}
      final clubProvider = Provider.of<ClubProvider>(context, listen: false);

      // Ensure data is loaded
      if (clubProvider.clubs.isEmpty && !clubProvider.isLoading) {
        await clubProvider.loadClubs();
      }

      final isResponsible = clubProvider.clubs.any(
        (c) => c.responsibleId == userId,
      );

      if (isResponsible) {}

      return isResponsible;
    } catch (e) {
      return false;
    }
  }
}
