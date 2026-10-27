import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/attractions/attraction_detail_view.dart';
import '../views/attractions/attraction_list_view.dart';
import '../views/dashboard_view.dart';
import '../views/departments/department_detail_view.dart';
import '../views/departments/department_list_view.dart';
import '../views/dishes/dish_detail_view.dart';
import '../views/dishes/dish_list_view.dart';
import '../views/not_found_view.dart';
import '../views/presidents/president_detail_view.dart';
import '../views/presidents/president_list_view.dart';
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
        builder: (context, state) => const DashboardView(),
        routes: [
          _section(
            path: 'departments',
            name: AppRoutes.departments,
            detailName: AppRoutes.departmentDetail,
            list: const DepartmentListView(),
            detail: (id) => DepartmentDetailView(id: id),
          ),
          _section(
            path: 'presidents',
            name: AppRoutes.presidents,
            detailName: AppRoutes.presidentDetail,
            list: const PresidentListView(),
            detail: (id) => PresidentDetailView(id: id),
          ),
          _section(
            path: 'attractions',
            name: AppRoutes.attractions,
            detailName: AppRoutes.attractionDetail,
            list: const AttractionListView(),
            detail: (id) => AttractionDetailView(id: id),
          ),
          _section(
            path: 'dishes',
            name: AppRoutes.dishes,
            detailName: AppRoutes.dishDetail,
            list: const DishListView(),
            detail: (id) => DishDetailView(id: id),
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
