import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  delivery,
  travel,
  shopping,
  entertainment,
  health,
  bills,
  other,
}

extension ExpenseCategoryMeta on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.food => 'Food',
        ExpenseCategory.delivery => 'Fare',
        ExpenseCategory.travel => 'Travel',
        ExpenseCategory.shopping => 'Shopping',
        ExpenseCategory.entertainment => 'Entertainment',
        ExpenseCategory.health => 'Health',
        ExpenseCategory.bills => 'Bills',
        ExpenseCategory.other => 'Other',
      };

  String get emoji => switch (this) {
        ExpenseCategory.food => '🍔',
        ExpenseCategory.delivery => '🛵',
        ExpenseCategory.travel => '✈️',
        ExpenseCategory.shopping => '🛍️',
        ExpenseCategory.entertainment => '🎮',
        ExpenseCategory.health => '💊',
        ExpenseCategory.bills => '💡',
        ExpenseCategory.other => '✨',
      };

  Color get color => switch (this) {
        ExpenseCategory.food => const Color(0xFFFF6B6B),
        ExpenseCategory.delivery => const Color(0xFFFF8A65),
        ExpenseCategory.travel => const Color(0xFF64B5F6),
        ExpenseCategory.shopping => const Color(0xFFCE93D8),
        ExpenseCategory.entertainment => const Color(0xFF4DB6AC),
        ExpenseCategory.health => const Color(0xFF81C784),
        ExpenseCategory.bills => const Color(0xFFFFD54F),
        ExpenseCategory.other => const Color(0xFFF06292),
      };
}

const allExpenseCategories = ExpenseCategory.values;