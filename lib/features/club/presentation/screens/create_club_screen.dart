import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/club_provider.dart';
import '../../domain/club.dart';
import '../../../user/domain/user.dart';
import '../../../user/domain/user_repository.dart';
import '../../../address/data/datasources/address_local_sources.dart';
import '../../../address/domain/address.dart';

/// Screen for creating or editing a club
class CreateClubScreen extends StatefulWidget {
  final Club? club;

  const CreateClubScreen({super.key, this.club});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingData = true;

  List<User> _availableUsers = [];
  List<Address> _availableAddresses = [];
  User? _selectedResponsible;
  Address? _selectedAddress;

  bool get _isEditing => widget.club != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.club!.name;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Use UserRepository to fetch users from API
      final userRepository = context.read<UserRepository>();
      final addressSources = AddressLocalSources();

      final users = await userRepository.getAllUsers();
      final addresses = await addressSources.getAllAddresses();

      if (mounted) {
        setState(() {
          _availableUsers = users;
          _availableAddresses = addresses;
          _isLoadingData = false;

          // En mode édition, sélectionner le responsable actuel
          if (_isEditing && widget.club!.responsibleId != null) {
            try {
              _selectedResponsible = users.firstWhere(
                (u) => u.id == widget.club!.responsibleId,
              );
            } catch (_) {}
          }
          if (_isEditing && widget.club!.addressId != null) {
            try {
              _selectedAddress = addresses.firstWhere(
                (a) => a.id == widget.club!.addressId,
              );
            } catch (_) {}
          }
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
    super.dispose();
  }

  Future<void> _saveClub() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedResponsible == null || _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un responsable et une adresse'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final clubProvider = context.read<ClubProvider>();

      if (_isEditing) {
        await clubProvider.updateClub(
          id: widget.club!.id,
          name: _nameController.text.trim(),
        );
      } else {
        await clubProvider.createClub(
          name: _nameController.text.trim(),
          responsibleId: _selectedResponsible!.id,
          addressId: _selectedAddress!.id!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Club modifié avec succès' : 'Club créé avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le club' : 'Créer un club'),
        backgroundColor: const Color(0xFF1B3D2F),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon header
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3D2F).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups,
                          size: 50,
                          color: Color(0xFF1B3D2F),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Club name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du club *',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                        hintText: 'Ex: Club Orientation Paris',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Le nom du club est requis';
                        }
                        if (value!.length < 3) {
                          return 'Le nom doit contenir au moins 3 caractères';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Responsible autocomplete field
                    Autocomplete<User>(
                      displayStringForOption: (user) => user.fullName,
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _availableUsers;
                        }
                        return _availableUsers.where((user) {
                          return user.fullName.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                        });
                      },
                      initialValue: _selectedResponsible != null
                          ? TextEditingValue(
                              text: _selectedResponsible!.fullName,
                            )
                          : null,
                      onSelected: (user) {
                        setState(() => _selectedResponsible = user);
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              enabled: !_isEditing,
                              decoration: InputDecoration(
                                labelText: 'Responsable du club *',
                                prefixIcon: const Icon(Icons.person),
                                border: const OutlineInputBorder(),
                                hintText: 'Tapez pour rechercher...',
                                suffixIcon: _selectedResponsible != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          controller.clear();
                                          setState(
                                            () => _selectedResponsible = null,
                                          );
                                        },
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                if (_selectedResponsible == null) {
                                  return 'Veuillez sélectionner un responsable';
                                }
                                return null;
                              },
                            );
                          },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final user = options.elementAt(index);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF1B3D2F),
                                      child: Text(
                                        user.initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text(user.fullName),
                                    subtitle: Text(
                                      user.email,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onTap: () => onSelected(user),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Address autocomplete field
                    Autocomplete<Address>(
                      displayStringForOption: (address) => address.fullAddress,
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _availableAddresses;
                        }
                        return _availableAddresses.where((address) {
                          return address.fullAddress.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                        });
                      },
                      initialValue: _selectedAddress != null
                          ? TextEditingValue(
                              text: _selectedAddress!.fullAddress,
                            )
                          : null,
                      onSelected: (address) {
                        setState(() => _selectedAddress = address);
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Adresse du club *',
                                prefixIcon: const Icon(Icons.location_on),
                                border: const OutlineInputBorder(),
                                hintText: 'Tapez pour rechercher...',
                                suffixIcon: _selectedAddress != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          controller.clear();
                                          setState(
                                            () => _selectedAddress = null,
                                          );
                                        },
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                if (_selectedAddress == null) {
                                  return 'Veuillez sélectionner une adresse';
                                }
                                return null;
                              },
                            );
                          },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final address = options.elementAt(index);
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFF1B3D2F),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(address.city),
                                    subtitle: Text(
                                      '${address.streetNumber} ${address.streetName}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onTap: () => onSelected(address),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Save button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveClub,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(_isEditing ? Icons.save : Icons.add),
                        label: Text(
                          _isLoading
                              ? 'Enregistrement...'
                              : (_isEditing ? 'ENREGISTRER' : 'CRÉER LE CLUB'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
