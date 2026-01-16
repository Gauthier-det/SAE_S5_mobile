// lib/features/teams/presentation/widgets/member_info_row.dart
import 'package:flutter/material.dart';

/// Reusable info row displaying member data with conditional states [web:215][web:228][web:231].
///
/// Shows icon, label, value with visual feedback for completion status.
/// Displays either edit button (if editable) or status icon (complete/incomplete)
/// using conditional trailing widget pattern [web:228][web:231].
///
/// **Visual States:**
/// - Complete (green): Green icon, black text, checkmark
/// - Incomplete (grey): Grey icon, grey text, warning icon
/// - Editable: Green edit button replaces status icon
///
/// Example:
/// ```dart
/// // Non-editable field
/// MemberInfoRow(
///   icon: Icons.credit_card,
///   label: 'N° Licence',
///   value: '12345',
///   isComplete: true,
/// );
/// 
/// // Editable field for race managers
/// MemberInfoRow(
///   icon: Icons.sensors,
///   label: 'N° de puce',
///   value: chipNumber?.toString() ?? 'Non attribué',
///   isComplete: chipNumber != null,
///   isEditable: isRaceManager,
///   onEdit: () => _showChipDialog(userId),
/// );
/// ```
class MemberInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isComplete;
  final bool isEditable;
  final VoidCallback? onEdit;

  const MemberInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isComplete,
    this.isEditable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Leading icon with completion color [web:215]
        Icon(
          icon,
          size: 20,
          color: isComplete ? const Color(0xFF52B788) : Colors.grey.shade400,
        ),
        const SizedBox(width: 12),
        
        // Label and value column [web:215][web:225]
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isComplete ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        
        // Conditional trailing: edit button OR status icon [web:228][web:231]
        if (isEditable && onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
            color: const Color(0xFF52B788),
            tooltip: 'Modifier',
          )
        else
          Icon(
            isComplete ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isComplete ? Colors.green : Colors.orange,
          ),
      ],
    );
  }
}
