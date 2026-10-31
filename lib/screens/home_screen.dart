import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/security_report.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/report_card.dart';
import 'detail_screen.dart';

/// Pantalla 1: listado principal de reportes de seguridad.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Navega a la Pantalla 2 enviando el reporte como parámetro y
  /// espera (await) el resultado que devuelve Navigator.pop.
  Future<void> _openDetail(SecurityReport report) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(report: report),
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BugTatsu Sec'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        centerTitle: true,
        leading: const Icon(Icons.shield_outlined),
        actions: [
          const _ConnectionIndicator(),
        ],
      ),
      body: Column(
        children: [
          // Encabezado estilo terminal con datos del investigador.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF070C16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  r'bugtatsu@sec:~$ whoami',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.bug_report, size: 28, color: AppColors.secondary),
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
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        avatar: const Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${sampleReports.length} reportes · divulgación responsable',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: sampleReports.length,
              itemBuilder: (context, index) {
                final report = sampleReports[index];
                return ReportCard(
                  report: report,
                  onViewDetail: () => _openDetail(report),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Ícono de estado de red en la AppBar (se actualiza solo).
class _ConnectionIndicator extends StatelessWidget {
  const _ConnectionIndicator();

  @override
  Widget build(BuildContext context) {
    final online = context.select<ConnectivityProvider, bool>(
      (provider) => provider.isOnline,
    );
    return Tooltip(
      message: online ? 'En línea' : 'Sin conexión',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          online ? Icons.wifi : Icons.wifi_off,
          color: online ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}

