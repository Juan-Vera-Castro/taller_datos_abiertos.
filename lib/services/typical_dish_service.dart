import '../models/typical_dish.dart';
import 'api_client.dart';

/// Consumo del endpoint `/TypicalDish`.
class TypicalDishService {
  static const String _path = '/TypicalDish';
  final ApiClient _api;

  TypicalDishService([ApiClient? api]) : _api = api ?? ApiClient();

  Future<List<TypicalDish>> getAll() =>
      _api.getList(_path, TypicalDish.fromJson);

  Future<TypicalDish> getById(int id) =>
      _api.getOne('$_path/$id', TypicalDish.fromJson);
}
