import '../models/department.dart';
import 'api_client.dart';

/// Consumo del endpoint `/Department`.
class DepartmentService {
  static const String _path = '/Department';
  final ApiClient _api;

  DepartmentService([ApiClient? api]) : _api = api ?? ApiClient();

  Future<List<Department>> getAll() =>
      _api.getList(_path, Department.fromJson);

  Future<Department> getById(int id) =>
      _api.getOne('$_path/$id', Department.fromJson);
}
