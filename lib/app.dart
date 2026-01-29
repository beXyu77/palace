// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'ui/screens/start_screen.dart';
import 'ui/screens/create_run_screen.dart';
import 'ui/screens/loop_screen.dart';
import 'ui/screens/month_end_screen.dart';
import 'ui/screens/ending_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const StartScreen()),
    GoRoute(
      path: '/create',
      builder: (context, state) {
        final extra = state.extra;
        final openingStyle = (extra is Map && extra['openingStyle'] is String)
            ? extra['openingStyle'] as String
            : 'balanced';

        return CreateRunScreen(openingStyle: openingStyle);
      },
    ),

    GoRoute(path: '/loop', builder: (context, state) => const LoopScreen()),
    GoRoute(path: '/monthEnd', builder: (context, state) => const MonthEndScreen()),
    GoRoute(path: '/ending', builder: (context, state) => const EndingScreen()),
  ],
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
