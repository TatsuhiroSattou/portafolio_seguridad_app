import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/contact_request.dart';
import '../providers/connectivity_provider.dart';
import '../providers/requests_provider.dart';

/// Lista las solicitudes guardadas en el dispositivo y su estado de envío.
class OutboxScreen extends StatelessWidget {
  const OutboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<RequestsProvider>();
    final online = context.select<ConnectivityProvider, bool>(
      (provider) => provider.isOnline,
    );
    final items = requests.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Aún no has enviado solicitudes.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) => _RequestTile(request: items[index]),
            ),
      bottomNavigationBar: requests.pendingCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: online ? requests.flushPending : null,
                  icon: const Icon(Icons.sync),
                  label: Text('Reintentar envío (${requests.pendingCount})'),
                ),
              ),
            )
          : null,
    );
  }
}

class _RequestTile extends StatelessWidget {
  final ContactRequest request;

  const _RequestTile({required this.request});

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final sent = request.sent;
    return ListTile(
      leading: Icon(
        sent ? Icons.check_circle : Icons.schedule,
        color: sent ? AppColors.success : AppColors.warning,
      ),
      title: Text('${request.organization} · ${request.reason}'),
      subtitle: Text('${request.name} · ${_formatDate(request.createdAt)}'),
      trailing: Text(
        sent ? 'Enviada' : 'Pendiente',
        style: TextStyle(
          color: sent ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
