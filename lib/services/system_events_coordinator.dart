import '../providers/connectivity_provider.dart';
import 'notification_service.dart';

/// Conecta dos módulos que no se conocen entre sí: cuando la red cambia de
/// estado, avisa con una notificación local. Así ConnectivityProvider no
/// depende de NotificationService (desacoplamiento).
class SystemEventsCoordinator {
  SystemEventsCoordinator({
    required ConnectivityProvider connectivity,
    required NotificationService notifications,
  })  : _connectivity = connectivity,
        _notifications = notifications,
        _lastOnline = connectivity.isOnline {
    _connectivity.addListener(_onConnectivityChanged);
  }

  final ConnectivityProvider _connectivity;
  final NotificationService _notifications;
  bool _lastOnline;

  void _onConnectivityChanged() {
    final online = _connectivity.isOnline;
    if (online == _lastOnline) return;
    _lastOnline = online;

    _notifications.show(
      title: online ? 'Conexión restablecida' : 'Sin conexión',
      body: online
          ? 'BugTatsu Sec volvió a estar en línea.'
          : 'Modo offline: tus solicitudes se guardarán en el dispositivo.',
    );
  }

  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
  }
}
