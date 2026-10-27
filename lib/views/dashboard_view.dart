import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_sections.dart';
import '../themes/app_colors.dart';
import '../widgets/section_card.dart';

/// Pantalla de inicio: una card por cada endpoint consumido.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FlagStripe(),
                    const SizedBox(height: 16),
                    Text('API Colombia',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Explora datos abiertos de Colombia. Elige una categoría.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              // Retícula responsiva: 1 columna en teléfono, 2 desde 720 px.
              // Se usa Wrap para que cada card tome la altura de su contenido.
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final maxWidth = constraints.crossAxisExtent;
                  final columns = maxWidth >= 720 ? 2 : 1;
                  final width = (maxWidth - spacing * (columns - 1)) / columns;
                  return SliverToBoxAdapter(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final section in appSections)
                          SizedBox(
                            width: width,
                            child: SectionCard(
                              section: section,
                              onTap: () => context.goNamed(section.routeName),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagStripe extends StatelessWidget {
  const _FlagStripe();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: const SizedBox(
        width: 72,
        height: 8,
        child: Row(
          children: [
            Expanded(flex: 2, child: ColoredBox(color: AppColors.yellow)),
            Expanded(child: ColoredBox(color: AppColors.blue)),
            Expanded(child: ColoredBox(color: AppColors.red)),
          ],
        ),
      ),
    );
  }
}
