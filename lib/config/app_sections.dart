import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../themes/app_colors.dart';

/// Describe cada endpoint consumido, tal como se muestra en el dashboard.
class AppSection {
  final String title;
  final String description;
  final String endpoint;
  final IconData icon;
  final Color color;
  final String routeName;

  const AppSection({
    required this.title,
    required this.description,
    required this.endpoint,
    required this.icon,
    required this.color,
    required this.routeName,
  });
}

const List<AppSection> appSections = [
  AppSection(
    title: 'Departamentos',
    description: 'Los 32 departamentos: capital, población y superficie.',
    endpoint: '/Department',
    icon: Icons.map_outlined,
    color: AppColors.departments,
    routeName: AppRoutes.departments,
  ),
  AppSection(
    title: 'Presidentes',
    description: 'Quienes han gobernado Colombia y sus periodos.',
    endpoint: '/President',
    icon: Icons.account_balance_outlined,
    color: AppColors.presidents,
    routeName: AppRoutes.presidents,
  ),
  AppSection(
    title: 'Atractivos turísticos',
    description: 'Lugares emblemáticos para visitar en el país.',
    endpoint: '/TouristicAttraction',
    icon: Icons.landscape_outlined,
    color: AppColors.attractions,
    routeName: AppRoutes.attractions,
  ),
  AppSection(
    title: 'Platos típicos',
    description: 'Gastronomía tradicional de cada región.',
    endpoint: '/TypicalDish',
    icon: Icons.restaurant_menu,
    color: AppColors.dishes,
    routeName: AppRoutes.dishes,
  ),
];
