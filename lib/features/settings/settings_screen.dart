import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/extensions/num_ext.dart';
import '../../data/models/user_settings.dart';
import '../../data/spends_controller.dart';
import '../../shared/widgets/app_shell.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  bool _didInitControllers = false;
  late bool _isMonthlyMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitControllers) {
      return;
    }
    final state = ref.read(spendsControllerProvider);
    _nameController.text = state.settings.displayName;
    _isMonthlyMode = state.settings.limitMode == LimitMode.monthly;
    final limitValue =
        _isMonthlyMode ? state.settings.monthlyLimit : state.settings.dailyLimit;
    _limitController.text = limitValue.toStringAsFixed(0);
    _didInitControllers = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spendsControllerProvider);
    final controller = ref.read(spendsControllerProvider.notifier);
    final currentDailyLimit = state.settings.limitMode == LimitMode.monthly
        ? SpendsController.calculateDynamicDailyFromMonthly(
            monthlyLimit: state.settings.monthlyLimit,
            expenses: state.expenses,
          )
        : state.settings.dailyLimit;

    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Name',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                TextField(controller: _nameController),
                const SizedBox(height: 14),
                const Text(
                  'Budget Mode',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        selected: {_isMonthlyMode},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _isMonthlyMode = selection.first;
                            final settings = ref.read(spendsControllerProvider).settings;
                            final limitValue = _isMonthlyMode
                                ? settings.monthlyLimit
                                : settings.dailyLimit;
                            _limitController.text = limitValue.toStringAsFixed(0);
                          });
                        },
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Daily'),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Monthly'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _isMonthlyMode ? 'Monthly Limit (INR)' : 'Daily Limit (INR)',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(prefixText: '₹ '),
                ),
                const SizedBox(height: 14),
                Text(
                  'Current: ${currentDailyLimit.inRupees}/day',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () async {
                    final nextLimit =
                        double.tryParse(_limitController.text.trim()) ?? 0;
                    if (nextLimit > 0) {
                      if (_isMonthlyMode) {
                        await controller.updateMonthlyLimit(nextLimit);
                      } else {
                        await controller.updateDailyLimit(nextLimit);
                      }
                    }
                    await controller.updateDisplayName(_nameController.text);
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings updated')),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Currency',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: const Text(
                    'INR (₹)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danger Zone',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _confirmReset(context, controller),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Reset all local data'),
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
      currentIndex: 2,
      onHome: () => context.go('/'),
      onStats: () => context.go('/stats'),
      onAdd: () => context.push('/add'),
      onSettings: () => context.go('/settings'),
      child: content,
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    SpendsController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset app data?'),
        content: const Text('This will remove all local expenses and settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await controller.clearAll();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data reset complete')),
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
