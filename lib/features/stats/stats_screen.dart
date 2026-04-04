import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/categories.dart';
import '../../core/extensions/date_ext.dart';
import '../../core/extensions/num_ext.dart';
import '../../data/spends_controller.dart';
import '../../shared/widgets/app_shell.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  bool _isMonth = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spendsControllerProvider);
    final now = DateTime.now();

    final active = state.expenses.where((expense) {
      if (_isMonth) {
        return expense.spentAt.isSameMonth(now);
      }
      return expense.spentAt.isSameYear(now);
    }).toList(growable: false);

    final total = active.fold<double>(0, (sum, expense) => sum + expense.amount);

    final byCategory = {
      for (final category in allExpenseCategories)
        category: active
            .where((expense) => expense.category == category)
            .fold<double>(0, (sum, expense) => sum + expense.amount),
    };

    final categories = byCategory.entries.where((entry) => entry.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final monthlyTotals = List<double>.generate(12, (index) {
      final month = index + 1;
      return state.expenses
          .where((expense) =>
              expense.spentAt.year == now.year && expense.spentAt.month == month)
          .fold<double>(0, (sum, expense) => sum + expense.amount);
    });

    final monthMax = monthlyTotals.fold<double>(1, (max, value) => value > max ? value : max);

    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ToggleButton(
                selected: _isMonth,
                label: 'This Month',
                onTap: () => setState(() => _isMonth = true),
              ),
              const SizedBox(width: 8),
              _ToggleButton(
                selected: !_isMonth,
                label: 'This Year',
                onTap: () => setState(() => _isMonth = false),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total spent',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  total.inRupees,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                          final index = value.toInt();
                          if (index < 0 || index > 11) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            labels[index],
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(
                    12,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: monthMax == 0 ? 0 : monthlyTotals[index] / monthMax,
                          borderRadius: BorderRadius.circular(99),
                          width: 12,
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentSecondary],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    ),
                  ),
                  maxY: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'By Category',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (categories.isEmpty)
                  const Text(
                    'No data in this range yet',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                for (final entry in categories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(entry.key.emoji),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          entry.value.inRupees,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return AppShell(
      currentIndex: 1,
      onHome: () => context.go('/'),
      onStats: () => context.go('/stats'),
      onAdd: () => context.push('/add'),
      onSettings: () => context.go('/settings'),
      child: content,
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.2)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.surfaceBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: child,
    );
  }
}
