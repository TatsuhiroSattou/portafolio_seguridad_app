import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact_request.dart';

/// Persistencia local (caché) de las solicitudes de contacto.
class RequestsRepository {
  static const _key = 'contact_requests_v1';

  Future<List<ContactRequest>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ContactRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      // Si el contenido guardado está dañado, se descarta en vez de cerrar la app.
      debugPrint('Caché de solicitudes dañada, se reinicia: $error');
      await prefs.remove(_key);
      return [];
    }
  }

  Future<void> save(List<ContactRequest> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
