import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/security_report.dart';
import '../widgets/severity_chip.dart';

/// Pantalla 2: detalle del reporte y formulario de contacto.
/// Recibe el [SecurityReport] seleccionado en la Pantalla 1 por constructor.
class DetailScreen extends StatefulWidget {
  final SecurityReport report;

  const DetailScreen({super.key, required this.report});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const List<String> _reasons = [
    'Consulta técnica',
    'Colaboración',
    'Oferta laboral',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _reason = _reasons.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final report = widget.report;

    // Regresa a la Pantalla 1 devolviendo un mensaje (vuelta).
    Navigator.pop(
      context,
      'Solicitud de $name ($_reason) sobre el reporte de ${report.organization}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return Scaffold(
      appBar: AppBar(
        title: Text(report.organization),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                report.imagePath,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  width: double.infinity,
                  color: AppColors.border,
                  child: const Icon(
                    Icons.security,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              report.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SeverityChip(severity: report.severity),
                const SizedBox(width: 12),
                Icon(
                  report.isResolved ? Icons.check_circle : Icons.hourglass_top,
                  size: 18,
                  color:
                      report.isResolved ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(report.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'ID de reporte: #${report.id}',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.bug_report,
              label: 'Tipo',
              value: report.vulnType,
            ),
            _InfoRow(
              icon: Icons.description,
              label: 'Descripción',
              value: report.description,
            ),
            _InfoRow(
              icon: Icons.priority_high,
              label: 'Impacto',
              value: report.impact,
            ),
            const Divider(height: 32),
            const Text(
              'Contactar sobre este reporte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tu nombre',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Motivo'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final reason in _reasons)
                        ChoiceChip(
                          label: Text(reason),
                          selected: _reason == reason,
                          onSelected: (_) => setState(() => _reason = reason),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar solicitud'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver al listado'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila reutilizable de información (ícono + etiqueta + valor).
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
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
