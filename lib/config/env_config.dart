import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso centralizado a las variables definidas en el archivo `.env`.
class EnvConfig {
  EnvConfig._();

  static const String _envFile = '.env';
  static const String _defaultBaseUrl = 'https://api-colombia.com/api/v1';
  static const int _defaultTimeoutSeconds = 15;

  /// Carga el archivo `.env`. Debe llamarse antes de `runApp`.
  static Future<void> load() => dotenv.load(fileName: _envFile);

  /// URL base de API Colombia, sin barra final.
  static String get apiBaseUrl {
    final url = dotenv.maybeGet('API_BASE_URL') ?? _defaultBaseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Tiempo máximo de espera para cada petición HTTP.
  static Duration get apiTimeout {
    final seconds = int.tryParse(dotenv.maybeGet('API_TIMEOUT_SECONDS') ?? '');
    return Duration(seconds: seconds ?? _defaultTimeoutSeconds);
  }
}
