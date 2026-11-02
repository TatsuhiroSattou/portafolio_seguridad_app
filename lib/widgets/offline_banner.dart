import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/connectivity_provider.dart';

/// Envuelve toda la app y dibuja un banner flotante cuando no hay internet.
///
/// Se engancha en `MaterialApp.builder`, así aparece sobre cualquier pantalla
/// sin que cada pantalla tenga que saber nada de la conectividad.
class OfflineBannerHost extends StatelessWidget {
  final Widget child;

  const OfflineBannerHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final online = context.select<ConnectivityProvider, bool>(
      (provider) => provider.isOnline,
    );
    final top = MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    return Stack(
      textDirection: TextDirection.ltr,
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          top: top,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: AnimatedSlide(
              offset: online ? const Offset(0, -2) : Offset.zero,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: online ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                child: const _OfflineBanner(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: Color(0xFF1F1300)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sin conexión. Tus solicitudes se guardarán en el '
                'dispositivo y se enviarán al reconectar.',
                style: TextStyle(
                  color: Color(0xFF1F1300),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
