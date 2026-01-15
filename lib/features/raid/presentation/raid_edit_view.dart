// lib/features/raid/presentation/raid_edit_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../raid/domain/raid.dart';
import '../domain/raid_repository.dart';
import '../../address/domain/address.dart';
import '../../address/domain/address_repository.dart';

/// Screen for editing an existing raid
class RaidEditView extends StatefulWidget {
  final Raid raid;
  final RaidRepository repository;

  const RaidEditView({super.key, required this.raid, required this.repository});

  @override
  State<RaidEditView> createState() => _RaidEditViewState();
}

class _RaidEditViewState extends State<RaidEditView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _raceCountController;

  Address? _selectedAddress;
  List<Address> _addresses = [];

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationStart;
  DateTime? _registrationEnd;

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing raid data
    _nameController = TextEditingController(text: widget.raid.name);
    _emailController = TextEditingController(text: widget.raid.email ?? '');
    _phoneController = TextEditingController(
      text: widget.raid.phoneNumber ?? '',
    );
    _websiteController = TextEditingController(text: widget.raid.website ?? '');
    _raceCountController = TextEditingController(
      text: widget.raid.nbRaces.toString(),
    );

    // Initialize dates
    _startDate = widget.raid.timeStart;
    _endDate = widget.raid.timeEnd;
    _registrationStart = widget.raid.registrationStart;
    _registrationEnd = widget.raid.registrationEnd;

    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final addressRepository = Provider.of<AddressRepository>(
        context,
        listen: false,
      );
      final addresses = await addressRepository.getAllAddresses();

      if (mounted) {
        setState(() {
          _addresses = addresses;
          // Find the current address
          try {
            _selectedAddress = addresses.firstWhere(
              (a) => a.id == widget.raid.addressId,
            );
          } catch (_) {
            if (addresses.isNotEmpty) {
              _selectedAddress = addresses.first;
            }
          }
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _raceCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le Raid'),
        backgroundColor: const Color(0xFF1B3D2F),
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
                    // Raid name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du raid *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Address dropdown
                    DropdownButtonFormField<Address>(
                      value: _selectedAddress,
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
                        setState(() => _selectedAddress = newValue);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un lieu';
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
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
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
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    // Website field
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Site web',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.web),
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

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _raceCountController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre maximum de courses *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_list_numbered),
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

                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text('ENREGISTRER LES MODIFICATIONS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

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
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date == null ? 'Sélectionner' : _formatDate(date)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStart,
    required bool isEvent,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isEvent
          ? (isStart ? _startDate : _endDate) ?? DateTime.now()
          : (isStart ? _registrationStart : _registrationEnd) ?? DateTime.now(),
      firstDate: DateTime(2020),
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

    setState(() => _isLoading = true);

    try {
      final updatedRaid = Raid(
        id: widget.raid.id,
        clubId: widget.raid.clubId,
        addressId: _selectedAddress!.id!,
        userId: widget.raid.userId,
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phoneNumber: _phoneController.text.isEmpty
            ? null
            : _phoneController.text,
        website: _websiteController.text.isEmpty
            ? null
            : _websiteController.text,
        image: widget.raid.image,
        timeStart: _startDate!,
        timeEnd: _endDate!,
        registrationStart: _registrationStart!,
        registrationEnd: _registrationEnd!,
        nbRaces: int.parse(_raceCountController.text),
      );

      await widget.repository.updateRaid(widget.raid.id, updatedRaid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Raid modifié avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
