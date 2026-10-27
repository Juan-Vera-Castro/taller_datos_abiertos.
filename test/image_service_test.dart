import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taller_datos_abiertos/services/image_service.dart';

final _png = Uint8List.fromList([137, 80, 78, 71]);

http.Response _image() =>
    http.Response.bytes(_png, 200, headers: {'content-type': 'image/png'});

ImageService _serviceWith(MockClientHandler handler) => ImageService(
      client: MockClient(handler),
      retryDelay: Duration.zero,
    );

void main() {
  test('reintenta la misma URL ante 429 y luego obtiene la imagen', () async {
    final calls = <String>[];
    final service = _serviceWith((request) async {
      calls.add(request.url.toString());
      return calls.length < 3 ? http.Response('', 429) : _image();
    });

    final bytes = await service.load(['https://img/a.png', 'https://img/b.png']);

    expect(bytes, _png);
    expect(calls, everyElement('https://img/a.png'));
    expect(calls, hasLength(3));
  });

  test('ante un 400 pasa a la siguiente URL candidata', () async {
    final calls = <String>[];
    final service = _serviceWith((request) async {
      calls.add(request.url.path);
      return request.url.path == '/a.png' ? http.Response('', 400) : _image();
    });

    expect(await service.load(['https://img/a.png', 'https://img/b.png']), _png);
    expect(calls, ['/a.png', '/b.png']);
  });

  test('rechaza respuestas que no son imágenes', () async {
    final service = _serviceWith((_) async =>
        http.Response('<html>', 200, headers: {'content-type': 'text/html'}));

    expect(await service.load(['https://img/a.png']), isNull);
  });

  test('guarda en memoria las descargas exitosas', () async {
    var calls = 0;
    final service = _serviceWith((_) async {
      calls++;
      return _image();
    });

    await service.load(['https://img/a.png']);
    await service.load(['https://img/a.png']);

    expect(calls, 1);
  });

  test('no supera el máximo de descargas simultáneas', () async {
    var active = 0;
    var peak = 0;
    final service = ImageService(
      maxConcurrent: 2,
      client: MockClient((_) async {
        active++;
        peak = active > peak ? active : peak;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        active--;
        return _image();
      }),
    );

    await Future.wait([
      for (var i = 0; i < 6; i++) service.load(['https://img/$i.png']),
    ]);

    expect(peak, 2);
  });
}
