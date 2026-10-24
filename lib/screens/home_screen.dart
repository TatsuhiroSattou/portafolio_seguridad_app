import 'package:flutter/material.dart';

import '../models/security_report.dart';
import '../widgets/report_card.dart';
import 'detail_screen.dart';

/// Pantalla 1: listado principal de reportes de seguridad.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Navega a la Pantalla 2 enviando el reporte como parámetro y
  /// espera (await) el resultado que devuelve Navigator.pop.
  Future<void> _openDetail(BuildContext context, SecurityReport report) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(report: report),
      ),
    );

    // Si el usuario volvió con un mensaje, se muestra en un SnackBar.
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Portfolio'),
        centerTitle: true,
        leading: const Icon(Icons.shield),
      ),
      body: Column(
        children: [
          // Encabezado estilo terminal con datos del investigador.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF010409),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  r'victor@security-portfolio:~$ whoami',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.bug_report, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Offensive Security Specialist & Bug Bounty Hunter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final cert in certifications)
                      Chip(
                        label: Text(cert, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(Icons.verified, size: 14),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: sampleReports.length,
              itemBuilder: (context, index) {
                final report = sampleReports[index];
                return ReportCard(
                  report: report,
                  onViewDetail: () => _openDetail(context, report),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
