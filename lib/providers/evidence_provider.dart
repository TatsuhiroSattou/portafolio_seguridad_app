import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/image_service.dart';
import '../services/permission_service.dart';

/// Estados posibles de la pantalla de evidencia.
enum EvidenceStatus {
  idle,
  busy,
  permissionDenied,
  permissionBlocked,
  error,
}

/// Orquesta el flujo: permiso -> cámara/galería -> (recorte y compresión).
/// No conoce widgets: solo habla con los servicios y avisa a la interfaz.
class EvidenceProvider extends ChangeNotifier {
  EvidenceProvider({
    required PermissionService permissions,
    required ImageService images,
    this.onEvidenceReady,
  })  : _permissions = permissions,
        _images = images {
  }

  final PermissionService _permissions;
  final ImageService _images;

  /// Se invoca cuando una imagen quedó lista (sirve para notificar).
  final void Function(String message)? onEvidenceReady;

  EvidenceStatus _status = EvidenceStatus.idle;
  String? _errorMessage;
  bool _disposed = false;

  File? _file;

  File? get imageFile => _file;

  EvidenceStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> capture(ImageSource source) async {
    if (_status == EvidenceStatus.busy) return;
    _setStatus(EvidenceStatus.busy);

    try {
      if (source == ImageSource.camera) {
        final permission = await _permissions.requestCamera();
        if (permission == PermissionResult.denied) {
          _setStatus(EvidenceStatus.permissionDenied);
          return;
        }
        if (permission == PermissionResult.permanentlyDenied) {
          _setStatus(EvidenceStatus.permissionBlocked);
          return;
        }
      }

      final picked = await _images.pick(source);
      if (picked == null) {
        _setStatus(EvidenceStatus.idle); // el usuario canceló
        return;
      }

      _file = File(picked.path);
      onEvidenceReady?.call('Imagen seleccionada correctamente.');
      _setStatus(EvidenceStatus.idle);
    } on PlatformException catch (e) {
      _fail('No se pudo acceder a la cámara o a la galería (${e.code}).');
    } on FormatException catch (e) {
      _fail(e.message);
    } on FileSystemException {
      _fail('No se pudo guardar la imagen en el dispositivo.');
    } catch (_) {
      _fail('Ocurrió un error inesperado al procesar la imagen.');
    }
  }

  /// Lleva al usuario a los ajustes de la app (permiso bloqueado).
  Future<void> openSettings() async {
    await _permissions.openSettings();
  }

  void _fail(String message) {
    _errorMessage = message;
    _setStatus(EvidenceStatus.error);
  }

  void _setStatus(EvidenceStatus status) {
    if (_disposed) return;
    _status = status;
    if (status != EvidenceStatus.error) _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
