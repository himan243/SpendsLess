import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../models/outbox_entry.dart';
import '../models/user_settings.dart';
import '../../security/cipher_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences not initialized'),
);

abstract class SpendsRepository {
  Future<UserSettings> loadSettings();
  Future<List<Expense>> loadExpenses();
  Future<void> saveSettings(UserSettings settings);
  Future<void> saveExpenses(List<Expense> expenses);
  Future<List<OutboxEntry>> loadOutbox();
  Future<void> saveOutbox(List<OutboxEntry> entries);
  Future<void> enqueueOutbox(OutboxEntry entry);
  Future<void> removeOutboxEntries(Set<String> entryIds);
  Future<void> clearAll();
}

final spendsRepositoryProvider = Provider<SpendsRepository>(
  (ref) => LocalSpendsRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(cipherServiceProvider),
  ),
);

class LocalSpendsRepository implements SpendsRepository {
  LocalSpendsRepository(this._prefs, this._cipher);

  final SharedPreferences _prefs;
  final CipherService _cipher;

  static const _settingsKey = 'spendsless_settings_v1';
  static const _expensesKey = 'spendsless_expenses_v1';
  static const _outboxKey = 'spendsless_outbox_v1';

  @override
  Future<UserSettings> loadSettings() async {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return UserSettings.defaults();
    }

    final decrypted = await _decryptIfNeeded(raw);

    return UserSettings.fromJson(
      jsonDecode(decrypted) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<Expense>> loadExpenses() async {
    final raw = _prefs.getString(_expensesKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decrypted = await _decryptIfNeeded(raw);
    final list = jsonDecode(decrypted) as List<dynamic>;
    return list
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    final encrypted = await _cipher.encryptText(jsonEncode(settings.toJson()));
    await _prefs.setString(_settingsKey, encrypted);
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) async {
    final raw = jsonEncode(expenses.map((expense) => expense.toJson()).toList());
    final encrypted = await _cipher.encryptText(raw);
    await _prefs.setString(_expensesKey, encrypted);
  }

  @override
  Future<List<OutboxEntry>> loadOutbox() async {
    final raw = _prefs.getString(_outboxKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decrypted = await _decryptIfNeeded(raw);
    final list = jsonDecode(decrypted) as List<dynamic>;
    return list
        .map((item) => OutboxEntry.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> saveOutbox(List<OutboxEntry> entries) async {
    final raw = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    final encrypted = await _cipher.encryptText(raw);
    await _prefs.setString(_outboxKey, encrypted);
  }

  @override
  Future<void> enqueueOutbox(OutboxEntry entry) async {
    final current = await loadOutbox();
    await saveOutbox([entry, ...current]);
  }

  @override
  Future<void> removeOutboxEntries(Set<String> entryIds) async {
    if (entryIds.isEmpty) {
      return;
    }
    final current = await loadOutbox();
    final filtered = current.where((entry) => !entryIds.contains(entry.id)).toList();
    await saveOutbox(filtered);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_settingsKey);
    await _prefs.remove(_expensesKey);
    await _prefs.remove(_outboxKey);
  }

  Future<String> _decryptIfNeeded(String value) async {
    try {
      return await _cipher.decryptText(value);
    } catch (_) {
      // Backward compatibility for plaintext records from previous app versions.
      return value;
    }
  }
}