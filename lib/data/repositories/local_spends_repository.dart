import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../models/user_settings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences not initialized'),
);

abstract class SpendsRepository {
  Future<UserSettings> loadSettings();
  Future<List<Expense>> loadExpenses();
  Future<void> saveSettings(UserSettings settings);
  Future<void> saveExpenses(List<Expense> expenses);
  Future<void> clearAll();
}

final spendsRepositoryProvider = Provider<SpendsRepository>(
  (ref) => LocalSpendsRepository(ref.watch(sharedPreferencesProvider)),
);

class LocalSpendsRepository implements SpendsRepository {
  LocalSpendsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _settingsKey = 'spendsless_settings_v1';
  static const _expensesKey = 'spendsless_expenses_v1';

  @override
  Future<UserSettings> loadSettings() async {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return UserSettings.defaults();
    }

    return UserSettings.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<Expense>> loadExpenses() async {
    final raw = _prefs.getString(_expensesKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) async {
    await _prefs.setString(
      _expensesKey,
      jsonEncode(expenses.map((expense) => expense.toJson()).toList()),
    );
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_settingsKey);
    await _prefs.remove(_expensesKey);
  }
}