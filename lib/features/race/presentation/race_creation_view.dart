// lib/features/race/presentation/race_creation_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae5_g13_mobile/features/race/domain/category.dart';
import 'package:sae5_g13_mobile/features/race/domain/race.dart';
import 'package:sae5_g13_mobile/features/race/presentation/widgets/form/race_form_age_section.dart';
import 'package:sae5_g13_mobile/features/raid/presentation/widgets/raid_info_banner.dart';
import 'package:sae5_g13_mobile/features/raid/domain/raid.dart';
import '../domain/race_repository.dart';
import '../../user/domain/user.dart';
import '../../club/domain/club_repository.dart';
import 'widgets/category_price_selector.dart';
import 'widgets/form/race_form_date_field.dart';
import 'widgets/form/race_form_participants_section.dart';

/// Race creation form screen.
///
/// Comprehensive form for creating races within a raid. Fetches club members
/// and categories, validates inputs, and handles chip mandatory logic based on
/// race type (always mandatory for Compétitif) [web:138][web:150].
///
/// **Key Features:**
/// - Manager selection (requires licence number)
/// - Date/time pickers constrained to raid dates
/// - Type-based chip requirement (auto for Compétitif, optional for Rando)
/// - Category pricing with validation rules
/// - Team capacity configuration
///
/// **Validation Rules:**
/// - Licensed price ≤ Minor price
/// - Non-licensed price ≥ Minor price
/// - End date > Start date
/// - All prices must be defined
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => RaceCreationView(
///       raid: selectedRaid,
///       repository: raceRepo,
///     ),
///   ),
/// );
/// ```
class RaceCreationView extends StatefulWidget {
  final Raid raid;
  final RacesRepository repository;

  const RaceCreationView({
    super.key,
    required this.raid,
    required this.repository,
  });

  @override
  State<RaceCreationView> createState() => _RaceCreationViewState();
}

class _RaceCreationViewState extends State<RaceCreationView> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers [web:150]
  final _nameController = TextEditingController();
  final _minParticipantsController = TextEditingController(text: '1');
  final _maxParticipantsController = TextEditingController(text: '200');
  final _minTeamsController = TextEditingController(text: '1');
  final _maxTeamsController = TextEditingController(text: '200');
  final _minTeamMembersController = TextEditingController(text: '2');
  final _maxTeamMembersController = TextEditingController(text: '2');
  final _ageMinController = TextEditingController();
  final _ageMiddleController = TextEditingController();
  final _ageMaxController = TextEditingController();
  final _difficultyController = TextEditingController();

  // Form state
  User? _selectedManager;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedSex;
  bool _chipMandatory = false;

  static const _sexes = ['Homme', 'Femme', 'Mixte'];
  static const _types = ['Compétitif', 'Rando/Loisirs'];

  List<User> _clubMembers = [];
  List<Category> _categories = [];
  Map<int, int> _categoryPrices = {};

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads club members and categories via Provider [web:138].
  Future<void> _loadData() async {
    try {
      final clubRepository = Provider.of<ClubRepository>(
        context,
        listen: false,
      );

      final clubId = widget.raid.clubId;

      final results = await Future.wait([
        clubRepository.getClubMembers(clubId),
        widget.repository.getCategories(),
      ]);

      if (mounted) {
        setState(() {
          _clubMembers = results[0] as List<User>;
          _categories = results[1] as List<Category>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers [web:150]
    _nameController.dispose();
    _minParticipantsController.dispose();
    _maxParticipantsController.dispose();
    _minTeamsController.dispose();
    _maxTeamsController.dispose();
    _minTeamMembersController.dispose();
    _maxTeamMembersController.dispose();
    _ageMinController.dispose();
    _ageMiddleController.dispose();
    _ageMaxController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une course'),
        backgroundColor: const Color(0xFF1B3022),
        foregroundColor: Colors.white,
      ),
      body: _isLoading || _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RaidInfoBanner(raid: widget.raid),
                    const SizedBox(height: 24),

                    // Race name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la course *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Manager (only licensed members)
                    DropdownButtonFormField<User>(
                      initialValue: _selectedManager,
                      decoration: const InputDecoration(
                        labelText: 'Gestionnaire *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        helperText:
                            'Le gestionnaire doit avoir un numéro de licence',
                      ),
                      items: _clubMembers.map((m) {
                        final hasLicence = m.licenceNumber != null;
                        return DropdownMenuItem(
                          value: m,
                          enabled: hasLicence,
                          child: Text(
                            hasLicence
                                ? m.fullName
                                : '${m.fullName} (Pas de licence)',
                            style: TextStyle(
                              color: hasLicence ? null : Colors.grey,
                              fontStyle: hasLicence
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedManager = value),
                      validator: (value) => value == null
                          ? 'Veuillez sélectionner un gestionnaire'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Dates
                    Text(
                      'Dates de la course',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    RaceFormDateField(
                      label: 'Date de début *',
                      date: _startDate,
                      onTap: () => _selectDate(isStart: true),
                    ),
                    const SizedBox(height: 8),

                    RaceFormDateField(
                      label: 'Date de fin *',
                      date: _endDate,
                      onTap: () => _selectDate(isStart: false),
                    ),
                    const SizedBox(height: 24),

                    // Type and difficulty
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Type *',
                              border: OutlineInputBorder(),
                            ),
                            items: _types
                                .map((t) =>
                                    DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value;
                                // Force chip mandatory for Compétitif
                                if (value == 'Compétitif') {
                                  _chipMandatory = true;
                                }
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Obligatoire' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _difficultyController,
                            decoration: const InputDecoration(
                              labelText: 'Difficulté *',
                              border: OutlineInputBorder(),
                              hintText: 'Ex: Facile, Moyen...',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obligatoire';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chip mandatory switch (Rando only)
                    if (_selectedType == 'Rando/Loisirs')
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sd_card,
                                color: Color(0xFFFF6B00)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Puce électronique obligatoire ?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Switch(
                              value: _chipMandatory,
                              onChanged: (value) {
                                setState(() => _chipMandatory = value);
                              },
                              activeThumbColor: const Color(0xFFFF6B00),
                            ),
                          ],
                        ),
                      ),

                    // Info banner for Compétitif
                    if (_selectedType == 'Compétitif')
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Puce électronique obligatoire pour les courses compétitives',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.blue.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Gender
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSex,
                      decoration: const InputDecoration(
                        labelText: 'Sexe *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      items: _sexes
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedSex = value),
                      validator: (value) => value == null ? 'Obligatoire' : null,
                    ),
                    const SizedBox(height: 24),

                    // Participants and teams
                    RaceFormParticipantsSection(
                      minParticipantsController: _minParticipantsController,
                      maxParticipantsController: _maxParticipantsController,
                      minTeamsController: _minTeamsController,
                      maxTeamsController: _maxTeamsController,
                      minTeamMembersController: _minTeamMembersController,
                      maxTeamMembersController: _maxTeamMembersController,
                    ),
                    const SizedBox(height: 24),

                    // Ages
                    RaceFormAgesSection(
                      ageMinController: _ageMinController,
                      ageMiddleController: _ageMiddleController,
                      ageMaxController: _ageMaxController,
                    ),
                    const SizedBox(height: 24),

                    // Category pricing
                    CategoryPriceSelector(
                      categories: _categories,
                      initialPrices: _categoryPrices,
                      onChanged: (prices) =>
                          setState(() => _categoryPrices = prices),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'CRÉER LA COURSE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Shows date and time pickers constrained to raid dates.
  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart
        ? (widget.raid.timeStart.isAfter(DateTime.now())
            ? widget.raid.timeStart
            : DateTime.now())
        : (_startDate ?? widget.raid.timeStart);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStart
          ? widget.raid.timeStart
          : (_startDate ?? widget.raid.timeStart),
      lastDate: widget.raid.timeEnd,
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null || !mounted) return;

    final finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startDate = finalDateTime;
      } else {
        _endDate = finalDateTime;
      }
    });
  }

  /// Validates and submits race creation form.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Veuillez remplir tous les champs obligatoires');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showSnackBar('Les dates sont obligatoires');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showSnackBar('La date de fin doit être après le début');
      return;
    }

    if (_selectedManager == null) {
      _showSnackBar('Veuillez sélectionner un gestionnaire');
      return;
    }

    if (_selectedType == null) {
      _showSnackBar('Veuillez sélectionner un type de course');
      return;
    }

    if (_categoryPrices.isEmpty) {
      _showSnackBar('Veuillez définir au moins un prix');
      return;
    }

    if (!_validateCategoryPrices()) {
      _showSnackBar('Veuillez corriger les prix des catégories');
      return;
    }

    if (_selectedSex == null) {
      _showSnackBar('Veuillez sélectionner un sexe');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calculate chip mandatory: always 1 for Compétitif
      final chipMandatory =
          _selectedType == 'Compétitif' ? 1 : (_chipMandatory ? 1 : 0);

      final race = Race(
        id: 0,
        name: _nameController.text.trim(),
        userId: _selectedManager!.id,
        raidId: widget.raid.id,
        startDate: _startDate!,
        endDate: _endDate!,
        type: _selectedType!,
        difficulty: _difficultyController.text.trim(),
        sex: _selectedSex!,
        minParticipants: int.parse(_minParticipantsController.text),
        maxParticipants: int.parse(_maxParticipantsController.text),
        minTeams: int.parse(_minTeamsController.text),
        maxTeams: int.parse(_maxTeamsController.text),
        minTeamMembers: int.parse(_minTeamMembersController.text),
        teamMembers: int.parse(_maxTeamMembersController.text),
        ageMin: int.parse(_ageMinController.text),
        ageMiddle: int.parse(_ageMiddleController.text),
        ageMax: int.parse(_ageMaxController.text),
        chipMandatory: chipMandatory,
      );

      await widget.repository.createRace(race, _categoryPrices);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course créée avec succès !'),
            backgroundColor: Color(0xFF52B788),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors de la création : $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Validates category pricing business rules.
  bool _validateCategoryPrices() {
    final mineurCat = _categories.firstWhere(
      (c) => c.label == 'Mineur',
      orElse: () => _categories.first,
    );
    final licencieCat = _categories.firstWhere(
      (c) => c.label == 'Licencié',
      orElse: () => _categories.last,
    );
    final nonLicencieCat = _categories.firstWhere(
      (c) => c.label == 'Majeur non licencié',
      orElse: () => _categories[1],
    );

    final prixMineur = _categoryPrices[mineurCat.id];
    final prixLicencie = _categoryPrices[licencieCat.id];
    final prixNonLicencie = _categoryPrices[nonLicencieCat.id];

    // All prices must be defined
    if (prixMineur == null || prixLicencie == null || prixNonLicencie == null) {
      return false;
    }

    // Licensed ≤ Minor
    if (prixLicencie > prixMineur) {
      return false;
    }

    // Non-licensed ≥ Minor
    if (prixNonLicencie < prixMineur) {
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
