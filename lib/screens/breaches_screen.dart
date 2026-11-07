import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/breaches_provider.dart';
import '../services/breach_service.dart';
import '../widgets/breach_card.dart';
import '../widgets/breach_detail_sheet.dart';

/// Pantalla de resultados: muestra las filtraciones de datos que devuelve la
/// API de Have I Been Pwned. Dibuja uno de los tres estados del provider:
/// cargando, éxito (lista con pull-to-refresh) o error (con botón Reintentar).
class BreachesScreen extends StatelessWidget {
  const BreachesScreen({super.key});

  /// Pull-to-refresh sobre la lista con datos.
  Future<void> _refresh(BuildContext context) async {
    final provider = context.read<BreachesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.refresh();
    if (!ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar. Se muestran los últimos datos.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BreachesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brechas de datos'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        actions: [
          PopupMenuButton<BreachSort>(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            initialValue: provider.sort,
            onSelected: provider.setSort,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: BreachSort.recent,
                child: Text('Más recientes'),
              ),
              PopupMenuItem(
                value: BreachSort.mostAccounts,
                child: Text('Más cuentas afectadas'),
              ),
            ],
          ),
        ],
      ),
      body: switch (provider.status) {
        BreachesStatus.loading => const _LoadingView(),
        BreachesStatus.error => _ErrorView(
            error: provider.error,
            onRetry: provider.load,
          ),
        BreachesStatus.success => _SuccessView(
            provider: provider,
            onRefresh: () => _refresh(context),
          ),
      },
    );
  }
}

/// Estado 1: Cargando.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Consultando haveibeenpwned.com…',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Estado 3: Error (sin internet, tiempo agotado, servidor, etc.).
/// Se puede reintentar con el botón o arrastrando hacia abajo.
class _ErrorView extends StatelessWidget {
  final BreachException? error;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  IconData get _icon => switch (error?.kind) {
        BreachErrorKind.network => Icons.wifi_off,
        BreachErrorKind.timeout => Icons.timer_off_outlined,
        BreachErrorKind.rateLimited => Icons.speed,
        _ => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Icon(_icon, size: 72, color: AppColors.warning),
          const SizedBox(height: 16),
          const Text(
            'No se pudieron cargar los datos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error?.message ?? 'Ocurrió un error inesperado.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado 2: Éxito. Lista de tarjetas con pull-to-refresh.
class _SuccessView extends StatelessWidget {
  final BreachesProvider provider;
  final Future<void> Function() onRefresh;

  const _SuccessView({required this.provider, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final items = provider.visible;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: provider.setQuery,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, dominio o tipo de dato',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        _SummaryHeader(
          shown: items.length,
          total: provider.total,
          updated: provider.lastUpdated,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Text(
                          'Sin resultados.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final breach = items[index];
                      return BreachCard(
                        breach: breach,
                        onTap: () => showBreachDetail(context, breach),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int shown;
  final int total;
  final DateTime? updated;

  const _SummaryHeader({
    required this.shown,
    required this.total,
    required this.updated,
  });

  @override
  Widget build(BuildContext context) {
    final count = shown == total ? '$total' : '$shown de $total';
    final time = updated == null
        ? ''
        : ' · actualizado a las '
            '${updated!.hour.toString().padLeft(2, '0')}:'
            '${updated!.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$count brechas$time',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
