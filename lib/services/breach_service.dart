import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/breach.dart';

/// Tipos de error que puede producir la consulta a la API.
enum BreachErrorKind { network, timeout, rateLimited, server, parse, unknown }

/// Error de la capa de red con un mensaje listo para mostrar al usuario.
/// Así la interfaz nunca depende de las excepciones internas de `http`.
class BreachException implements Exception {
  final BreachErrorKind kind;
  final String message;
  final int? statusCode;

  const BreachException(this.kind, this.message, {this.statusCode});

  @override
  String toString() => 'BreachException($kind, $statusCode): $message';
}

/// Servicio de red: único lugar que conoce la URL, las cabeceras y el
/// formato HTTP de la API. No depende de ninguna pantalla ni de Provider.
class BreachService {
  BreachService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Endpoint público (sin token). Devuelve un arreglo JSON con todas las brechas.
  static final Uri endpoint =
      Uri.parse('https://haveibeenpwned.com/api/v3/breaches');

  /// La API rechaza (403) las peticiones sin cabecera User-Agent.
  static const Map<String, String> _headers = {
    'user-agent': 'BugTatsuSec-Flutter-StudentProject/3.0',
    'accept': 'application/json',
  };

  static const Duration _timeout = Duration(seconds: 20);

  /// Descarga la lista de brechas. Lanza [BreachException] ante cualquier fallo.
  Future<List<Breach>> fetchBreaches() async {
    try {
      final response =
          await _client.get(endpoint, headers: _headers).timeout(_timeout);

      if (response.statusCode == 429) {
        throw const BreachException(
          BreachErrorKind.rateLimited,
          'Demasiadas consultas seguidas. Espera un momento y vuelve a intentar.',
          statusCode: 429,
        );
      }
      if (response.statusCode != 200) {
        throw BreachException(
          BreachErrorKind.server,
          'El servidor respondió con un error (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      // Se decodifica como UTF-8 a mano: así los acentos salen bien aunque el
      // servidor no indique el charset.
      final body = utf8.decode(response.bodyBytes);
      // El JSON pesa cerca de 1 MB: se procesa en otro isolate para no
      // congelar la interfaz.
      return await compute(parseBreaches, body);
    } on BreachException {
      rethrow;
    } on TimeoutException {
      throw const BreachException(
        BreachErrorKind.timeout,
        'El servidor tardó demasiado en responder.',
      );
    } on IOException {
      // Incluye SocketException (sin internet / sin DNS) y errores TLS.
      throw const BreachException(
        BreachErrorKind.network,
        'No hay conexión a internet. Revisa tu red e inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const BreachException(
        BreachErrorKind.network,
        'No se pudo conectar con el servidor.',
      );
    } on FormatException {
      throw const BreachException(
        BreachErrorKind.parse,
        'La respuesta del servidor no tiene el formato esperado.',
      );
    } catch (error) {
      throw BreachException(
        BreachErrorKind.unknown,
        'Ocurrió un error inesperado: $error',
      );
    }
  }

  void dispose() => _client.close();
}

/// Convierte el cuerpo JSON en modelos. Es una función de nivel superior para
/// poder ejecutarse con `compute` en un isolate.
List<Breach> parseBreaches(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) {
    throw const FormatException('Se esperaba una lista de brechas');
  }
  return decoded
      .whereType<Map<String, dynamic>>()
      .map(Breach.fromJson)
      .toList();
}
