import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/add_expense/add_expense_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/add',
      pageBuilder: (context, state) => const MaterialPage<void>(
        fullscreenDialog: true,
        child: AddExpenseScreen(),
      ),
    ),
  ],
);