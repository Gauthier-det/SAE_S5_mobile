// lib/features/teams/presentation/widgets/team_validation_button.dart
import 'package:flutter/material.dart';

/// Full-width toggle button for team validation with loading state [web:252][web:254][web:255].
///
/// Toggles between validate/invalidate states with visual feedback. Disables
/// during async operations and shows loading spinner [web:252][web:256][web:257].
///
/// **States:**
/// - Valid (orange): Shows "INVALIDER L'ÉQUIPE" with cancel icon
/// - Invalid (green): Shows "VALIDER L'ÉQUIPE" with check icon
/// - Loading: Disabled with spinner and "Traitement..." text
///
/// **Button behavior:**
/// - onPressed = null when isValidating (auto-disables button) [web:255][web:257]
/// - Color changes based on current validation state
/// - Icon switches between check_circle and cancel
///
/// Example:
/// ```dart
/// // In parent widget state
/// bool _isValidating = false;
/// 
/// TeamValidationButton(
///   isValid: team.isValid ?? false,
///   isValidating: _isValidating,
///   onPressed: () async {
///     setState(() => _isValidating = true);
///     try {
///       if (team.isValid) {
///         await repository.invalidateTeamForRace(teamId, raceId);
///       } else {
///         await repository.validateTeamForRace(teamId, raceId);
///       }
///     } finally {
///       setState(() => _isValidating = false);
///     }
///   },
/// );
/// ```
class TeamValidationButton extends StatelessWidget {
  final bool isValid;
  final bool isValidating;
  final VoidCallback onPressed;

  const TeamValidationButton({
    super.key,
    required this.isValid,
    required this.isValidating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isValidating ? null : onPressed, // Disable when loading [web:255][web:257]
          style: ElevatedButton.styleFrom(
            backgroundColor: isValid ? Colors.orange : const Color(0xFF52B788),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: isValidating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(isValid ? Icons.cancel : Icons.check_circle),
          label: Text(
            isValidating
                ? 'Traitement...'
                : isValid
                    ? 'INVALIDER L\'ÉQUIPE'
                    : 'VALIDER L\'ÉQUIPE',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
