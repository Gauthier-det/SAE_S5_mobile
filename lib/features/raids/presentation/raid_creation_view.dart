// lib/features/raids/presentation/raid_create_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/raid.dart';
import '../domain/raid_repository.dart';
import '../../user/domain/user_repository.dart';
import '../../user/domain/user.dart';
import '../../club/domain/club_repository.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// Page for creating a new raid
/// Uses a StatefulWidget because we need to manage form state
class RaidCreateView extends StatefulWidget {
  final RaidRepository repository;

  const RaidCreateView({super.key, required this.repository});

  @override
  State<RaidCreateView> createState() => _RaidCreateViewState();
}

class _RaidCreateViewState extends State<RaidCreateView> {
  // GlobalKey: unique identifier for the form
  // Allows validating and saving form data
  final _formKey = GlobalKey<FormState>();
  
  // TextEditingController: manages the content of a text field
  // One controller per field to retrieve values
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  
  // Variables to store selected dates
  // DateTime? means "can be null" (not yet selected)
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationStart;
  DateTime? _registrationEnd;
  
  // Variable to display loading during save
  bool _isLoading = false;
  
  // NEW: Club and raid manager selection
  int? _clubId;
  User? _selectedRaidManager;
  List<User> _clubMembers = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    // Appeler après que le widget soit monté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClubData();
    });
  }

  /// Load club ID and members
  Future<void> _loadClubData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userRepository = Provider.of<UserRepository>(context, listen: false);
      final clubRepository = Provider.of<ClubRepository>(context, listen: false);
      
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      // Get user's club ID
      final clubId = await userRepository.getUserClubId(currentUser.id as int);
      
      if (clubId == null) {
        throw Exception('Vous devez être responsable de club pour créer un raid');
      }
      
      // Get club members
      final members = await clubRepository.getClubMembers(clubId);
      
      if (mounted) {
        setState(() {
          _clubId = clubId;
          _clubMembers = members;
          // Auto-select current user as raid manager
          _selectedRaidManager = members.firstWhere(
            (m) => m.id == currentUser.id,
            orElse: () => members.first,
          );
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  /// Method called when the widget is destroyed
  /// IMPORTANT: free memory from controllers
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Raid'),
      ),
      body: _isLoading || _isLoadingMembers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey, // Bind the form to the key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Raid name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du raid *',
                        border: OutlineInputBorder(),
                      ),
                      // Validation: function that returns null if OK, or an error message
                      validator: (value) {
                        // value == null || value.isEmpty
                        // means "if empty or null"
                        if (value == null || value.isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null; // null = validation OK
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // NEW: Raid manager dropdown
                    DropdownButtonFormField<User>(
                      value: _selectedRaidManager,
                      decoration: const InputDecoration(
                        labelText: 'Responsable du raid *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _clubMembers.map((User member) {
                        return DropdownMenuItem<User>(
                          value: member,
                          child: Text(member.fullName),
                        );
                      }).toList(),
                      onChanged: (User? newValue) {
                        setState(() {
                          _selectedRaidManager = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un responsable';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email de contact',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      // Email validation with regex (pattern)
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // RegExp = regular expression to validate email format
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Email invalide';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if(value != null && value.isNotEmpty){
                          if(value.length != 10){
                            return 'Numéro invalide';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Website field
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Site web',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Dates section
                    Text(
                      'Dates de l\'événement',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Button to select start date
                    _buildDateField(
                      label: 'Date de début *',
                      date: _startDate,
                      onTap: () => _selectDate(context, isStart: true, isEvent: true),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildDateField(
                      label: 'Date de fin *',
                      date: _endDate,
                      onTap: () => _selectDate(context, isStart: false, isEvent: true),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Période d\'inscription',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildDateField(
                      label: 'Ouverture des inscriptions *',
                      date: _registrationStart,
                      onTap: () => _selectDate(context, isStart: true, isEvent: false),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildDateField(
                      label: 'Clôture des inscriptions *',
                      date: _registrationEnd,
                      onTap: () => _selectDate(context, isStart: false, isEvent: false),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('CRÉER LE RAID'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Reusable widget to display a clickable date field
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap, // Function called on click
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // If date is null, display "Select", otherwise display the date
            Text(
              date == null 
                  ? 'Sélectionner une date' 
                  : _formatDate(date),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  /// Displays the native date picker followed by time picker
  /// async = asynchronous function that can "await" a response
  Future<void> _selectDate(
    BuildContext context, {
    required bool isStart,
    required bool isEvent,
  }) async {
    // Step 1: Pick the date
    // showDatePicker = Flutter function that displays a calendar
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // No past dates
      lastDate: DateTime(2030),
    );
    
    // If user cancelled date selection, stop here
    if (pickedDate == null) return;
    
    // Step 2: Pick the time
    // showTimePicker = Flutter function that displays a time picker
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    // If user cancelled time selection, stop here
    if (pickedTime == null) return;
    
    // Step 3: Combine date and time into a single DateTime
    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    
    // If the user selected both date and time
    if (mounted) {
      // setState: informs Flutter that data has changed
      // Flutter will rebuild the widget to display the new date
      setState(() {
        if (isEvent) {
          if (isStart) {
            _startDate = finalDateTime;
          } else {
            _endDate = finalDateTime;
          }
        } else {
          if (isStart) {
            _registrationStart = finalDateTime;
          } else {
            _registrationEnd = finalDateTime;
          }
        }
      });
    }
  }

  /// Formats a DateTime to French readable format with time
  /// Example: "13 janvier 2026 à 14h30"
  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    // Format: day month year at HH:mm
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  /// Validates and submits the form
  Future<void> _submitForm() async {
    // 1. Validate all TextFormField fields
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }
    
    // 2. Check that dates are filled in
    if (_startDate == null || _endDate == null || 
        _registrationStart == null || _registrationEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toutes les dates sont obligatoires')),
      );
      return;
    }
    
    // 3. Check event dates consistency
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de fin doit être après la date de début')),
      );
      return;
    }
    
    // 4. Check registration dates consistency
    if (_registrationEnd!.isBefore(_registrationStart!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La clôture doit être après l\'ouverture des inscriptions')),
      );
      return;
    }
    
    // 5. Check that registration start is before event start
    if (_registrationStart!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les inscriptions doivent ouvrir avant le début de l\'événement')),
      );
      return;
    }
    
    // 6. Check that registration end is before or at event start
    if (_registrationEnd!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les inscriptions doivent se clôturer avant le début de l\'événement')),
      );
      return;
    }
    
    // 7. Display loading
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 8. Create Raid object with form data
      final newRaid = Raid(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        clubId: _clubId!, // Use connected user's club
        addressId: 1, // TODO: add address selection
        userId: _selectedRaidManager!.id, // Use selected raid manager
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
        image: null, // TODO: add image upload
        timeStart: _startDate!,
        timeEnd: _endDate!,
        registrationStart: _registrationStart!,
        registrationEnd: _registrationEnd!,
      );
      
      // 9. Save via repository
      await widget.repository.createRaid(newRaid);
      
      // 10. Success: return to previous screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Raid créé avec succès !')),
        );
        Navigator.pop(context, true); // true = success signal
      }
      
    } catch (e) {
      // 11. Error: display a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      // 12. Hide loading in all cases
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
