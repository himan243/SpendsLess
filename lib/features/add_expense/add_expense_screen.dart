import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/payment_methods.dart';
import '../../core/extensions/num_ext.dart';
import '../../data/spends_controller.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  int _step = 0;
  ExpenseCategory? _selectedCategory;
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final canStep1 = amount > 0;
    final canStep2 = _selectedCategory != null;
    final canSave = canStep1 && canStep2 && _selectedMethod != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Expense'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP ${_step + 1} OF 3',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _step
                            ? AppColors.accent
                            : AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: switch (_step) {
                  0 => _AmountStep(controller: _amountController),
                  1 => _CategoryStep(
                      selected: _selectedCategory,
                      onSelect: (value) => setState(() => _selectedCategory = value),
                    ),
                  _ => _MethodStep(
                      selectedMethod: _selectedMethod,
                      onSelectMethod: (value) =>
                          setState(() => _selectedMethod = value),
                      noteController: _noteController,
                      amount: amount,
                      category: _selectedCategory,
                    ),
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step -= 1),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: switch (_step) {
                        0 when canStep1 => () => setState(() => _step = 1),
                        1 when canStep2 => () => setState(() => _step = 2),
                        2 when canSave => _save,
                        _ => null,
                      },
                      child: Text(_step == 2 ? 'Log Expense' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim());
    final category = _selectedCategory;
    final method = _selectedMethod;

    if (amount == null || amount <= 0 || category == null || method == null) {
      return;
    }

    await ref.read(spendsControllerProvider.notifier).addExpense(
          amount: amount,
          category: category,
          paymentMethod: method,
          note: _noteController.text,
        );

    if (!mounted) {
      return;
    }

    context.go('/');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense logged successfully')),
    );
  }
}

class _AmountStep extends StatelessWidget {
  const _AmountStep({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final quick = [50, 100, 200, 500, 1000, 2000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How much did you spend?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
          decoration: const InputDecoration(
            prefixText: '₹ ',
            hintText: '0',
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final amount in quick)
              OutlinedButton(
                onPressed: () {
                  controller.text = amount.toString();
                },
                child: Text('₹$amount'),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({required this.selected, required this.onSelect});

  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.builder(
            itemCount: allExpenseCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final category = allExpenseCategories[index];
              final isSelected = category == selected;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(category),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withValues(alpha: 0.22)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? category.color : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 6),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              isSelected ? category.color : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    required this.selectedMethod,
    required this.onSelectMethod,
    required this.noteController,
    required this.amount,
    required this.category,
  });

  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod> onSelectMethod;
  final TextEditingController noteController;
  final double amount;
  final ExpenseCategory? category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How did you pay?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final method in allPaymentMethods)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelectMethod(method),
                    child: Ink(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedMethod == method
                            ? AppColors.accent.withValues(alpha: 0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedMethod == method
                              ? AppColors.accent
                              : AppColors.surfaceBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(method.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 4),
                          Text(
                            method.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: noteController,
          maxLength: 60,
          decoration: const InputDecoration(
            hintText: 'Optional note',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
          ),
          child: Text(
            '${amount.inRupees} • ${category?.label ?? '-'} • ${selectedMethod?.label ?? '-'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
