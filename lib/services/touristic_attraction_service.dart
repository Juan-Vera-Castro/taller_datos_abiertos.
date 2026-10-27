import '../models/touristic_attraction.dart';
import 'api_client.dart';

/// Consumo del endpoint `/TouristicAttraction`.
class TouristicAttractionService {
  static const String _path = '/TouristicAttraction';
  final ApiClient _api;

  TouristicAttractionService([ApiClient? api]) : _api = api ?? ApiClient();

  Future<List<TouristicAttraction>> getAll() =>
      _api.getList(_path, TouristicAttraction.fromJson);

  Future<TouristicAttraction> getById(int id) =>
      _api.getOne('$_path/$id', TouristicAttraction.fromJson);
}
