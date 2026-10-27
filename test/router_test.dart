import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_datos_abiertos/main.dart';
import 'package:taller_datos_abiertos/routes/app_router.dart';
import 'package:taller_datos_abiertos/routes/app_routes.dart';
import 'package:taller_datos_abiertos/views/not_found_view.dart';

Future<GoRouter> _pumpApp(WidgetTester tester, String location) async {
  final router = createAppRouter(initialLocation: location);
  await tester.pumpWidget(TallerApp(router: router));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  test('las rutas de detalle se construyen con el id', () {
    expect(AppRoutes.departmentDetailPath(5), '/departments/5');
    expect(AppRoutes.presidentDetailPath(3), '/presidents/3');
    expect(AppRoutes.attractionDetailPath(36), '/attractions/36');
    expect(AppRoutes.dishDetailPath(1), '/dishes/1');
  });

  testWidgets('la ruta inicial es el dashboard', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.homePath);
    expect(router.state.name, AppRoutes.home);
  });

  testWidgets('navega por nombre al detalle con el parámetro id',
      (tester) async {
    final router = await _pumpApp(tester, AppRoutes.homePath);

    router.goNamed(AppRoutes.presidentDetail,
        pathParameters: {AppRoutes.idParam: '3'});
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '/presidents/3');
    expect(router.state.pathParameters[AppRoutes.idParam], '3');
  });

  for (final path in ['/departments', '/presidents', '/attractions', '/dishes']) {
    testWidgets('la ruta $path existe y su detalle también', (tester) async {
      final router = await _pumpApp(tester, path);
      expect(find.byType(NotFoundView), findsNothing);

      router.go('$path/1');
      await tester.pumpAndSettle();
      expect(find.byType(NotFoundView), findsNothing);
    });
  }

  testWidgets('un id no numérico muestra NotFoundView', (tester) async {
    await _pumpApp(tester, '/dishes/abc');
    expect(find.byType(NotFoundView), findsOneWidget);
  });

  testWidgets('una ruta desconocida muestra NotFoundView', (tester) async {
    await _pumpApp(tester, '/no-existe');
    expect(find.byType(NotFoundView), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Ir al inicio'));
    await tester.pumpAndSettle();
    expect(find.byType(NotFoundView), findsNothing);
  });
}
