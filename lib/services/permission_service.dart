import 'package:permission_handler/permission_handler.dart';

/// Resultado simplificado de pedir un permiso, independiente del plugin.
enum PermissionResult { granted, denied, permanentlyDenied }

/// Servicio nativo de permisos en tiempo de ejecución.
class PermissionService {
  /// Pide el permiso de cámara, manejando los tres casos:
  /// concedido, denegado (se puede volver a pedir) y bloqueado para siempre.
  Future<PermissionResult> requestCamera() async {
    var status = await Permission.camera.status;
    if (status.isGranted) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;

    status = await Permission.camera.request();
    if (status.isGranted) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;
    return PermissionResult.denied;
  }

  /// Abre los ajustes de la app (único camino cuando el permiso está bloqueado).
  Future<bool> openSettings() => openAppSettings();
}
