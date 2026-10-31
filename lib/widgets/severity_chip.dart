import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Chip reutilizable que colorea la severidad de un reporte.
class SeverityChip extends StatelessWidget {
  final String severity;

  const SeverityChip({super.key, required this.severity});

  bool get _isCritical => severity.startsWith('Crítica');

  @override
  Widget build(BuildContext context) {
    final background = _isCritical ? AppColors.danger : AppColors.warning;
    final foreground = _isCritical ? Colors.white : const Color(0xFF1F1300);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            severity,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
