import 'package:flutter/material.dart';

/// Imagen remota con imagen de respaldo. Si una URL falla prueba la
/// siguiente alternativa y, al agotarlas, muestra [placeholderIcon].
class AppNetworkImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Ancho solicitado a Wikimedia para las miniaturas.
  final int targetWidth;
  final IconData placeholderIcon;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.targetWidth = 330,
    this.placeholderIcon = Icons.image_outlined,
  });

  /// Wikimedia exige un User-Agent identificable.
  static const Map<String, String> _headers = {
    'User-Agent': 'TallerDatosAbiertos/1.0 (Flutter; proyecto educativo)',
  };

  static final RegExp _thumbWidth = RegExp(r'/\d+px-');
  static final RegExp _wikimediaOriginal = RegExp(
      r'^(https://upload\.wikimedia\.org/wikipedia/[\w-]+)/([0-9a-f])/([0-9a-f]{2})/([^/]+)$');
  static final RegExp _wikimediaThumb = RegExp(r'/thumb/(.+)/\d+px-[^/]+$');

  /// URLs a intentar, en orden. Wikimedia solo sirve miniaturas en anchos
  /// estándar, por eso se reescribe el ancho y se deja la original de respaldo.
  static List<String> candidatesFor(String? raw, int width) {
    final url = raw?.trim().replaceAll(' ', '%20') ?? '';
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
      return const [];
    }

    final candidates = <String>[];
    if (uri.host == 'upload.wikimedia.org') {
      if (url.contains('/thumb/')) {
        candidates.add(url.replaceFirst(_thumbWidth, '/${width}px-'));
        candidates.add(url);
        candidates.add(url.replaceFirstMapped(
            _wikimediaThumb, (m) => '/${m[1]}'));
      } else {
        final m = _wikimediaOriginal.firstMatch(url);
        if (m != null && !m[4]!.toLowerCase().endsWith('.svg')) {
          candidates.add(
              '${m[1]}/thumb/${m[2]}/${m[3]}/${m[4]}/${width}px-${m[4]}');
        }
        candidates.add(url);
      }
    } else {
      candidates.add(url);
    }
    return candidates.toSet().toList();
  }

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  late List<String> _candidates;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _candidates = AppNetworkImage.candidatesFor(widget.url, widget.targetWidth);
  }

  @override
  void didUpdateWidget(AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.targetWidth != widget.targetWidth) {
      _candidates =
          AppNetworkImage.candidatesFor(widget.url, widget.targetWidth);
      _index = 0;
    }
  }

  void _tryNext(int failedIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _index == failedIndex) setState(() => _index++);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= _candidates.length) return _placeholder(context);

    final index = _index;
    return Image.network(
      _candidates[index],
      key: ValueKey(_candidates[index]),
      headers: AppNetworkImage._headers,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(context, loading: true),
      errorBuilder: (context, error, stackTrace) {
        _tryNext(index);
        return _placeholder(context);
      },
    );
  }

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: widget.width,
      height: widget.height,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.placeholderIcon, color: scheme.onSurfaceVariant),
    );
  }
}
