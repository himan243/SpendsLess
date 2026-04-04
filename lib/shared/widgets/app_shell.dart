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
      body: Stack(
        children: [
          const _AppBackdrop(),
          Positioned.fill(child: child),
        ],
      ),
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

class _AppBackdrop extends StatefulWidget {
  const _AppBackdrop();

  @override
  State<_AppBackdrop> createState() => _AppBackdropState();
}

class _AppBackdropState extends State<_AppBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF08080F), Color(0xFF0B0B16), Color(0xFF08080F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -70 + (t * 18),
                left: -48 + (t * 22),
                child: _GlowBlob(
                  size: 170,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    AppColors.accentSecondary.withValues(alpha: 0.04),
                  ],
                ),
              ),
              Positioned(
                top: 120 + (t * -12),
                right: -60 + (t * 16),
                child: _GlowBlob(
                  size: 220,
                  colors: [
                    AppColors.success.withValues(alpha: 0.10),
                    AppColors.accent.withValues(alpha: 0.03),
                  ],
                ),
              ),
              Positioned(
                bottom: 90 + (t * 18),
                left: 24 + (t * -10),
                child: _GlowBlob(
                  size: 140,
                  colors: [
                    AppColors.warning.withValues(alpha: 0.10),
                    AppColors.accentSecondary.withValues(alpha: 0.02),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.07,
                    child: CustomPaint(
                      painter: _GridPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors.first,
            blurRadius: 60,
            spreadRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 0.7;

    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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