enum OutboxOperationType { createExpense, deleteExpense }

class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
  });

  final String id;
  final OutboxOperationType operation;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  OutboxEntry copyWith({
    String? id,
    OutboxOperationType? operation,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
  }) {
    return OutboxEntry(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'operation': operation.name,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory OutboxEntry.fromJson(Map<String, dynamic> json) {
    return OutboxEntry(
      id: json['id'] as String,
      operation: OutboxOperationType.values.byName(json['operation'] as String),
      payload: (json['payload'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );
  }
}
