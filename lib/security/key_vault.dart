import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final keyVaultProvider = Provider<KeyVault>(
  (ref) => KeyVault(ref.watch(secureStorageProvider)),
);

class KeyVault {
  KeyVault(this._storage);

  final FlutterSecureStorage _storage;

  static const _masterKey = 'spendsless_master_key_v1';

  Future<Uint8List> getOrCreateMasterKey() async {
    final existing = await _storage.read(key: _masterKey);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Decode(existing));
    }

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final encoded = base64Encode(bytes);
    await _storage.write(key: _masterKey, value: encoded);
    return Uint8List.fromList(bytes);
  }

  Future<void> clearMasterKey() async {
    await _storage.delete(key: _masterKey);
  }
}
