// lib/features/teams/presentation/team_detail_view.dart
import 'package:flutter/material.dart';
import '../domain/team.dart';
import '../domain/team_repository.dart';
import '../../user/domain/user.dart';
import 'widgets/team_header.dart';
import 'widgets/team_validation_button.dart';
import 'widgets/team_members_list.dart';
import 'widgets/add_member_dialog.dart';

/// Team detail screen with granular role-based permissions [web:273][web:274][web:275].
///
/// Manages team viewing, member management, and race validation with three
/// permission levels: team creator, race manager, and member [web:274][web:277].
///
/// **Permission Model [web:273][web:274]:**
/// - Team Creator: Add/remove members, edit own info
/// - Race Manager: Validate/invalidate team, delete team, edit all members, add/remove members
/// - Member: View details, edit own PPS/chip only
///
/// **Business Rules:**
/// - Team can be validated only if all members have licence OR PPS
/// - PPS not required/editable if member has licence number
/// - Only race manager can validate/invalidate/delete team
/// - Validation requires confirmation dialog
///
/// **Key Actions:**
/// - Toggle validation (race manager only)
/// - Add/remove members (creator or manager)
/// - Edit PPS form (no licence required, self or manager)
/// - Edit chip number (self or manager)
/// - Delete team (race manager only)
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => TeamDetailView(
///       repository: teamRepository,
///       teamId: 123,
///       raceId: 456,
///       isRaceManager: true,
///       currentUserId: currentUser.id,
///     ),
///   ),
/// );
/// ```
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

  /// Checks if current user is team creator [web:274][web:277].
  bool _isTeamCreator() {
    return _team?.managerId == widget.currentUserId;
  }

  /// Checks if user can manage team (creator OR race manager) [web:274].
  bool _canManageTeam() {
    return _isTeamCreator() || widget.isRaceManager;
  }

  /// Checks if user can edit specific member's details [web:274][web:277].
  ///
  /// Race manager and team creator can edit anyone.
  /// Regular members can edit only themselves.
  bool _canEditMember(int memberId) {
    if (widget.isRaceManager || _isTeamCreator()) {
      return true;
    }
    return memberId == widget.currentUserId;
  }

  /// Validates team readiness: all members need licence OR PPS.
  bool _canValidateTeam() {
    for (var member in _membersWithDetails) {
      final hasLicence =
          member['USE_LICENCE_NUMBER'] != null &&
          (member['USE_LICENCE_NUMBER']) != null;
      final hasPPS =
          member['USR_PPS_FORM'] != null &&
          (member['USR_PPS_FORM'] as String).isNotEmpty;

      if (!hasLicence && !hasPPS) {
        return false;
      }
    }
    return true;
  }

  /// Loads team with validation status, dossard, and member details.
  Future<void> _loadTeamDetails() async {
    setState(() => _isLoading = true);

    try {
      final team = await widget.repository.getTeamByIdWithRaceStatus(
        widget.teamId,
        widget.raceId,
      );

      final dossardNumber = await widget.repository.getTeamDossardNumber(
        widget.teamId,
        widget.raceId,
      );

      final membersWithDetails = await widget.repository
          .getTeamMembersWithRaceDetails(widget.teamId, widget.raceId);

      if (mounted) {
        setState(() {
          _team = team;
          _dossardNumber = dossardNumber;
          _membersWithDetails = membersWithDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Erreur : $e');
      }
    }
  }

  /// Toggles team validation (race manager only) [web:274].
  Future<void> _toggleTeamValidation() async {
    if (!widget.isRaceManager) {
      _showSnackBar('Seul le responsable de la course peut valider l\'équipe');
      return;
    }

    final isCurrentlyValid = _team?.isValid ?? false;
    final action = isCurrentlyValid ? 'invalider' : 'valider';

    // Check validation requirements before validating
    if (!isCurrentlyValid && !_canValidateTeam()) {
      _showValidationErrorDialog();
      return;
    }

    final confirm = await _showConfirmDialog(
      title: '${action[0].toUpperCase()}${action.substring(1)} l\'équipe',
      content:
          'Confirmez-vous que vous souhaitez $action cette équipe pour la course ?',
      actionLabel: action.toUpperCase(),
      isDestructive: isCurrentlyValid,
    );

    if (confirm != true) return;

    setState(() => _isValidating = true);

    try {
      if (isCurrentlyValid) {
        await widget.repository.invalidateTeamForRace(
          widget.teamId,
          widget.raceId,
        );
      } else {
        await widget.repository.validateTeamForRace(
          widget.teamId,
          widget.raceId,
        );
      }

      if (mounted) {
        _showSnackBar(
          'Équipe ${isCurrentlyValid ? "invalidée" : "validée"} avec succès !',
          isSuccess: true,
        );
        await _loadTeamDetails();
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

  /// Shows dialog to add member (creator or manager only) [web:274].
  Future<void> _addMember() async {
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
        await widget.repository.addTeamMember(
          _team!.id,
          selectedUser.id,
          raceId: widget.raceId,
        );
        await widget.repository.registerUserToRace(
          selectedUser.id,
          widget.raceId,
        );

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

  /// Removes member from team (creator or manager only) [web:274].
  Future<void> _removeMember(int userId, String memberName) async {
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
      await widget.repository.removeMemberFromTeam(
        widget.teamId,
        userId,
        raceId: widget.raceId,
      );

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

  /// Deletes team (race manager only) [web:274].
  Future<void> _deleteTeam() async {
    if (!widget.isRaceManager) {
      _showSnackBar(
        'Seul le responsable de la course peut supprimer l\'équipe',
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      title: 'Supprimer l\'équipe',
      content:
          'Êtes-vous sûr de vouloir supprimer cette équipe ? Cette action est irréversible.',
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

  /// Edits member's PPS form (no licence required, self or manager) [web:274].
  Future<void> _editPPSForm(
    int userId,
    String currentPPS,
    String memberName,
  ) async {
    if (!_canEditMember(userId)) {
      _showSnackBar('Vous ne pouvez modifier que vos propres informations');
      return;
    }

    final member = _membersWithDetails.firstWhere((m) => m['USE_ID'] == userId);
    final hasLicence =
        member['USE_LICENCE_NUMBER'] != null &&
        (member['USE_LICENCE_NUMBER'] as String).isNotEmpty;

    if (hasLicence) {
      _showSnackBar('Ce membre a déjà un numéro de licence');
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

    if (result == null || result == currentPPS) return;

    try {
      await widget.repository.updateUserPPS(
        userId,
        result.isEmpty ? null : result,
        widget.raceId,
        widget.teamId,
      );

      if (mounted) {
        _showSnackBar('Formulaire PPS mis à jour !', isSuccess: true);
        await _loadTeamDetails();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur : $e');
      }
    }
  }

  /// Edits member's chip number (self or manager) [web:274].
  Future<void> _editChipNumber(
    int userId,
    int? currentChip,
    String memberName,
  ) async {
    if (!_canEditMember(userId)) {
      _showSnackBar('Vous ne pouvez modifier que vos propres informations');
      return;
    }

    final controller = TextEditingController(
      text: currentChip?.toString() ?? '',
    );

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
      await widget.repository.updateUserChipNumber(
        userId,
        widget.raceId,
        chipNumber,
        widget.teamId,
      );

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

  /// Shows error dialog when validation requirements not met.
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

  /// Generic confirmation dialog for destructive actions.
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
              backgroundColor: isDestructive
                  ? Colors.red
                  : const Color(0xFF52B788),
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
                      TeamHeader(team: _team!, dossardNumber: _dossardNumber),

                      // Validation button (race manager only) [web:274]
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
                        currentUserId: widget.currentUserId,
                        canEditMember: _canEditMember,
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
