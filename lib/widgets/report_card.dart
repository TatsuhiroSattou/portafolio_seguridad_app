import 'package:flutter/material.dart';

import '../models/security_report.dart';
import 'severity_chip.dart';

/// Tarjeta reutilizable con el resumen de un reporte de seguridad.
class ReportCard extends StatelessWidget {
  final SecurityReport report;
  final VoidCallback onViewDetail;

  const ReportCard({
    super.key,
    required this.report,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = report.isResolved;

    return Card(
      elevation: 3,
      color: const Color(0xFF161B22),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            report.imagePath,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 130,
              width: double.infinity,
              color: const Color(0xFF21262D),
              child: const Icon(Icons.security, size: 48, color: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.organization,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SeverityChip(severity: report.severity),
                    const Spacer(),
                    Icon(
                      resolved ? Icons.check_circle : Icons.hourglass_top,
                      size: 18,
                      color: resolved ? Colors.green : Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(report.status),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onViewDetail,
                    icon: const Icon(Icons.terminal),
                    label: const Text('Ver detalle'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
