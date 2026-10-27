import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'config/env_config.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  runApp(TallerApp(router: createAppRouter()));
}

class TallerApp extends StatelessWidget {
  final GoRouter router;

  const TallerApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'API Colombia',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
