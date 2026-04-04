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
    this.userId,
    this.deviceId,
    this.version = 1,
    required this.updatedAt,
    this.deletedAt,
    this.pendingSync = false,
  });

  final String id;
  final double amount;
  final ExpenseCategory category;
  final PaymentMethod paymentMethod;
  final String note;
  final DateTime spentAt;
  final String? userId;
  final String? deviceId;
  final int version;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendingSync;

  Expense copyWith({
    String? id,
    double? amount,
    ExpenseCategory? category,
    PaymentMethod? paymentMethod,
    String? note,
    DateTime? spentAt,
    String? userId,
    String? deviceId,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? pendingSync,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      spentAt: spentAt ?? this.spentAt,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category.name,
        'paymentMethod': paymentMethod.name,
        'note': note,
        'spentAt': spentAt.toIso8601String(),
        'userId': userId,
        'deviceId': deviceId,
        'version': version,
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'pendingSync': pendingSync,
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
      userId: json['userId'] as String?,
      deviceId: json['deviceId'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      updatedAt: DateTime.parse(
        (json['updatedAt'] as String?) ?? (json['spentAt'] as String),
      ),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      pendingSync: (json['pendingSync'] as bool?) ?? false,
    );
  }
}