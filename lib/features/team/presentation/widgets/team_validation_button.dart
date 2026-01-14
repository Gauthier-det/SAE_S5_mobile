// lib/features/teams/presentation/widgets/team_validation_button.dart
import 'package:flutter/material.dart';

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
          onPressed: isValidating ? null : onPressed,
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
