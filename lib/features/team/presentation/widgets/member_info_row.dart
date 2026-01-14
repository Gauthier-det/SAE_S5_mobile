// lib/features/teams/presentation/widgets/member_info_row.dart
import 'package:flutter/material.dart';

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
        Icon(
          icon,
          size: 20,
          color: isComplete ? const Color(0xFF52B788) : Colors.grey.shade400,
        ),
        const SizedBox(width: 12),
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
