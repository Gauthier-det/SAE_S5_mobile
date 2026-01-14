// lib/features/races/presentation/race_create_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae5_g13_mobile/features/races/domain/category.dart';
import 'package:sae5_g13_mobile/features/races/presentation/widgets/race_form_age_section.dart';
import 'package:sae5_g13_mobile/features/raids/presentation/widgets/raid_info_banner.dart';
import '../../../core/database/database_helper.dart';
import '../domain/race.dart';
import '../domain/race_repository.dart';
import '../../raids/domain/raid.dart';
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
  
  final _minParticipantsController = TextEditingController(text: '1');
  final _maxParticipantsController = TextEditingController(text: '200');
  final _minTeamsController = TextEditingController(text: '1');
  final _maxTeamsController = TextEditingController(text: '200');
  final _teamMembersController = TextEditingController();
  final _ageMinController = TextEditingController();
  final _ageMiddleController = TextEditingController();
  final _ageMaxController = TextEditingController();

  User? _selectedManager;
  String? _selectedType;
  String? _selectedDifficulty;
  DateTime? _startDate;
  DateTime? _endDate;
  
  List<User> _clubMembers = [];
  List<Category> _categories = [];
  Map<int, double> _categoryPrices = {};
  
  bool _isLoading = false;
  bool _isLoadingData = true;

  static const _difficulties = ['Facile', 'Moyen', 'Difficile'];
  static const _types = ['Compétitif', 'Rando/Loisirs'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final clubRepository = Provider.of<ClubRepository>(context, listen: false);
      final db = await DatabaseHelper.database;
      
      final raidData = await db.query(
        'SAN_RAIDS',
        where: 'RAI_ID = ?',
        whereArgs: [widget.raid.id],
        limit: 1,
      );
      
      if (raidData.isEmpty) throw Exception('Raid introuvable');
      
      final clubId = raidData.first['CLU_ID'] as int;
      
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _minParticipantsController.dispose();
    _maxParticipantsController.dispose();
    _minTeamsController.dispose();
    _maxTeamsController.dispose();
    _teamMembersController.dispose();
    _ageMinController.dispose();
    _ageMiddleController.dispose();
    _ageMaxController.dispose();
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

                    // Gestionnaire
                    DropdownButtonFormField<User>(
                      value: _selectedManager,
                      decoration: const InputDecoration(
                        labelText: 'Gestionnaire *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _clubMembers
                          .map((m) => DropdownMenuItem(value: m, child: Text(m.fullName)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedManager = value),
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

                    // Type et difficulté
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Type *',
                              border: OutlineInputBorder(),
                            ),
                            items: _types
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedType = value),
                            validator: (value) => value == null ? 'Obligatoire' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: 'Difficulté *',
                              border: OutlineInputBorder(),
                            ),
                            items: _difficulties
                                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedDifficulty = value),
                            validator: (value) => value == null ? 'Obligatoire' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Participants et équipes
                    RaceFormParticipantsSection(
                      minParticipantsController: _minParticipantsController,
                      maxParticipantsController: _maxParticipantsController,
                      minTeamsController: _minTeamsController,
                      maxTeamsController: _maxTeamsController,
                      teamMembersController: _teamMembersController,
                    ),
                    const SizedBox(height: 24),

                    // Âges
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
                      onChanged: (prices) => setState(() => _categoryPrices = prices),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      firstDate: isStart ? widget.raid.timeStart : (_startDate ?? widget.raid.timeStart),
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
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      _showSnackBar('Les dates sont obligatoires');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showSnackBar('La date de fin doit être après le début');
      return;
    }

    if (_categoryPrices.isEmpty) {
      _showSnackBar('Veuillez définir au moins un prix');
      return;
    }

    // ✅ NOUVELLE VALIDATION : Vérifier les contraintes de prix
    if (!_validateCategoryPrices()) {
      _showSnackBar('Veuillez corriger les prix des catégories');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ... reste du code
    } catch (e) {
      if (mounted) _showSnackBar('Erreur : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Ajoute cette méthode dans _RaceCreateViewState :
  bool _validateCategoryPrices() {
    // Trouver les catégories
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
