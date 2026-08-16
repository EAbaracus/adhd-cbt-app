import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AdhdCbtApp());
}

class AdhdCbtApp extends StatelessWidget {
  const AdhdCbtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADHD CBT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: RouteGenerator.onboarding,
    );
  }
}
