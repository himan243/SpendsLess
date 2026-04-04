import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.onHome,
    required this.onStats,
    required this.onAdd,
    required this.onSettings,
  });

  final int currentIndex;
  final Widget child;
  final VoidCallback onHome;
  final VoidCallback onStats;
  final VoidCallback onAdd;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 132,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _NavButton(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          selected: currentIndex == 0,
                          onTap: onHome,
                        ),
                      ),
                      Expanded(
                        child: _NavButton(
                          icon: Icons.bar_chart_rounded,
                          label: 'Stats',
                          selected: currentIndex == 1,
                          onTap: onStats,
                        ),
                      ),
                      Expanded(
                        child: _NavButton(
                          icon: Icons.tune_rounded,
                          label: 'Settings',
                          selected: currentIndex == 2,
                          onTap: onSettings,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 96,
                child: _AddButton(onTap: onAdd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary : AppColors.textMuted;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      offset: selected ? const Offset(0, -0.04) : Offset.zero,
      curve: Curves.easeOutCubic,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: selected
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.55))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: selected ? 23 : 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.accentSecondary],
          ),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x667C6BFF),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
          border: Border.all(color: const Color(0x7AFFFFFF)),
        ),
        child: const Center(
          child: Icon(Icons.add_rounded, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}