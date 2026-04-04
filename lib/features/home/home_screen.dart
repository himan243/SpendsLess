import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/payment_methods.dart';
import '../../core/extensions/date_ext.dart';
import '../../core/extensions/num_ext.dart';
import '../../core/utils/emoji_reactor.dart';
import '../../data/models/expense.dart';
import '../../data/spends_controller.dart';
import '../../shared/widgets/app_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(spendsControllerProvider);
    final controller = ref.read(spendsControllerProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final now = DateTime.now();
    final todayExpenses = state.expenses
        .where((expense) => expense.spentAt.isSameDay(now))
        .toList(growable: false);
    final todayTotal = todayExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final limit = state.settings.dailyLimit;
    final percent = limit <= 0 ? 0.0 : (todayTotal / limit) * 100;
    final reaction = budgetReactionFor(percent);

    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 118),
        children: [
          _HeaderCard(
            todayTotal: todayTotal,
            limit: limit,
            percent: percent,
            reaction: reaction,
            onEditLimit: () => _showLimitDialog(context, controller, limit),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TODAY',
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${todayExpenses.length} txn${todayExpenses.length == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (todayExpenses.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Column(
                children: [
                  Text('🫙', style: TextStyle(fontSize: 44)),
                  SizedBox(height: 8),
                  Text(
                    'No spending logged today',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          for (final expense in todayExpenses)
            _ExpenseTile(
              expense: expense,
              onDelete: () => _confirmDelete(context, controller, expense),
            )
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: 0.1, duration: 280.ms),
        ],
      ),
    );

    if (embedded) {
      return content;
    }

    return AppShell(
      currentIndex: 0,
      onHome: () => context.go('/'),
      onStats: () => context.go('/stats'),
      onAdd: () => context.push('/add'),
      onSettings: () => context.go('/settings'),
      child: content,
    );
  }

  Future<void> _showLimitDialog(
    BuildContext context,
    SpendsController controller,
    double currentLimit,
  ) async {
    final textController = TextEditingController(
      text: currentLimit.toStringAsFixed(0),
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Set daily limit (INR)'),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: '₹ '),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final limit = double.tryParse(textController.text.trim());
                if (limit == null || limit <= 0) {
                  return;
                }
                await controller.updateDailyLimit(limit);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SpendsController controller,
    Expense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Remove expense?'),
          content: Text(
            '${expense.amount.inRupees} • ${expense.category.label} • ${expense.spentAt.friendlyTime}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await controller.deleteExpense(expense.id);
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.todayTotal,
    required this.limit,
    required this.percent,
    required this.reaction,
    required this.onEditLimit,
  });

  final double todayTotal;
  final double limit;
  final double percent;
  final BudgetReaction reaction;
  final VoidCallback onEditLimit;

  @override
  Widget build(BuildContext context) {
    final capped = percent.clamp(0, 100).toDouble();
    final toneStrength = (capped / 100) * 0.72;
    final topTone = Color.lerp(
      const Color(0xFF171726),
      reaction.color.withValues(alpha: 0.34),
      toneStrength,
    )!;
    final bottomTone = Color.lerp(
      const Color(0xFF10101D),
      reaction.color.withValues(alpha: 0.22),
      toneStrength,
    )!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [topTone, bottomTone],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Limit',
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          limit.inRupees,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: onEditLimit,
                          icon: const Icon(Icons.edit_rounded),
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: todayTotal.inRupees,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(
                            text: ' spent today',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                reaction.emoji,
                style: const TextStyle(fontSize: 54),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .moveY(begin: -1, end: 3, duration: 1700.ms, curve: Curves.easeInOut)
                  .then()
                  .shake(hz: 0.35, duration: 1900.ms, rotation: 0.012),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reaction.message,
            style: TextStyle(color: reaction.color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: capped / 100,
              minHeight: 10,
              backgroundColor: Colors.white10,
              color: reaction.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.onDelete});

  final Expense expense;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = expense.category;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.amount.inRupees,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${category.label} • ${expense.paymentMethod.label} • ${expense.spentAt.friendlyTime}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                if (expense.note.isNotEmpty)
                  Text(
                    expense.note,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
