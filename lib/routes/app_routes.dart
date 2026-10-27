/// Nombres y rutas de la aplicación. Usar estas constantes en lugar de
/// escribir rutas a mano evita errores de tipeo al navegar.
class AppRoutes {
  AppRoutes._();

  // Nombres (para context.goNamed / context.pushNamed).
  static const String home = 'home';
  static const String departments = 'departments';
  static const String departmentDetail = 'department-detail';
  static const String presidents = 'presidents';
  static const String presidentDetail = 'president-detail';
  static const String attractions = 'attractions';
  static const String attractionDetail = 'attraction-detail';
  static const String dishes = 'dishes';
  static const String dishDetail = 'dish-detail';

  // Rutas.
  static const String homePath = '/';
  static const String departmentsPath = '/departments';
  static const String presidentsPath = '/presidents';
  static const String attractionsPath = '/attractions';
  static const String dishesPath = '/dishes';

  /// Parámetro de ruta con el identificador del registro.
  static const String idParam = 'id';

  static String departmentDetailPath(int id) => '$departmentsPath/$id';
  static String presidentDetailPath(int id) => '$presidentsPath/$id';
  static String attractionDetailPath(int id) => '$attractionsPath/$id';
  static String dishDetailPath(int id) => '$dishesPath/$id';
}
