import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/connectivity_service.dart';

/// Expone a la interfaz el estado de red del servicio.
///
/// Hasta que se conoce el primer estado real, [isOnline] devuelve true (para no
/// mostrar el banner por error al abrir la app) pero [isReady] es false.
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider(this._service) {
    _start();
  }

  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;
  bool? _online;
  bool _disposed = false;

  bool get isOnline => _online ?? true;
  bool get isReady => _online != null;

  Future<void> _start() async {
    _subscription = _service.onlineStream.listen(
      _update,
      onError: (Object error) {
        // Un error del stream no debe tumbar la app: se conserva el último estado.
        debugPrint('Error en el stream de conectividad: $error');
      },
    );
    try {
      _update(await _service.checkOnline());
    } catch (error) {
      debugPrint('No se pudo consultar la conectividad: $error');
    }
  }

  void _update(bool online) {
    if (_disposed || online == _online) return;
    _online = online;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
