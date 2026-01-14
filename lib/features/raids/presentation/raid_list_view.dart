// lib/features/raids/presentation/raid_list_view.dart (VERSION SIMPLIFIÉE)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae5_g13_mobile/core/presentation/widgets/common_results_header.dart';
import '../../../core/presentation/widgets/common_loading_view.dart';
import '../../../core/presentation/widgets/common_error_view.dart';
import '../../../core/presentation/widgets/common_empty_view.dart';
import '../../../core/presentation/widgets/common_list_header.dart';
import '../../../core/database/database_helper.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../user/domain/user_repository.dart';
import '../domain/raid.dart';
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

  // Tri
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _raidsFuture = widget.repository.getAllRaids();
  }

  void _applyFiltersAndSort() {
    setState(() {
      _filteredRaids = _allRaids.where((raid) {
        if (_selectedStatus != null && !_matchesStatus(raid, _selectedStatus!)) {
          return false;
        }
        if (_selectedRegistrationStatus != null &&
            !_matchesRegistrationStatus(raid, _selectedRegistrationStatus!)) {
          return false;
        }
        return true;
      }).toList();

      _filteredRaids.sort((a, b) => _sortAscending
          ? a.timeStart.compareTo(b.timeStart)
          : b.timeStart.compareTo(a.timeStart));
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

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedRegistrationStatus = null;
      _applyFiltersAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _selectedStatus != null || _selectedRegistrationStatus != null;

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
          if (_filteredRaids.isEmpty || _filteredRaids.length != _allRaids.length) {
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
                  builder: (context) => RaidCreateView(repository: widget.repository),
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userRepository = Provider.of<UserRepository>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) return false;

      final db = await DatabaseHelper.database;
      final users = await db.query(
        'SAN_USERS',
        where: 'USE_MAIL = ?',
        whereArgs: [currentUser.email],
        limit: 1,
      );

      if (users.isEmpty) return false;

      final sqliteUserId = users.first['USE_ID'] as int;
      final clubId = await userRepository.getUserClubId(sqliteUserId);

      return clubId != null;
    } catch (e) {
      return false;
    }
  }
}
