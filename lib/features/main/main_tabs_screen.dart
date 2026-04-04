import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_shell.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant MainTabsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _currentIndex = widget.initialIndex;
      _pageController.jumpToPage(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    if (_currentIndex == index) {
      return;
    }
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: _currentIndex,
      onHome: () => _jumpTo(0),
      onStats: () => _jumpTo(1),
      onAdd: () => context.push('/add'),
      onSettings: () => _jumpTo(2),
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [
          HomeScreen(embedded: true),
          StatsScreen(embedded: true),
          SettingsScreen(embedded: true),
        ],
      ),
    );
  }
}
