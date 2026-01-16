import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// Profile editing form screen with Provider-based state management [web:315][web:321][web:280].
///
/// Two-section form (personal info + sports info) with date picker integration
/// and real-time state updates via AuthProvider. Validates required fields
/// and handles optimistic updates with error recovery [web:321][web:280].
///
/// **Form Sections:**
/// - Personal: First name*, last name*, phone, birth date
/// - Sports: Club, licence number, PPS number, chip number
/// - Email: Display-only (locked field)
///
/// **Features [web:320][web:321]:**
/// - DatePicker integration for birth date [web:320][web:323]
/// - Required field validation (first/last name)
/// - Loading state with disabled submit during save
/// - Success/error feedback via SnackBar
/// - Auto-navigation on successful save
///
/// **State Management [web:321][web:280]:**
/// - Uses Provider to access AuthProvider.currentUser
/// - context.read() for actions (load/save)
/// - context.watch() for reactive UI updates
/// - TextEditingController per field for form state
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => EditProfileScreen(),
///   ),
/// );
/// ```
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
  final _clubController = TextEditingController();
  final _licenceNumberController = TextEditingController();
  final _ppsNumberController = TextEditingController();
  final _chipNumberController = TextEditingController();

  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Populates form fields from AuthProvider.currentUser [web:321].
  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneNumberController.text = user.phoneNumber ?? '';
      _clubController.text = user.club ?? '';
      _licenceNumberController.text = user.licenceNumber ?? '';
      _ppsNumberController.text = user.ppsNumber ?? '';
      _chipNumberController.text = user.chipNumber ?? '';

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
    _clubController.dispose();
    _licenceNumberController.dispose();
    _ppsNumberController.dispose();
    _chipNumberController.dispose();
    super.dispose();
  }

  /// Shows DatePicker dialog for birth date selection [web:320][web:323].
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

  /// Validates and submits profile updates via AuthProvider [web:321][web:280].
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
            club: _clubController.text.trim().isEmpty
                ? null
                : _clubController.text.trim(),
            licenceNumber: _licenceNumberController.text.trim().isEmpty
                ? null
                : _licenceNumberController.text.trim(),
            ppsNumber: _ppsNumberController.text.trim().isEmpty
                ? null
                : _ppsNumberController.text.trim(),
            chipNumber: _chipNumberController.text.trim().isEmpty
                ? null
                : _chipNumberController.text.trim(),
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
              // Email (read-only, locked)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                  trailing: const Icon(Icons.lock, size: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Section: Personal information
              _buildSectionTitle('Informations personnelles'),
              const SizedBox(height: 8),

              // Last name (required)
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

              // First name (required)
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

              // Phone number (optional)
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

              // Birth date picker [web:320][web:323]
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

              // Section: Sports information
              _buildSectionTitle('Informations sportives'),
              const SizedBox(height: 8),

              // Club (optional)
              TextFormField(
                controller: _clubController,
                decoration: const InputDecoration(
                  labelText: 'Club',
                  prefixIcon: Icon(Icons.groups),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Licence number (optional)
              TextFormField(
                controller: _licenceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de licence',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              // Save button with loading state
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

  /// Builds section header with consistent styling.
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
