import 'package:flutter/foundation.dart';

import '../models/breach.dart';
import '../services/breach_service.dart';

/// Los tres estados de la petición que dibuja la interfaz.
enum BreachesStatus { loading, success, error }

/// Gestiona el estado de la consulta a la API con Provider.
///
/// La pantalla solo observa este objeto: no sabe nada de HTTP ni de JSON.
/// El provider le pide los datos al [BreachService] y traduce el resultado
/// a uno de los tres estados: cargando, éxito o error.
class BreachesProvider extends ChangeNotifier {
  BreachesProvider(
    this._service, {
    this.minLoadingTime = const Duration(milliseconds: 800),
  });

  final BreachService _service;

  /// Tiempo mínimo que se muestra el estado "Cargando", para que no parpadee
  /// cuando la red responde muy rápido.
  final Duration minLoadingTime;

  BreachesStatus _status = BreachesStatus.loading;
  List<Breach> _all = const [];
  BreachException? _error;
  DateTime? _lastUpdated;
  bool _disposed = false;

  BreachesStatus get status => _status;
  BreachException? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  /// Total de brechas descargadas (sin filtros).
  int get total => _all.length;

  /// Lista que ve el usuario: las brechas más recientes primero.
  List<Breach> get visible => _all;

  /// Carga inicial o reintento: pasa por el estado "Cargando".
  Future<void> load() async {
    _status = BreachesStatus.loading;
    _error = null;
    _notify();

    final minWait = Future<void>.delayed(minLoadingTime);
    try {
      final data = await _service.fetchBreaches();
      await minWait;
      _all = data..sort(_byRecent);
      _lastUpdated = DateTime.now();
      _status = BreachesStatus.success;
    } on BreachException catch (error) {
      await minWait;
      _error = error;
      _status = BreachesStatus.error;
    } catch (error) {
      await minWait;
      _error = BreachException(
        BreachErrorKind.unknown,
        'Ocurrió un error inesperado: $error',
      );
      _status = BreachesStatus.error;
    }
    _notify();
  }

  /// Pull-to-refresh: mantiene la lista visible mientras actualiza.
  /// Devuelve true si la actualización salió bien.
  Future<bool> refresh() async {
    if (_all.isEmpty) {
      await load();
      return _status == BreachesStatus.success;
    }
    try {
      final data = await _service.fetchBreaches();
      _all = data..sort(_byRecent);
      _lastUpdated = DateTime.now();
      _error = null;
      _notify();
      return true;
    } catch (error) {
      debugPrint('No se pudo actualizar las brechas: $error');
      return false;
    }
  }

  static int _byRecent(Breach a, Breach b) {
    final da = a.addedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final db = b.addedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    return db.compareTo(da);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
