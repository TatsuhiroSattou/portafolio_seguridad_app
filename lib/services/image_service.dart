
import 'package:image_picker/image_picker.dart';

/// Servicio nativo de cámara y galería.
class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Abre la cámara o la galería. Devuelve null si el usuario cancela.
  Future<XFile?> pick(ImageSource source) => _picker.pickImage(source: source);

}

