import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Resultado de recortar y comprimir una imagen.
class ProcessedImage {
  const ProcessedImage({
    required this.file,
    required this.originalBytes,
    required this.finalBytes,
    required this.width,
    required this.height,
  });

  final File file;
  final int originalBytes;
  final int finalBytes;
  final int width;
  final int height;

  int get savedPercent => originalBytes == 0
      ? 0
      : (((originalBytes - finalBytes) / originalBytes) * 100).round();
}

/// Servicio nativo de cámara y galería.
class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Abre la cámara o la galería. Devuelve null si el usuario cancela.
  Future<XFile?> pick(ImageSource source) => _picker.pickImage(source: source);

  static const int _maxSide = 1024;
  static const int _quality = 75;

  /// Recorta al centro en formato cuadrado y comprime a JPEG.
  /// El trabajo pesado se hace en otro isolate para no congelar la interfaz.
  Future<ProcessedImage> cropAndCompress(XFile source) async {
    final bytes = await source.readAsBytes();
    final result = await compute(
      _cropAndCompress,
      _CropJob(bytes, _maxSide, _quality),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/evidence_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(result.bytes, flush: true);

    return ProcessedImage(
      file: file,
      originalBytes: bytes.length,
      finalBytes: result.bytes.length,
      width: result.width,
      height: result.height,
    );
  }
}

class _CropJob {
  const _CropJob(this.bytes, this.maxSide, this.quality);

  final Uint8List bytes;
  final int maxSide;
  final int quality;
}

class _CropResult {
  const _CropResult(this.bytes, this.width, this.height);

  final Uint8List bytes;
  final int width;
  final int height;
}

/// Función de nivel superior: es la que se ejecuta en el isolate.
_CropResult _cropAndCompress(_CropJob job) {
  final decoded = img.decodeImage(job.bytes);
  if (decoded == null) {
    throw const FormatException('El archivo no es una imagen válida.');
  }

  final oriented = img.bakeOrientation(decoded);
  final side =
      oriented.width < oriented.height ? oriented.width : oriented.height;
  final x = (oriented.width - side) ~/ 2;
  final y = (oriented.height - side) ~/ 2;

  var square = img.copyCrop(oriented, x: x, y: y, width: side, height: side);
  if (side > job.maxSide) {
    square = img.copyResize(square, width: job.maxSide, height: job.maxSide);
  }

  final encoded = img.encodeJpg(square, quality: job.quality);
  return _CropResult(Uint8List.fromList(encoded), square.width, square.height);
}
