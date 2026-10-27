import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taller_datos_abiertos/services/services.dart';

const _baseUrl = 'https://api-colombia.com/api/v1';

ApiClient _clientWith(MockClientHandler handler) => ApiClient(
      client: MockClient(handler),
      baseUrl: _baseUrl,
      timeout: const Duration(milliseconds: 200),
    );

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json'},
    );

void main() {
  test('getAll consulta /Department y decodifica UTF-8', () async {
    late Uri requested;
    final service = DepartmentService(_clientWith((request) async {
      requested = request.url;
      return _json([
        {'id': 5, 'name': 'Bolívar', 'description': 'Región Caribe'},
      ]);
    }));

    final result = await service.getAll();

    expect(requested.toString(), '$_baseUrl/Department');
    expect(result.single.name, 'Bolívar');
  });

  test('getById consulta /President/{id}', () async {
    late Uri requested;
    final service = PresidentService(_clientWith((request) async {
      requested = request.url;
      return _json({'id': 3, 'name': 'Rafael', 'lastName': 'Núñez'});
    }));

    final result = await service.getById(3);

    expect(requested.path, '/api/v1/President/3');
    expect(result.fullName, 'Rafael Núñez');
  });

  test('404 se traduce a ApiException', () {
    final service = TypicalDishService(
        _clientWith((_) async => http.Response('Not found', 404)));

    expect(
      service.getById(9999),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
    );
  });

  test('error 500 se traduce a ApiException', () {
    final service = TouristicAttractionService(
        _clientWith((_) async => http.Response('boom', 500)));

    expect(service.getAll(), throwsA(isA<ApiException>()));
  });

  test('error de red se traduce a ApiException', () {
    final service = DepartmentService(_clientWith(
        (_) async => throw http.ClientException('Failed host lookup')));

    expect(service.getAll(), throwsA(isA<ApiException>()));
  });

  test('timeout se traduce a ApiException', () {
    final service = DepartmentService(_clientWith((_) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return _json([]);
    }));

    expect(service.getAll(), throwsA(isA<ApiException>()));
  });

  test('respuesta con formato inesperado lanza ApiException', () {
    final service =
        DepartmentService(_clientWith((_) async => _json({'id': 1})));

    expect(service.getAll(), throwsA(isA<ApiException>()));
  });
}
