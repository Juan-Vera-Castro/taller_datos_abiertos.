import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/typical_dish.dart';
import '../../routes/app_routes.dart';
import '../../services/typical_dish_service.dart';
import '../../themes/app_colors.dart';
import '../../widgets/resource_tile.dart';
import '../resource_list_view.dart';

class DishListView extends StatelessWidget {
  final TypicalDishService? service;

  const DishListView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service ?? TypicalDishService();
    return ResourceListView<TypicalDish>(
      title: 'Platos típicos',
      loader: () async =>
          (await service.getAll())..sort((a, b) => a.name.compareTo(b.name)),
      searchText: (d) =>
          '${d.name} ${d.department?.name ?? ''} ${d.ingredients}',
      itemBuilder: (context, d) => ResourceTile(
        title: d.name,
        subtitle: d.department?.name,
        imageUrl: d.imageUrl,
        icon: Icons.restaurant_menu,
        color: AppColors.dishes,
        onTap: () => context.goNamed(
          AppRoutes.dishDetail,
          pathParameters: {AppRoutes.idParam: '${d.id}'},
        ),
      ),
    );
  }
}
