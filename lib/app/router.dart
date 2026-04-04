import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/add_expense/add_expense_screen.dart';
import '../features/main/main_tabs_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: MainTabsScreen(initialIndex: 0),
      ),
    ),
    GoRoute(
      path: '/stats',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: MainTabsScreen(initialIndex: 1),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: MainTabsScreen(initialIndex: 2),
      ),
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