// lib/features/race/presentation/race_creation_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae5_g13_mobile/features/race/domain/category.dart';
import 'package:sae5_g13_mobile/features/race/domain/race.dart';
import 'package:sae5_g13_mobile/features/race/presentation/widgets/race_form_age_section.dart';
import 'package:sae5_g13_mobile/features/raid/presentation/widgets/raid_info_banner.dart';
import 'package:sae5_g13_mobile/features/raid/domain/raid.dart';
import '../../../core/database/database_helper.dart';
import '../domain/race_repository.dart';
import '../../user/domain/user.dart';
import '../../club/domain/club_repository.dart';
import 'widgets/category_price_selector.dart';
import 'widgets/race_form_date_field.dart';
import 'widgets/race_form_participants_section.dart';

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

  Future<void> _loadData() async {
    try {
      final clubRepository = Provider.of<ClubRepository>(
        context,
        listen: false,
      );

      // Use clubId from the raid passed as widget parameter
      // instead of querying local DB which may be empty
      final clubId = widget.raid.clubId;
      print(
        '🏁 RaceCreationView._loadData - Using clubId: $clubId from raid: ${widget.raid.name}',
      );

      final results = await Future.wait([
        clubRepository.getClubMembers(clubId),
        widget.repository.getCategories(),
      ]);

      print(
        '🏁 RaceCreationView._loadData - Got ${(results[0] as List).length} club members',
      );

      if (mounted) {
        setState(() {
          _clubMembers = results[0] as List<User>;
          _categories = results[1] as List<Category>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('❌ RaceCreationView._loadData - Error: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
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

                    // Nom de la course
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

                    // Gestionnaire (only show members with licence)
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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

                    // Type et Difficulté
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
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value;
                                // Si Compétitif, forcer la puce obligatoire
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

                    // Puce obligatoire - Switch pour Rando/Loisirs
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
                            const Icon(Icons.sd_card, color: Color(0xFFFF6B00)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Puce électronique obligatoire ?',
                                style: Theme.of(context).textTheme.bodyMedium
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

                    // Indicateur pour Compétitif
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.blue.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Sexe
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSex,
                      decoration: const InputDecoration(
                        labelText: 'Sexe *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      items: _sexes
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSex = value),
                      validator: (value) =>
                          value == null ? 'Obligatoire' : null,
                    ),
                    const SizedBox(height: 24),

                    // Participants et équipes
                    RaceFormParticipantsSection(
                      minParticipantsController: _minParticipantsController,
                      maxParticipantsController: _maxParticipantsController,
                      minTeamsController: _minTeamsController,
                      maxTeamsController: _maxTeamsController,
                      minTeamMembersController: _minTeamMembersController,
                      maxTeamMembersController: _maxTeamMembersController,
                    ),
                    const SizedBox(height: 24),

                    // Âges (optionnels)
                    RaceFormAgesSection(
                      ageMinController: _ageMinController,
                      ageMiddleController: _ageMiddleController,
                      ageMaxController: _ageMaxController,
                    ),
                    const SizedBox(height: 24),

                    // Prix par catégorie
                    CategoryPriceSelector(
                      categories: _categories,
                      initialPrices: _categoryPrices,
                      onChanged: (prices) =>
                          setState(() => _categoryPrices = prices),
                    ),
                    const SizedBox(height: 32),

                    // Bouton créer
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

  Future<void> _submitForm() async {
    // Validation du formulaire
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Veuillez remplir tous les champs obligatoires');
      return;
    }

    // Validation des dates
    if (_startDate == null || _endDate == null) {
      _showSnackBar('Les dates sont obligatoires');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showSnackBar('La date de fin doit être après le début');
      return;
    }

    // Validation du gestionnaire
    if (_selectedManager == null) {
      _showSnackBar('Veuillez sélectionner un gestionnaire');
      return;
    }

    // Validation du type
    if (_selectedType == null) {
      _showSnackBar('Veuillez sélectionner un type de course');
      return;
    }

    // Validation des prix
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
      // Calculer chipMandatory : toujours 1 si Compétitif, sinon selon le switch
      final chipMandatory = _selectedType == 'Compétitif'
          ? 1
          : (_chipMandatory ? 1 : 0);

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

    // Tous les prix doivent être définis
    if (prixMineur == null || prixLicencie == null || prixNonLicencie == null) {
      return false;
    }

    // Prix licencié <= Prix mineur
    if (prixLicencie > prixMineur) {
      return false;
    }

    // Prix non licencié >= Prix mineur
    if (prixNonLicencie < prixMineur) {
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
