import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Descarga imágenes remotas respetando los límites de Wikimedia:
/// pocas peticiones simultáneas, reintentos con espera ante 429/5xx y
/// paso a la siguiente URL candidata solo ante errores definitivos (4xx).
class ImageService {
  static final ImageService instance = ImageService();

  /// Wikimedia exige un User-Agent identificable. En web el navegador no
  /// permite cambiarlo, así que solo se envía en las demás plataformas.
  static const Map<String, String> _headers = kIsWeb
      ? {}
      : {'User-Agent': 'TallerDatosAbiertos/1.0 (Flutter; proyecto educativo)'};

  final http.Client _client;
  final int maxConcurrent;
  final int maxAttempts;
  final Duration retryDelay;
  final Duration timeout;

  final Map<String, Future<Uint8List?>> _cache = {};
  final Queue<Completer<void>> _waiting = Queue();
  int _active = 0;

  ImageService({
    http.Client? client,
    this.maxConcurrent = 3,
    this.maxAttempts = 4,
    this.retryDelay = const Duration(milliseconds: 800),
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  /// Bytes de la primera URL de [candidates] que responda una imagen, o
  /// `null` si ninguna funciona. Las descargas exitosas quedan en memoria.
  Future<Uint8List?> load(List<String> candidates) {
    if (candidates.isEmpty) return Future.value(null);
    final key = candidates.first;
    return _cache.putIfAbsent(key, () async {
      final bytes = await _loadFirst(candidates);
      // Los fallos no se guardan, para reintentar si la imagen vuelve a verse.
      if (bytes == null) _cache.remove(key);
      return bytes;
    });
  }

  Future<Uint8List?> _loadFirst(List<String> candidates) async {
    for (final url in candidates) {
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final response = await _get(url);
        if (response != null &&
            response.statusCode == 200 &&
            (response.headers['content-type'] ?? '').startsWith('image/')) {
          return response.bodyBytes;
        }
        final retryable = response == null ||
            response.statusCode == 429 ||
            response.statusCode >= 500;
        if (!retryable) break; // Error definitivo: probar la siguiente URL.
        await Future<void>.delayed(retryDelay * (1 << attempt));
      }
    }
    return null;
  }

  Future<http.Response?> _get(String url) async {
    await _acquire();
    try {
      return await _client
          .get(Uri.parse(url), headers: _headers)
          .timeout(timeout);
    } catch (_) {
      return null;
    } finally {
      _release();
    }
  }

  Future<void> _acquire() {
    if (_active < maxConcurrent) {
      _active++;
      return Future.value();
    }
    final turn = Completer<void>();
    _waiting.add(turn);
    return turn.future;
  }

  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeFirst().complete();
    } else {
      _active--;
    }
  }
}
