import 'package:flutter/material.dart';

import '../widgets/async_state_builder.dart';
import '../widgets/error_view.dart';
import '../widgets/loader.dart';

/// Listado genérico de un endpoint: hace la petición GET con [loader] y
/// muestra los estados de carga, error y éxito (con búsqueda local y
/// "deslizar para actualizar").
class ResourceListView<T> extends StatelessWidget {
  final String title;
  final Future<List<T>> Function() loader;
  final String Function(T item) searchText;
  final Widget Function(BuildContext context, T item) itemBuilder;

  const ResourceListView({
    super.key,
    required this.title,
    required this.loader,
    required this.searchText,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AsyncStateBuilder<List<T>>(
        loader: loader,
        loading: const ListSkeleton(),
        builder: (context, items, refresh) => _FilterableList<T>(
          items: items,
          searchText: searchText,
          itemBuilder: itemBuilder,
          onRefresh: refresh,
        ),
      ),
    );
  }
}

class _FilterableList<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) searchText;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;

  const _FilterableList({
    required this.items,
    required this.searchText,
    required this.itemBuilder,
    required this.onRefresh,
  });

  @override
  State<_FilterableList<T>> createState() => _FilterableListState<T>();
}

class _FilterableListState<T> extends State<_FilterableList<T>> {
  String _query = '';

  List<T> get _visible {
    final query = _normalize(_query);
    if (query.isEmpty) return widget.items;
    return widget.items
        .where((item) => _normalize(widget.searchText(item)).contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: visible.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _header(visible.length);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: widget.itemBuilder(context, visible[index - 1]),
          );
        },
      ),
    );
  }

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar…',
            ),
          ),
          const SizedBox(height: 8),
          Text('$count de ${widget.items.length} registros',
              style: Theme.of(context).textTheme.labelMedium),
          if (count == 0)
            const EmptyView(message: 'No hay registros que coincidan.'),
        ],
      ),
    );
  }

  /// Minúsculas y sin tildes, para que "bogota" encuentre "Bogotá".
  static String _normalize(String value) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    var result = value.toLowerCase().trim();
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }
}
