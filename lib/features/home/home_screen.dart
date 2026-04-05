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
import '../../data/models/user_settings.dart';
import '../../data/spends_controller.dart';
import '../../shared/widgets/app_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(spendsControllerProvider);
    final controller = ref.read(spendsControllerProvider.notifier);
    final displayName = state.settings.displayName.trim().isEmpty
        ? 'SpendsLess'
        : state.settings.displayName.trim();
    final avatarId = state.settings.avatarId;

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
    // Calculate daily limit based on mode
    final limit = state.settings.limitMode == LimitMode.monthly
        ? SpendsController.calculateDynamicDailyFromMonthly(
            monthlyLimit: state.settings.monthlyLimit,
            expenses: state.expenses,
            now: now,
          )
        : state.settings.dailyLimit;
    final percent = limit <= 0 ? 0.0 : (todayTotal / limit) * 100;
    final reaction = budgetReactionFor(percent);

    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 118),
        children: [
          _HomeTopBar(
            displayName: displayName,
            avatarId: avatarId,
            onProfileTap: () => _showProfileSheet(
              context,
              controller,
              displayName,
              avatarId,
            ),
          ),
          const SizedBox(height: 16),
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

  Future<void> _showProfileSheet(
    BuildContext context,
    SpendsController controller,
    String displayName,
    String avatarId,
  ) async {
    final nameController = TextEditingController(text: displayName);
    var selectedAvatar = avatarId;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 28,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _AvatarBadge(
                          name: nameController.text.trim().isEmpty
                              ? 'SpendsLess'
                              : nameController.text.trim(),
                          avatarId: selectedAvatar,
                          size: 54,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Changes save locally on this device.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Choose avatar',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final option in _avatarChoices)
                          _AvatarChoiceChip(
                            option: option,
                            selected: selectedAvatar == option.id,
                            onTap: () => setModalState(() {
                              selectedAvatar = option.id;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final nextName = nameController.text.trim();
                              if (nextName.isNotEmpty) {
                                await controller.updateDisplayName(nextName);
                              }
                              await controller.updateAvatarId(selectedAvatar);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
  }
}

class _AvatarOption {
  const _AvatarOption({required this.id, required this.emoji});

  final String id;
  final String emoji;
}

const _avatarChoices = <_AvatarOption>[
  _AvatarOption(id: 'spark', emoji: '✨'),
  _AvatarOption(id: 'fox', emoji: '🦊'),
  _AvatarOption(id: 'cat', emoji: '🐱'),
  _AvatarOption(id: 'robot', emoji: '🤖'),
  _AvatarOption(id: 'ninja', emoji: '🥷'),
  _AvatarOption(id: 'owl', emoji: '🦉'),
];

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.displayName,
    required this.avatarId,
    required this.onProfileTap,
  });

  final String displayName;
  final String avatarId;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SpendsLess',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track clean. Spend smarter.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _ProfileAvatarButton(
            displayName: displayName,
            avatarId: avatarId,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({
    required this.displayName,
    required this.avatarId,
    required this.onTap,
  });

  final String displayName;
  final String avatarId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: _AvatarBadge(name: displayName, avatarId: avatarId, size: 42),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.name,
    required this.avatarId,
    required this.size,
  });

  final String name;
  final String avatarId;
  final double size;

  int _seedFor(String value) {
    var seed = 0;
    for (final unit in value.codeUnits) {
      seed += unit;
    }
    return seed;
  }

  List<Color> _palette(String value) {
    final palettes = <List<Color>>[
      [AppColors.accent, AppColors.accentSecondary],
      [AppColors.success, const Color(0xFF22C55E)],
      [const Color(0xFF38BDF8), const Color(0xFF0EA5E9)],
      [const Color(0xFFF59E0B), const Color(0xFFF97316)],
      [const Color(0xFFEC4899), const Color(0xFFA855F7)],
    ];
    return palettes[_seedFor(value) % palettes.length];
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'SL';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _palette(name);
    String? avatar;
    for (final choice in _avatarChoices) {
      if (choice.id == avatarId) {
        avatar = choice.emoji;
        break;
      }
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colors.first.withValues(alpha: 0.98),
            colors.last.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.22),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
      ),
      child: Center(
        child: avatar == null
            ? Text(
                _initials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.4,
                ),
              )
            : Text(
                avatar,
                style: TextStyle(fontSize: size * 0.48),
              ),
      ),
    );
  }
}

class _AvatarChoiceChip extends StatelessWidget {
  const _AvatarChoiceChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _AvatarOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? AppColors.accent.withValues(alpha: 0.24)
                : AppColors.background,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.surfaceBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(option.emoji, style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
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
