import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/evidence_provider.dart';
import '../services/image_service.dart';

/// Pantalla de evidencia: cámara/galería con permisos en tiempo de ejecución.
class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final evidence = context.watch<EvidenceProvider>();
    final busy = evidence.status == EvidenceStatus.busy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia fotográfica'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Adjunta una captura como evidencia. La imagen se recorta en '
            'formato cuadrado y se comprime antes de guardarse.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _Preview(file: evidence.imageFile),
          const SizedBox(height: 12),
          if (evidence.result != null) _Stats(result: evidence.result!),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),
          _StatusMessage(evidence: evidence),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : () => evidence.capture(ImageSource.camera),
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Tomar foto'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed:
                busy ? null : () => evidence.capture(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Elegir de la galería'),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final File? file;

  const _Preview({required this.file});

  @override
  Widget build(BuildContext context) {
    final image = file;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: image == null
            ? Container(
                color: AppColors.surface,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 56,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sin imagen',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            : Image.file(image, fit: BoxFit.cover),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final ProcessedImage result;

  const _Stats({required this.result});

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Original: ${_formatBytes(result.originalBytes)}'),
          Text('Comprimida: ${_formatBytes(result.finalBytes)}'),
          Text('Ahorro: ${result.savedPercent}%'),
          Text('Dimensiones: ${result.width} x ${result.height} px'),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final EvidenceProvider evidence;

  const _StatusMessage({required this.evidence});

  @override
  Widget build(BuildContext context) {
    switch (evidence.status) {
      case EvidenceStatus.permissionDenied:
        return _MessageCard(
          icon: Icons.no_photography_outlined,
          color: AppColors.warning,
          text: 'Sin el permiso de cámara no puedo abrirla. Puedes volver a '
              'intentarlo o elegir una imagen de la galería.',
          actionLabel: 'Reintentar',
          onAction: () => evidence.capture(ImageSource.camera),
        );
      case EvidenceStatus.permissionBlocked:
        return _MessageCard(
          icon: Icons.lock_outline,
          color: AppColors.danger,
          text: 'El permiso de cámara está bloqueado. Actívalo en los ajustes '
              'de la aplicación.',
          actionLabel: 'Abrir ajustes',
          onAction: evidence.openSettings,
        );
      case EvidenceStatus.error:
        return _MessageCard(
          icon: Icons.error_outline,
          color: AppColors.danger,
          text: evidence.errorMessage ?? 'Ocurrió un error.',
        );
      case EvidenceStatus.idle:
      case EvidenceStatus.busy:
        return const SizedBox.shrink();
    }
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageCard({
    required this.icon,
    required this.color,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
          if (actionLabel != null && onAction != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
        ],
      ),
    );
  }
}
