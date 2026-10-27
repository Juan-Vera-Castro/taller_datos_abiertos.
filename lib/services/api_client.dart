import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env_config.dart';
import 'api_exception.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

/// Cliente HTTP base: arma las URL a partir de `API_BASE_URL`, hace
/// peticiones GET y traduce cualquier fallo a [ApiException].
class ApiClient {
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;

  ApiClient({http.Client? client, String? baseUrl, Duration? timeout})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? EnvConfig.apiBaseUrl,
        _timeout = timeout ?? EnvConfig.apiTimeout;

  /// GET a un endpoint que devuelve un arreglo JSON.
  Future<List<T>> getList<T>(String path, FromJson<T> fromJson) async {
    final data = await _get(path);
    if (data is! List) {
      throw const ApiException('La respuesta no tiene el formato esperado.');
    }
    return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  /// GET a un endpoint que devuelve un único objeto JSON.
  Future<T> getOne<T>(String path, FromJson<T> fromJson) async {
    final data = await _get(path);
    if (data is! Map<String, dynamic>) {
      throw const ApiException('La respuesta no tiene el formato esperado.');
    }
    return fromJson(data);
  }

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
          'El servidor tardó demasiado en responder. Intenta de nuevo.');
    } on http.ClientException {
      // http 1.x envuelve los errores de red (p. ej. SocketException) aquí.
      throw const ApiException(
          'No fue posible conectar con API Colombia. Revisa tu conexión a internet.');
    }

    if (response.statusCode == 404) {
      throw const ApiException('El registro solicitado no existe.',
          statusCode: 404);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
          'API Colombia respondió con un error (${response.statusCode}).',
          statusCode: response.statusCode);
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('No se pudo interpretar la respuesta.');
    }
  }

  void close() => _client.close();
}
