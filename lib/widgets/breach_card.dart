import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/breach.dart';

/// Tarjeta de una brecha: logo, título, dominio, fecha, cuentas afectadas
/// y los primeros tipos de datos expuestos.
class BreachCard extends StatelessWidget {
  final Breach breach;
  final VoidCallback? onTap;

  const BreachCard({super.key, required this.breach, this.onTap});

  @override
  Widget build(BuildContext context) {
    final extra = breach.dataClasses.length - 4;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Logo(url: breach.logoUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          breach.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (breach.domain.isNotEmpty)
                          Text(
                            breach.domain,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (breach.isVerified)
                    const Tooltip(
                      message: 'Brecha verificada',
                      child: Icon(
                        Icons.verified,
                        size: 20,
                        color: AppColors.success,
                      ),
                    ),
                  if (breach.isSensitive)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Tooltip(
                        message: 'Brecha sensible',
                        child: Icon(
                          Icons.visibility_off,
                          size: 20,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    Breach.formatDate(breach.breachDate),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.people_alt_outlined,
                    size: 16,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${breach.pwnCountLabel} cuentas',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (breach.dataClasses.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final data in breach.dataClasses.take(4))
                      _DataChip(label: data),
                    if (extra > 0) _DataChip(label: '+$extra', highlight: true),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo remoto con indicador de carga y un ícono si la imagen falla.
class _Logo extends StatelessWidget {
  final String url;

  const _Logo({required this.url});

  @override
  Widget build(BuildContext context) {
    const size = 48.0;

    if (url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.lock_open, color: AppColors.secondary),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        padding: const EdgeInsets.all(4),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _DataChip extends StatelessWidget {
  final String label;
  final bool highlight;

  const _DataChip({required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.secondary : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
