import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../raid/domain/raid.dart';
import '../domain/raid_repository.dart';

import '../../user/domain/user.dart';
import '../../club/domain/club_repository.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../address/domain/address.dart';
import '../../address/domain/address_repository.dart';

/// Raid creation form screen.
///
/// Comprehensive form for creating raids with validation for dates, contact info,
/// and location. Loads club members (manager options) and addresses via [Provider].
/// Allows inline address creation via dialog [web:138][web:140][web:150].
///
/// **Date Validation Rules:**
/// - End date > Start date
/// - Registration end > Registration start
/// - Registration start < Event start
/// - Registration end ≤ Event start
///
/// **Required Fields:**
/// - Name, manager, location, all dates, race count
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => RaidCreateView(repository: raidRepo),
///   ),
/// );
/// ```
class RaidCreateView extends StatefulWidget {
  final RaidRepository repository;

  const RaidCreateView({super.key, required this.repository});

  @override
  State<RaidCreateView> createState() => _RaidCreateViewState();
}

class _RaidCreateViewState extends State<RaidCreateView> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form fields [web:150]
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _raceCountController = TextEditingController();
  Address? _selectedAddress;
  List<Address> _addresses = [];

  // Date state
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationStart;
  DateTime? _registrationEnd;

  bool _isLoading = false;

  // Club data
  int? _clubId;
  User? _selectedRaidManager;
  List<User> _clubMembers = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClubData();
    });
  }

  /// Loads club members and addresses via Provider [web:138].
  Future<void> _loadClubData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final clubRepository = Provider.of<ClubRepository>(
        context,
        listen: false,
      );
      final addressRepository = Provider.of<AddressRepository>(
        context,
        listen: false,
      );

      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final userId = int.tryParse(currentUser.id);
      if (userId == null) {
        throw Exception('ID utilisateur invalide');
      }

      // Find user's club (bypassing 403 on /users/{id})
      final allClubs = await clubRepository.getAllClubs();

      final userClub = allClubs.firstWhere(
        (c) => c.responsibleId == userId,
        orElse: () => throw Exception(
          'Vous devez être responsable de club pour créer un raid',
        ),
      );

      final clubId = userClub.id;

      // Load members and addresses in parallel
      final results = await Future.wait([
        clubRepository.getClubMembers(clubId),
        addressRepository.getAllAddresses(),
      ]);

      final members = results[0] as List<User>;
      final addresses = results[1] as List<Address>;

      if (mounted) {
        setState(() {
          _clubId = clubId;
          _clubMembers = members;
          _addresses = addresses;
          _selectedRaidManager = members.firstWhere(
            (m) => m.id == userId,
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un Raid')),
      body: _isLoading || _isLoadingMembers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Raid name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du raid *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Raid manager dropdown
                    DropdownButtonFormField<User>(
                      initialValue: _selectedRaidManager,
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

                    // Address dropdown with inline creation
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Address>(
                            initialValue: _selectedAddress,
                            decoration: const InputDecoration(
                              labelText: 'Lieu du raid *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            items: _addresses.map((Address address) {
                              return DropdownMenuItem<Address>(
                                value: address,
                                child: Text(
                                  address.fullAddress,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (Address? newValue) {
                              setState(() {
                                _selectedAddress = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner un lieu';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _showAddAddressDialog(),
                          icon: const Icon(Icons.add),
                          tooltip: 'Ajouter une adresse',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Email with validation
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email de contact',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Email invalide';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone with validation
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length != 10) {
                            return 'Numéro invalide';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Website
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Site web',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 24),

                    // Event dates section
                    Text(
                      'Dates de l\'événement',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 8),

                    _buildDateField(
                      label: 'Date de début *',
                      date: _startDate,
                      onTap: () =>
                          _selectDate(context, isStart: true, isEvent: true),
                    ),

                    const SizedBox(height: 8),

                    _buildDateField(
                      label: 'Date de fin *',
                      date: _endDate,
                      onTap: () =>
                          _selectDate(context, isStart: false, isEvent: true),
                    ),

                    const SizedBox(height: 24),

                    // Registration period section
                    Text(
                      'Période d\'inscription',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 8),

                    _buildDateField(
                      label: 'Ouverture des inscriptions *',
                      date: _registrationStart,
                      onTap: () =>
                          _selectDate(context, isStart: true, isEvent: false),
                    ),

                    const SizedBox(height: 8),

                    _buildDateField(
                      label: 'Clôture des inscriptions *',
                      date: _registrationEnd,
                      onTap: () =>
                          _selectDate(context, isStart: false, isEvent: false),
                    ),

                    const SizedBox(height: 32),

                    // Race count
                    TextFormField(
                      controller: _raceCountController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre maximum de courses *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_list_numbered),
                        hintText: 'Ex: 5',
                        helperText: 'Nombre de courses autorisées dans ce raid',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ est obligatoire';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return 'Doit être un nombre >= 1';
                        }
                        return null;
                      },
                    ),

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

  /// Builds clickable date field with calendar icon.
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date == null ? 'Sélectionner une date' : _formatDate(date)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  /// Shows address creation dialog [web:140].
  Future<void> _showAddAddressDialog() async {
    final formKey = GlobalKey<FormState>();
    final streetNumberController = TextEditingController();
    final streetNameController = TextEditingController();
    final postalCodeController = TextEditingController();
    final cityController = TextEditingController();

    final result = await showDialog<Address>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle adresse'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: streetNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: streetNameController,
                  decoration: const InputDecoration(
                    labelText: 'Rue *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Code postal *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obligatoire';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Nombre invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ville *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obligatoire';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final addressRepository = Provider.of<AddressRepository>(
                  context,
                  listen: false,
                );

                final newAddress = Address(
                  postalCode: int.parse(postalCodeController.text),
                  city: cityController.text,
                  streetName: streetNameController.text,
                  streetNumber: streetNumberController.text,
                );

                final id = await addressRepository.createAddress(newAddress);

                Navigator.pop(
                  context,
                  Address(
                    id: id,
                    postalCode: newAddress.postalCode,
                    city: newAddress.city,
                    streetName: newAddress.streetName,
                    streetNumber: newAddress.streetNumber,
                  ),
                );
              }
            },
            child: const Text('CRÉER'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _addresses.add(result);
        _selectedAddress = result;
      });
    }
  }

  /// Shows date and time pickers sequentially.
  Future<void> _selectDate(
    BuildContext context, {
    required bool isStart,
    required bool isEvent,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (mounted) {
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

  /// Formats date as "13 janvier 2026 à 14h30".
  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  /// Validates and submits form with comprehensive date checks.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null ||
        _endDate == null ||
        _registrationStart == null ||
        _registrationEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toutes les dates sont obligatoires')),
      );
      return;
    }

    // Date validation rules
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
        ),
      );
      return;
    }

    if (_registrationEnd!.isBefore(_registrationStart!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La clôture doit être après l\'ouverture des inscriptions',
          ),
        ),
      );
      return;
    }

    if (_registrationStart!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Les inscriptions doivent ouvrir avant le début de l\'événement',
          ),
        ),
      );
      return;
    }

    if (_registrationEnd!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Les inscriptions doivent se clôturer avant le début de l\'événement',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newRaid = Raid(
        id: DateTime.now().millisecondsSinceEpoch,
        clubId: _clubId!,
        addressId: _selectedAddress!.id!,
        userId: _selectedRaidManager!.id,
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phoneNumber:
            _phoneController.text.isEmpty ? null : _phoneController.text,
        website:
            _websiteController.text.isEmpty ? null : _websiteController.text,
        image: null,
        timeStart: _startDate!,
        timeEnd: _endDate!,
        registrationStart: _registrationStart!,
        registrationEnd: _registrationEnd!,
        nbRaces: int.parse(_raceCountController.text),
      );

      await widget.repository.createRaid(newRaid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Raid créé avec succès !')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
