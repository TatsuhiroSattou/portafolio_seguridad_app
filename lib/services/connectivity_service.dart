import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio nativo de red. No depende de ninguna pantalla ni de Provider.
///
/// connectivity_plus solo informa si hay una interfaz activa (Wi-Fi, datos);
/// no garantiza que haya internet. Por eso, cuando hay interfaz, se confirma
/// con una consulta DNS real.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Estado actual (consulta puntual).
  Future<bool> checkOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _verify(results);
  }

  /// Flujo reactivo: emite true/false cada vez que cambia la conectividad.
  Stream<bool> get onlineStream =>
      _connectivity.onConnectivityChanged.asyncMap(_verify).distinct();

  Future<bool> _verify(List<ConnectivityResult> results) async {
    final hasInterface = results.any((r) => r != ConnectivityResult.none);
    if (!hasInterface) return false;
    return _hasInternetAccess();
  }

  Future<bool> _hasInternetAccess({int attempts = 3}) async {
    for (var i = 0; i < attempts; i++) {
      try {
        final addresses = await InternetAddress.lookup('example.com')
            .timeout(const Duration(seconds: 3));
        if (addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException {
        // Sin DNS / sin salida a internet en este intento.
      } on TimeoutException {
        // La red tardó demasiado en responder.
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return false;
  }
}
