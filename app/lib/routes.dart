import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

class RouteGenerator {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case home:
        return MaterialPageRoute(builder: (ctx) {
          final scope = AppScope.of(ctx);
          if (scope == null || scope.engine == null || scope.db == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return HomeScreen(engine: scope.engine!, db: scope.db!);
        });
      default:
        throw FormatException('Route not found: ${settings.name}');
    }
  }
}
