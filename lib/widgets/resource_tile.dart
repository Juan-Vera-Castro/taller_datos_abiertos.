import 'package:flutter/material.dart';

import 'app_network_image.dart';

/// Elemento de un listado: miniatura (o icono), título y subtítulo.
class ResourceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const ResourceTile({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl == null
                    ? Container(
                        width: 64,
                        height: 64,
                        color: accent.withValues(alpha: 0.15),
                        child: Icon(icon, color: accent),
                      )
                    : AppNetworkImage(
                        url: imageUrl,
                        width: 64,
                        height: 64,
                        placeholderIcon: icon,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
