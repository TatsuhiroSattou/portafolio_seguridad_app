import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio nativo de notificaciones locales (canal de Android + iOS).
class NotificationService {
  static const String _channelId = 'bugtatsu_events';
  static const String _channelName = 'Eventos del sistema';
  static const String _channelDescription =
      'Avisos de conexión, envío de solicitudes y evidencias.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  int _nextId = 0;

  /// Inicializa el plugin y crea el canal de Android.
  Future<void> init() async {
    if (_initialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Pide permiso para mostrar notificaciones (obligatorio desde Android 13).
  /// Devuelve true si el usuario lo concedió.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? await android.areNotificationsEnabled() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final granted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? false;
  }

  /// Muestra una notificación inmediata. Los errores se registran pero no
  /// se propagan: una notificación fallida nunca debe romper la app.
  Future<void> show({required String title, required String body}) async {
    try {
      if (!_initialized) await init();

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(_nextId++, title, body, details);
    } catch (error) {
      debugPrint('No se pudo mostrar la notificación: $error');
    }
  }
}
