import 'package:flutter/foundation.dart';

import '../models/contact_request.dart';
import '../repositories/requests_repository.dart';

/// Gestiona las solicitudes de contacto con estrategia "offline first":
/// siempre se guardan primero en el dispositivo y se envían cuando hay red.
///
/// El envío al servidor está simulado (no hay backend en este MVP).
class RequestsProvider extends ChangeNotifier {
  RequestsProvider(this._repository, {this.onSynced}) {
    _load();
  }

  final RequestsRepository _repository;

  /// Se invoca cuando se envían solicitudes que estaban pendientes.
  final void Function(int count)? onSynced;

  List<ContactRequest> _items = const [];
  bool _online = false;
  bool _flushing = false;
  bool _disposed = false;

  List<ContactRequest> get items => List.unmodifiable(_items);
  int get pendingCount => _items.where((r) => !r.sent).length;

  Future<void> _load() async {
    _items = await _repository.load();
    if (_disposed) return;
    notifyListeners();
    await flushPending();
  }

  /// Lo llama el ProxyProvider cada vez que cambia el estado de red.
  void updateConnectivity(bool online) {
    if (online == _online) return;
    _online = online;
    if (online) Future.microtask(flushPending);
  }

  /// Guarda la solicitud y, si hay red, la envía. Devuelve true si ya se envió.
  Future<bool> submit({
    required int reportId,
    required String organization,
    required String name,
    required String reason,
  }) async {
    final request = ContactRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      reportId: reportId,
      organization: organization,
      name: name,
      reason: reason,
      createdAt: DateTime.now(),
      sent: false,
    );

    _items = [request, ..._items];
    await _repository.save(_items);
    notifyListeners();

    await flushPending();
    return _items.firstWhere((r) => r.id == request.id).sent;
  }

  /// Envía todas las solicitudes pendientes (si hay conexión).
  Future<void> flushPending() async {
    if (_flushing || !_online) return;
    final pending = pendingCount;
    if (pending == 0) return;

    _flushing = true;
    try {
      // Simulación del envío al servidor.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!_online || _disposed) return; // se perdió la red durante el envío

      _items = _items.map((r) => r.sent ? r : r.copyWith(sent: true)).toList();
      await _repository.save(_items);
      if (_disposed) return;
      notifyListeners();
      onSynced?.call(pending);
    } finally {
      _flushing = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
