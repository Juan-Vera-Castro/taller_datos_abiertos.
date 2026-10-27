import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/not_found_view.dart';
import 'app_routes.dart';

typedef _DetailBuilder = Widget Function(int id);

/// Crea el router de la aplicación. Se expone como función para poder
/// instanciarlo con otra ruta inicial en las pruebas.
GoRouter createAppRouter({String initialLocation = AppRoutes.homePath}) {
  return GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (context, state) =>
        NotFoundView(message: 'La ruta "${state.uri}" no existe.'),
    routes: [
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const _PendingView('Dashboard'),
        routes: [
          _section(
            path: 'departments',
            name: AppRoutes.departments,
            detailName: AppRoutes.departmentDetail,
            list: const _PendingView('Departamentos'),
            detail: (id) => _PendingView('Departamento $id'),
          ),
          _section(
            path: 'presidents',
            name: AppRoutes.presidents,
            detailName: AppRoutes.presidentDetail,
            list: const _PendingView('Presidentes'),
            detail: (id) => _PendingView('Presidente $id'),
          ),
          _section(
            path: 'attractions',
            name: AppRoutes.attractions,
            detailName: AppRoutes.attractionDetail,
            list: const _PendingView('Atractivos turísticos'),
            detail: (id) => _PendingView('Atractivo $id'),
          ),
          _section(
            path: 'dishes',
            name: AppRoutes.dishes,
            detailName: AppRoutes.dishDetail,
            list: const _PendingView('Platos típicos'),
            detail: (id) => _PendingView('Plato $id'),
          ),
        ],
      ),
    ],
  );
}

/// Ruta de listado con su ruta hija de detalle `:id` (patrón maestro-detalle).
GoRoute _section({
  required String path,
  required String name,
  required String detailName,
  required Widget list,
  required _DetailBuilder detail,
}) {
  return GoRoute(
    path: path,
    name: name,
    builder: (context, state) => list,
    routes: [
      GoRoute(
        path: ':${AppRoutes.idParam}',
        name: detailName,
        builder: (context, state) {
          final id = int.tryParse(
              state.pathParameters[AppRoutes.idParam] ?? '');
          if (id == null) {
            return const NotFoundView(
                message: 'El identificador del registro no es válido.');
          }
          return detail(id);
        },
      ),
    ],
  );
}

// TODO(paso-7): reemplazar por las vistas reales de Dashboard, Listado y Detalle.
class _PendingView extends StatelessWidget {
  final String title;

  const _PendingView(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
