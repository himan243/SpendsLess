import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/categories.dart';
import '../core/constants/payment_methods.dart';
import 'models/expense.dart';
import 'models/user_settings.dart';
import 'repositories/local_spends_repository.dart';

class SpendsState {
  const SpendsState({
    required this.isLoading,
    required this.settings,
    required this.expenses,
    required this.error,
  });

  final bool isLoading;
  final UserSettings settings;
  final List<Expense> expenses;
  final String? error;

  factory SpendsState.initial() => SpendsState(
        isLoading: true,
        settings: UserSettings.defaults(),
        expenses: const [],
        error: null,
      );

  SpendsState copyWith({
    bool? isLoading,
    UserSettings? settings,
    List<Expense>? expenses,
    String? error,
  }) {
    return SpendsState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      expenses: expenses ?? this.expenses,
      error: error,
    );
  }
}

final spendsControllerProvider =
    StateNotifierProvider<SpendsController, SpendsState>(
  (ref) {
    final controller = SpendsController(ref.watch(spendsRepositoryProvider));
    controller.load();
    return controller;
  },
);

class SpendsController extends StateNotifier<SpendsState> {
  SpendsController(this._repository) : super(SpendsState.initial());

  final SpendsRepository _repository;
  static const Uuid _uuid = Uuid();

  Future<void> load() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final settings = await _repository.loadSettings();
      final expenses = await _repository.loadExpenses();
      state = state.copyWith(
        isLoading: false,
        settings: settings,
        expenses: expenses,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> updateDailyLimit(double limit) async {
    final updated = state.settings.copyWith(dailyLimit: limit);
    state = state.copyWith(settings: updated, error: null);
    await _repository.saveSettings(updated);
  }

  Future<void> updateDisplayName(String displayName) async {
    final updated = state.settings.copyWith(displayName: displayName.trim());
    state = state.copyWith(settings: updated, error: null);
    await _repository.saveSettings(updated);
  }

  Future<void> updateCurrencyCode(String currencyCode) async {
    final updated = state.settings.copyWith(currencyCode: currencyCode.trim());
    state = state.copyWith(settings: updated, error: null);
    await _repository.saveSettings(updated);
  }

  Future<void> addExpense({
    required double amount,
    required ExpenseCategory category,
    required PaymentMethod paymentMethod,
    required String note,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      note: note.trim(),
      spentAt: DateTime.now(),
    );
    final updated = [expense, ...state.expenses];
    state = state.copyWith(expenses: updated, error: null);
    await _repository.saveExpenses(updated);
  }

  Future<void> deleteExpense(String id) async {
    final updated = state.expenses.where((expense) => expense.id != id).toList();
    state = state.copyWith(expenses: updated, error: null);
    await _repository.saveExpenses(updated);
  }

  Future<void> clearAll() async {
    state = state.copyWith(
      settings: UserSettings.defaults(),
      expenses: const [],
      error: null,
    );
    await _repository.clearAll();
    await _repository.saveSettings(UserSettings.defaults());
  }
}