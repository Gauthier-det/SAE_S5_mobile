import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../club/domain/club.dart';
import '../../club/data/datasources/club_api_sources.dart';
import '../../club/data/datasources/club_local_sources.dart';
import '../../../core/config/app_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _licenceNumberController = TextEditingController();
  final _ppsNumberController = TextEditingController();
  final _chipNumberController = TextEditingController();
  
  // Address controllers
  final _streetNumberController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  
  DateTime? _birthDate;
  bool _isLoading = false;
  
  // Clubs
  List<Club> _clubs = [];
  Club? _selectedClub;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    try {
      // Essayer de charger depuis l'API
      final clubApi = ClubApiSources(baseUrl: AppConfig.apiBaseUrl);
      final clubs = await clubApi.getAllClubs();
      _setClubs(clubs);
    } catch (e) {
      print('API non disponible pour les clubs, chargement local: $e');
      try {
        // Fallback sur les données locales
        final clubLocal = ClubLocalSources();
        final clubs = await clubLocal.getAllClubs();
        _setClubs(clubs);
      } catch (localError) {
        print('Erreur chargement clubs local: $localError');
      }
    }
  }

  void _setClubs(List<Club> clubs) {
    setState(() {
      _clubs = clubs;
      // Trouver le club de l'utilisateur s'il existe
      final user = context.read<AuthProvider>().currentUser;
      if (user?.club != null && user!.club!.isNotEmpty) {
        _selectedClub = _clubs.cast<Club?>().firstWhere(
          (c) => c?.name == user.club,
          orElse: () => null,
        );
      }
    });
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneNumberController.text = user.phoneNumber ?? '';
      _licenceNumberController.text = user.licenceNumber ?? '';
      _ppsNumberController.text = user.ppsNumber ?? '';
      _chipNumberController.text = user.chipNumber ?? '';
      
      // Address
      _streetNumberController.text = user.streetNumber ?? '';
      _streetNameController.text = user.streetName ?? '';
      _postalCodeController.text = user.postalCode ?? '';
      _cityController.text = user.city ?? '';
      
      if (user.birthDate != null && user.birthDate!.isNotEmpty) {
        try {
          _birthDate = DateTime.parse(user.birthDate!);
        } catch (e) {
          _birthDate = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _licenceNumberController.dispose();
    _ppsNumberController.dispose();
    _chipNumberController.dispose();
    _streetNumberController.dispose();
    _streetNameController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthProvider>().updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty 
            ? null 
            : _phoneNumberController.text.trim(),
        birthDate: _birthDate?.toIso8601String(),
        club: _selectedClub?.name,
        clubId: _selectedClub?.id,
        licenceNumber: _licenceNumberController.text.trim().isEmpty 
            ? null 
            : _licenceNumberController.text.trim(),
        ppsNumber: _ppsNumberController.text.trim().isEmpty 
            ? null 
            : _ppsNumberController.text.trim(),
        chipNumber: _chipNumberController.text.trim().isEmpty 
            ? null 
            : _chipNumberController.text.trim(),
        streetNumber: _streetNumberController.text.trim().isEmpty 
            ? null 
            : _streetNumberController.text.trim(),
        streetName: _streetNameController.text.trim().isEmpty 
            ? null 
            : _streetNameController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty 
            ? null 
            : _postalCodeController.text.trim(),
        city: _cityController.text.trim().isEmpty 
            ? null 
            : _cityController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier le profil')),
        body: const Center(child: Text('Aucun utilisateur connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveProfile,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email (non modifiable)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                  trailing: const Icon(Icons.lock, size: 16),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Section Informations personnelles
              _buildSectionTitle('Informations personnelles'),
              const SizedBox(height: 8),
              
              // Nom
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Prénom
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Téléphone
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '06 12 34 56 78',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date de naissance
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate != null
                            ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _birthDate != null 
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context).hintColor,
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Section Informations sportives
              _buildSectionTitle('Informations sportives'),
              const SizedBox(height: 8),
              
              
              // Numéro de licence
              TextFormField(
                controller: _licenceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de licence',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Numéro de puce
              TextFormField(
                controller: _chipNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de puce',
                  prefixIcon: Icon(Icons.memory),
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Section Adresse
              _buildSectionTitle('Adresse'),
              const SizedBox(height: 8),
              
              // Numéro et rue sur la même ligne
              Row(
                children: [
                  // Numéro
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _streetNumberController,
                      decoration: const InputDecoration(
                        labelText: 'N°',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Rue
                  Expanded(
                    child: TextFormField(
                      controller: _streetNameController,
                      decoration: const InputDecoration(
                        labelText: 'Rue',
                        prefixIcon: Icon(Icons.signpost),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Code postal et ville sur la même ligne
              Row(
                children: [
                  // Code postal
                  SizedBox(
                    width: 130,
                    child: TextFormField(
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Code postal',
                        prefixIcon: Icon(Icons.local_post_office),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ville
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Bouton Enregistrer
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Enregistrement...' : 'ENREGISTRER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B3D2F),
      ),
    );
  }
}
