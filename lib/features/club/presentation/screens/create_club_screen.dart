import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/club_provider.dart';
import '../../domain/club.dart';

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
  final _responsibleController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.club != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.club!.name;
      _responsibleController.text = widget.club!.responsibleName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _responsibleController.dispose();
    super.dispose();
  }

  Future<void> _saveClub() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final clubProvider = context.read<ClubProvider>();

      if (_isEditing) {
        await clubProvider.updateClub(
          id: widget.club!.id,
          name: _nameController.text.trim(),
          responsibleName: _responsibleController.text.trim(),
        );
      } else {
        await clubProvider.createClub(
          name: _nameController.text.trim(),
          responsibleName: _responsibleController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Club modifié avec succès' : 'Club créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le club' : 'Créer un club'),
        backgroundColor: const Color(0xFF1B3D2F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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

              // Responsible name field
              TextFormField(
                controller: _responsibleController,
                decoration: const InputDecoration(
                  labelText: 'Responsable du club *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Jean Dupont',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Le nom du responsable est requis';
                  }
                  return null;
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
