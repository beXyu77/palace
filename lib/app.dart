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

/// ✅ 全局 NavigatorKey（给弹窗用）
final GlobalKey<NavigatorState> rootNavigatorKey =
GlobalKey<NavigatorState>();

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      navigatorKey: rootNavigatorKey, // ✅ 正确位置在这里
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const StartScreen(),
        ),
        GoRoute(
          path: '/create',
          builder: (context, state) => const CreateRunScreen(),
        ),
        GoRoute(
          path: '/loop',
          builder: (context, state) => const LoopScreen(),
        ),
        GoRoute(
          path: '/monthEnd',
          builder: (context, state) => const MonthEndScreen(),
        ),
        GoRoute(
          path: '/ending',
          builder: (context, state) => const EndingScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router, // ✅ 不再写 navigatorKey
    );
  }
}
