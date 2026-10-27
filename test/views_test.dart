import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taller_datos_abiertos/main.dart';
import 'package:taller_datos_abiertos/routes/app_router.dart';
import 'package:taller_datos_abiertos/services/services.dart';
import 'package:taller_datos_abiertos/views/departments/department_detail_view.dart';
import 'package:taller_datos_abiertos/views/departments/department_list_view.dart';
import 'package:taller_datos_abiertos/widgets/app_network_image.dart';
import 'package:taller_datos_abiertos/widgets/error_view.dart';
import 'package:taller_datos_abiertos/widgets/formatters.dart';
import 'package:taller_datos_abiertos/widgets/loader.dart';

const _departments = [
  {
    'id': 2,
    'name': 'Antioquia',
    'description': 'Departamento del noroccidente',
    'municipalities': 125,
    'surface': 63612,
    'population': 6887306,
    'phonePrefix': '4',
    'cityCapital': {'id': 12, 'name': 'Medellín', 'description': ''},
  },
  {
    'id': 3,
    'name': 'Arauca',
    'description': 'Departamento de la Orinoquía',
    'population': 304978,
    'cityCapital': {
      'id': 143,
      'name': 'Arauca',
      'description': 'Capital del departamento',
      'postalCode': '810001',
    },
  },
];

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
    utf8.encode(jsonEncode(body)), status,
    headers: {'content-type': 'application/json'});

DepartmentService _serviceWith(MockClientHandler handler) => DepartmentService(
    ApiClient(client: MockClient(handler), baseUrl: 'https://test/api/v1'));

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('Listado', () {
    testWidgets('muestra cargando y luego la lista', (tester) async {
      final response = Completer<http.Response>();
      await tester.pumpWidget(_wrap(DepartmentListView(
          service: _serviceWith((_) => response.future))));

      expect(find.byType(ListSkeleton), findsOneWidget);

      response.complete(_json(_departments));
      await tester.pumpAndSettle();

      expect(find.byType(ListSkeleton), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Antioquia'), findsOneWidget);
      expect(find.textContaining('Capital: Medellín'), findsOneWidget);
      expect(find.text('2 de 2 registros'), findsOneWidget);
    });

    testWidgets('muestra error y se recupera al reintentar', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_wrap(DepartmentListView(
          service: _serviceWith((_) async =>
              ++calls == 1 ? http.Response('boom', 500) : _json(_departments)))));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.textContaining('(500)'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Arauca'), findsOneWidget);
    });

    testWidgets('la búsqueda ignora tildes y mayúsculas', (tester) async {
      await tester.pumpWidget(_wrap(DepartmentListView(
          service: _serviceWith((_) async => _json(_departments)))));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'MEDELLIN');
      await tester.pump();

      expect(find.text('Antioquia'), findsOneWidget);
      expect(find.text('Arauca'), findsNothing);
      expect(find.text('1 de 2 registros'), findsOneWidget);
    });
  });

  group('Detalle', () {
    testWidgets('pide el registro por id y muestra toda la información',
        (tester) async {
      late Uri requested;
      await tester.pumpWidget(_wrap(DepartmentDetailView(
        id: 3,
        service: _serviceWith((request) async {
          requested = request.url;
          return _json(_departments[1]);
        }),
      )));
      await tester.pumpAndSettle();

      expect(requested.path, '/api/v1/Department/3');
      expect(find.text('Arauca'), findsOneWidget);
      expect(find.text('304.978 habitantes'), findsOneWidget);
      expect(find.text('Capital: Arauca'), findsOneWidget);
      expect(find.text('810001'), findsOneWidget);
    });

    testWidgets('un id inexistente muestra el error', (tester) async {
      await tester.pumpWidget(_wrap(DepartmentDetailView(
          id: 999,
          service: _serviceWith((_) async => http.Response('', 404)))));
      await tester.pumpAndSettle();

      expect(find.text('El registro solicitado no existe.'), findsOneWidget);
    });
  });

  testWidgets('el dashboard muestra 4 cards y navega al listado',
      (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(TallerApp(router: router));
    await tester.pumpAndSettle();

    for (final title in [
      'Departamentos',
      'Presidentes',
      'Atractivos turísticos',
      'Platos típicos'
    ]) {
      expect(find.text(title), findsOneWidget);
    }

    await tester.tap(find.text('Presidentes'));
    await tester.pump();
    expect(router.state.uri.toString(), '/presidents');
  });

  group('AppNetworkImage.candidatesFor', () {
    test('reescribe miniaturas de Wikimedia a un ancho estándar', () {
      const url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/'
          'Foto.JPG/800px-Foto.JPG';
      expect(AppNetworkImage.candidatesFor(url, 960), [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Foto.JPG/960px-Foto.JPG',
        url,
        'https://upload.wikimedia.org/wikipedia/commons/4/4a/Foto.JPG',
      ]);
    });

    test('genera miniatura para originales de Wikimedia', () {
      const url =
          'https://upload.wikimedia.org/wikipedia/commons/d/db/Rafael_Nunez.JPG';
      expect(AppNetworkImage.candidatesFor(url, 330).first,
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Rafael_Nunez.JPG/330px-Rafael_Nunez.JPG');
    });

    test('codifica espacios y descarta textos que no son URL', () {
      expect(
          AppNetworkImage.candidatesFor(
              'https://host.net/platos/1. Bandeja Paisa.jpg', 330),
          ['https://host.net/platos/1.%20Bandeja%20Paisa.jpg']);
      expect(
          AppNetworkImage.candidatesFor('Centro_Histórico_2.JPG (1280×960)', 330),
          isEmpty);
      expect(AppNetworkImage.candidatesFor(null, 330), isEmpty);
    });
  });

  test('Formatters', () {
    expect(Formatters.number(6887306), '6.887.306');
    expect(Formatters.number(125), '125');
    expect(Formatters.number(null), 'Sin dato');
    expect(Formatters.date('1887-06-04'), '4 jun 1887');
    expect(Formatters.date(null), 'Actualidad');
  });
}
