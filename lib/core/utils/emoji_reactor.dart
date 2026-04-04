import 'package:flutter/material.dart';

class BudgetReaction {
  const BudgetReaction({
    required this.emoji,
    required this.message,
    required this.color,
  });

  final String emoji;
  final String message;
  final Color color;
}

BudgetReaction budgetReactionFor(double percent) {
  if (percent <= 0) {
    return const BudgetReaction(
      emoji: '😴',
      message: 'nothing spent yet',
      color: Color(0xFF6B7280),
    );
  }
  if (percent <= 15) {
    return const BudgetReaction(
      emoji: '😎',
      message: 'slay, you are saving',
      color: Color(0xFF10B981),
    );
  }
  if (percent <= 35) {
    return const BudgetReaction(
      emoji: '😊',
      message: 'vibing, all good',
      color: Color(0xFF22C55E),
    );
  }
  if (percent <= 55) {
    return const BudgetReaction(
      emoji: '🙂',
      message: 'mid spend, stay sharp',
      color: Color(0xFFEAB308),
    );
  }
  if (percent <= 70) {
    return const BudgetReaction(
      emoji: '😬',
      message: 'getting spenny',
      color: Color(0xFFF59E0B),
    );
  }
  if (percent <= 85) {
    return const BudgetReaction(
      emoji: '😰',
      message: 'budget is sweating',
      color: Color(0xFFF97316),
    );
  }
  if (percent <= 100) {
    return const BudgetReaction(
      emoji: '🤯',
      message: 'you are very close to the edge',
      color: Color(0xFFEF4444),
    );
  }
  return const BudgetReaction(
    emoji: '💀',
    message: 'budget overflow',
    color: Color(0xFFDC2626),
  );
}