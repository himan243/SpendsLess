import '../../core/constants/categories.dart';
import '../../core/constants/payment_methods.dart';

class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.note,
    required this.spentAt,
  });

  final String id;
  final double amount;
  final ExpenseCategory category;
  final PaymentMethod paymentMethod;
  final String note;
  final DateTime spentAt;

  Expense copyWith({
    String? id,
    double? amount,
    ExpenseCategory? category,
    PaymentMethod? paymentMethod,
    String? note,
    DateTime? spentAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      spentAt: spentAt ?? this.spentAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category.name,
        'paymentMethod': paymentMethod.name,
        'note': note,
        'spentAt': spentAt.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.byName(json['category'] as String),
      paymentMethod:
          PaymentMethod.values.byName(json['paymentMethod'] as String),
      note: (json['note'] as String?) ?? '',
      spentAt: DateTime.parse(json['spentAt'] as String),
    );
  }
}