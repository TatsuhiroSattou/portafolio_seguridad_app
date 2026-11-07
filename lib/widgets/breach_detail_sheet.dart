import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/breach.dart';

/// Abre una hoja inferior con el detalle completo de una brecha.
void showBreachDetail(BuildContext context, Breach breach) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _BreachDetail(breach: breach),
  );
}

class _BreachDetail extends StatelessWidget {
  final Breach breach;

  const _BreachDetail({required this.breach});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                breach.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (breach.domain.isNotEmpty)
                Text(
                  breach.domain,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.event,
                label: 'Fecha de la brecha',
                value: Breach.formatDate(breach.breachDate),
              ),
              _InfoRow(
                icon: Icons.add_circle_outline,
                label: 'Agregada a la base de datos',
                value: Breach.formatDate(breach.addedDate),
              ),
              _InfoRow(
                icon: Icons.people_alt_outlined,
                label: 'Cuentas afectadas',
                value: breach.pwnCountFull,
              ),
              _InfoRow(
                icon: Icons.verified_outlined,
                label: 'Verificada',
                value: breach.isVerified ? 'Sí' : 'No',
              ),
              if (breach.isSensitive)
                const _InfoRow(
                  icon: Icons.visibility_off_outlined,
                  label: 'Sensible',
                  value: 'Solo visible con verificación del correo afectado',
                ),
              const SizedBox(height: 8),
              const Text(
                'Descripción',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                breach.plainDescription.isEmpty
                    ? 'Sin descripción.'
                    : breach.plainDescription,
                style: const TextStyle(height: 1.4),
              ),
              if (breach.dataClasses.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Datos expuestos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final data in breach.dataClasses)
                      Chip(
                        label: Text(data, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.background,
                        side: const BorderSide(color: AppColors.border),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Fuente: Have I Been Pwned (haveibeenpwned.com), '
                'licencia CC BY 4.0.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
