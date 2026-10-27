import 'package:flutter/material.dart';

import '../services/api_exception.dart';
import 'error_view.dart';
import 'loader.dart';

typedef AsyncDataBuilder<T> = Widget Function(
    BuildContext context, T data, Future<void> Function() refresh);

/// Ejecuta [loader] y pinta explícitamente los tres estados:
/// cargando ([loading]), error ([ErrorView] con reintentar) y éxito ([builder]).
class AsyncStateBuilder<T> extends StatefulWidget {
  final Future<T> Function() loader;
  final AsyncDataBuilder<T> builder;
  final Widget loading;

  const AsyncStateBuilder({
    super.key,
    required this.loader,
    required this.builder,
    this.loading = const Loader(),
  });

  @override
  State<AsyncStateBuilder<T>> createState() => _AsyncStateBuilderState<T>();
}

class _AsyncStateBuilderState<T> extends State<AsyncStateBuilder<T>> {
  late Future<T> _future = widget.loader();

  void _retry() {
    setState(() {
      _future = widget.loader();
    });
  }

  /// Recarga conservando los datos actuales en pantalla mientras llega la
  /// respuesta (usado por el "deslizar para actualizar").
  Future<void> _refresh() async {
    final future = widget.loader();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {
      // El error se muestra con ErrorView a través del FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError &&
            snapshot.connectionState == ConnectionState.done) {
          return ErrorView(
            message: _messageFor(snapshot.error),
            onRetry: _retry,
          );
        }
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data as T, _refresh);
        }
        return widget.loading;
      },
    );
  }

  String _messageFor(Object? error) => error is ApiException
      ? error.message
      : 'Ocurrió un error inesperado al cargar la información.';
}
