import '../models/president.dart';
import 'api_client.dart';

/// Consumo del endpoint `/President`.
class PresidentService {
  static const String _path = '/President';
  final ApiClient _api;

  PresidentService([ApiClient? api]) : _api = api ?? ApiClient();

  Future<List<President>> getAll() => _api.getList(_path, President.fromJson);

  Future<President> getById(int id) =>
      _api.getOne('$_path/$id', President.fromJson);
}
