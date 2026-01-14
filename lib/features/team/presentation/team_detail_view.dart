// lib/features/teams/presentation/team_detail_view.dart
import 'package:flutter/material.dart';
import '../domain/team.dart';
import '../domain/team_repository.dart';
import '../../user/domain/user.dart';
import 'widgets/team_header.dart';
import 'widgets/team_validation_button.dart';
import 'widgets/team_members_list.dart';
import 'widgets/add_member_dialog.dart';

class TeamDetailView extends StatefulWidget {
  final TeamRepository repository;
  final int teamId;
  final int raceId;
  final bool isRaceManager;
  final int currentUserId;

  const TeamDetailView({
    super.key,
    required this.repository,
    required this.teamId,
    required this.raceId,
    required this.isRaceManager,
    required this.currentUserId,
  });

  @override
  State<TeamDetailView> createState() => _TeamDetailViewState();
}

class _TeamDetailViewState extends State<TeamDetailView> {
  Team? _team;
  List<Map<String, dynamic>> _membersWithDetails = [];
  int? _dossardNumber;
  bool _isLoading = true;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _loadTeamDetails();
  }

  // ✅ Vérifie si l'utilisateur est le créateur de l'équipe
  bool _isTeamCreator() {
    return _team?.managerId == widget.currentUserId;
  }

  // ✅ Vérifie si l'utilisateur peut gérer l'équipe (créateur OU responsable course)
  bool _canManageTeam() {
    return _isTeamCreator() || widget.isRaceManager;
  }

  // ✅ Vérifie si l'utilisateur peut modifier un membre spécifique
  bool _canEditMember(int memberId) {
    // Responsable de course ou créateur d'équipe → peut modifier tout le monde
    if (widget.isRaceManager || _isTeamCreator()) {
      return true;
    }
    // Sinon, peut modifier seulement soi-même
    return memberId == widget.currentUserId;
  }

  // ✅ Vérifie si l'équipe peut être validée (tous les membres ont licence OU PPS)
  bool _canValidateTeam() {
    for (var member in _membersWithDetails) {
      final hasLicence = member['USE_LICENCE_NUMBER'] != null &&
          (member['USE_LICENCE_NUMBER']) != null ;
      final hasPPS = member['USR_PPS_FORM'] != null && 
                     (member['USR_PPS_FORM'] as String).isNotEmpty;
      
      if (!hasLicence && !hasPPS) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadTeamDetails() async {
    setState(() => _isLoading = true);

    try {
      // ✅ Utilise la nouvelle méthode qui récupère le statut de validation
      final team = await widget.repository.getTeamByIdWithRaceStatus(
        widget.teamId,
        widget.raceId,
      );
      
      final dossardNumber = await widget.repository.getTeamDossardNumber(
        widget.teamId,
        widget.raceId,
      );
      
      final membersWithDetails = await widget.repository.getTeamMembersWithRaceDetails(
        widget.teamId,
        widget.raceId,
      );

      print('🔍 Team loaded: ${team?.name}, isValid: ${team?.isValid}');
      print('📊 Dossard: $dossardNumber');
      print('👥 Members: ${membersWithDetails.length}');

      if (mounted) {
        setState(() {
          _team = team;
          _dossardNumber = dossardNumber;
          _membersWithDetails = membersWithDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading team: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Erreur : $e');
      }
    }
  }


  Future<void> _toggleTeamValidation() async {
    // ✅ Seul le responsable de course peut valider/invalider
    if (!widget.isRaceManager) {
      _showSnackBar('Seul le responsable de la course peut valider l\'équipe');
      return;
    }

    print('Toggling team validation for team ${widget.teamId}');

    final isCurrentlyValid = _team?.isValid ?? false;
    final action = isCurrentlyValid ? 'invalider' : 'valider';

    print('Toggling team validation. Currently valid: $isCurrentlyValid');

    
    if (!isCurrentlyValid && !_canValidateTeam()) {
      _showValidationErrorDialog();
      return;
    }

    print('User confirmed to $action the team');

    final confirm = await _showConfirmDialog(
      title: '${action[0].toUpperCase()}${action.substring(1)} l\'équipe',
      content: 'Confirmez-vous que vous souhaitez $action cette équipe pour la course ?',
      actionLabel: action.toUpperCase(),
      isDestructive: isCurrentlyValid,
    );

    if (confirm != true) return;

    setState(() => _isValidating = true);

    try {
      if (isCurrentlyValid) {
        await widget.repository.invalidateTeamForRace(widget.teamId, widget.raceId);
      } else {
        await widget.repository.validateTeamForRace(widget.teamId, widget.raceId);
      }

      if (mounted) {
        _showSnackBar(
          'Équipe ${isCurrentlyValid ? "invalidée" : "validée"} avec succès !',
          isSuccess: true,
        );
        await _loadTeamDetails();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur : $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  Future<void> _addMember() async {
    // ✅ Seuls le créateur et le responsable peuvent ajouter des membres
    if (!_canManageTeam()) {
      _showSnackBar('Vous n\'avez pas la permission d\'ajouter des membres');
      return;
    }

    final availableUsers = await widget.repository.getAvailableUsersForRace(
      widget.raceId,
    );

    if (availableUsers.isEmpty) {
      _showSnackBar('Aucun utilisateur disponible pour cette course');
      return;
    }

    if (!mounted) return;

    final selectedUser = await showDialog<User>(
      context: context,
      builder: (context) => AddMemberDialog(availableUsers: availableUsers),
    );

    if (selectedUser != null) {
      try {
        await widget.repository.addTeamMember(_team!.id, selectedUser.id);
        await widget.repository.registerUserToRace(selectedUser.id, widget.raceId);

        if (mounted) {
          _showSnackBar(
            '${selectedUser.fullName} a été ajouté à l\'équipe !',
            isSuccess: true,
          );
          await _loadTeamDetails();
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Erreur : $e');
        }
      }
    }
  }

  Future<void> _removeMember(int userId, String memberName) async {
    // ✅ Seuls le créateur et le responsable peuvent retirer des membres
    if (!_canManageTeam()) {
      _showSnackBar('Vous n\'avez pas la permission de retirer des membres');
      return;
    }

    final confirm = await _showConfirmDialog(
      title: 'Retirer le membre',
      content: 'Êtes-vous sûr de vouloir retirer $memberName de l\'équipe ?',
      actionLabel: 'RETIRER',
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      await widget.repository.removeMemberFromTeam(widget.teamId, userId);

      if (mounted) {
        _showSnackBar('Membre retiré avec succès !');
        await _loadTeamDetails();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur : $e');
      }
    }
  }

  Future<void> _deleteTeam() async {
    // ✅ Seul le responsable de course peut supprimer l'équipe
    if (!widget.isRaceManager) {
      _showSnackBar('Seul le responsable de la course peut supprimer l\'équipe');
      return;
    }

    final confirm = await _showConfirmDialog(
      title: 'Supprimer l\'équipe',
      content: 'Êtes-vous sûr de vouloir supprimer cette équipe ? Cette action est irréversible.',
      actionLabel: 'SUPPRIMER',
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      await widget.repository.deleteTeam(widget.teamId, widget.raceId);

      if (mounted) {
        _showSnackBar('Équipe supprimée avec succès !', isSuccess: false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur : $e');
      }
    }
  }

  Future<void> _editPPSForm(int userId, String currentPPS, String memberName) async {
    if (!_canEditMember(userId)) {
      _showSnackBar('Vous ne pouvez modifier que vos propres informations');
      print('User $userId cannot edit member');
      return;
    }

    final member = _membersWithDetails.firstWhere((m) => m['USE_ID'] == userId);
    final hasLicence = member['USE_LICENCE_NUMBER'] != null &&
        (member['USE_LICENCE_NUMBER'] as String).isNotEmpty;

    if (hasLicence) {
      _showSnackBar('Ce membre a déjà un numéro de licence');
      print('Member $userId has a licence, cannot edit PPS');
      return;
    }

    final controller = TextEditingController(text: currentPPS);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Formulaire PPS - $memberName'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Formulaire PPS',
            hintText: 'URL ou référence du formulaire',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    print('PPS edit result for user $userId: $result');

    if (result == null || result == currentPPS) return;

    try {
      await widget.repository.updateUserPPS(userId, result.isEmpty ? null : result, widget.raceId);

      if (mounted) {
        _showSnackBar('Formulaire PPS mis à jour !', isSuccess: true);
        await _loadTeamDetails();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur : $e');
        print('Error updating PPS: $e');
      }
    }
  }

  Future<void> _editChipNumber(int userId, int? currentChip, String memberName) async {
    // ✅ Vérifier si l'utilisateur peut modifier ce membre
    if (!_canEditMember(userId)) {
      _showSnackBar('Vous ne pouvez modifier que vos propres informations');
      return;
    }

    final controller = TextEditingController(text: currentChip?.toString() ?? '');
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('N° de puce - $memberName'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Numéro de puce',
            hintText: 'Entrez le numéro',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == null) return;

    try {
      final chipNumber = result.isEmpty ? null : int.parse(result);
      await widget.repository.updateUserChipNumber(userId, widget.raceId, chipNumber);

      if (mounted) {
        _showSnackBar('Numéro de puce mis à jour !', isSuccess: true);
        await _loadTeamDetails();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur : $e');
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF52B788) : null,
      ),
    );
  }

  void _showValidationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation impossible'),
        content: const Text(
          'Tous les membres doivent avoir un numéro de licence OU un formulaire PPS renseigné avant de valider l\'équipe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String actionLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : const Color(0xFF52B788),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_team?.name ?? 'Équipe'),
        backgroundColor: const Color(0xFF1B3022),
        foregroundColor: Colors.white,
        actions: widget.isRaceManager
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteTeam,
                  tooltip: 'Supprimer l\'équipe',
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _team == null
              ? const Center(child: Text('Équipe introuvable'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeamHeader(
                        team: _team!,
                        dossardNumber: _dossardNumber,
                      ),
                      
                      // ✅ Bouton de validation visible UNIQUEMENT pour le responsable
                      if (widget.isRaceManager)
                        TeamValidationButton(
                          isValid: _team!.isValid ?? false,
                          isValidating: _isValidating,
                          onPressed: _toggleTeamValidation,
                        ),
                      
                      TeamMembersList(
                        members: _membersWithDetails,
                        canManageTeam: _canManageTeam(),
                        isRaceManager: widget.isRaceManager,
                        currentUserId: widget.currentUserId, // ✅ AJOUTE
                        canEditMember: _canEditMember, // ✅ AJOUTE
                        raceId: widget.raceId,
                        onAddMember: _addMember,
                        onRemoveMember: _removeMember,
                        onEditPPS: _editPPSForm,
                        onEditChipNumber: _editChipNumber,
                      ),
                    ],
                  ),
                ),
    );
  }
}
