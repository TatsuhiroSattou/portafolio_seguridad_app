import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda cuál fue la última evidencia guardada, para mostrarla al volver
/// a abrir la app aunque se haya cerrado.
class EvidenceRepository {
  static const _key = 'last_evidence_path';

  Future<String?> loadLastPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> saveLastPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
  }
}
