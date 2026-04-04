import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'key_vault.dart';

final cipherServiceProvider = Provider<CipherService>(
  (ref) => CipherService(ref.watch(keyVaultProvider)),
);

class CipherService {
  CipherService(this._keyVault);

  final KeyVault _keyVault;
  final _algorithm = AesGcm.with256bits();

  Future<String> encryptText(String plaintext) async {
    final keyBytes = await _keyVault.getOrCreateMasterKey();
    final secretKey = SecretKey(keyBytes);
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    final envelope = <String, dynamic>{
      'v': 1,
      'n': base64Encode(secretBox.nonce),
      'c': base64Encode(secretBox.cipherText),
      'm': base64Encode(secretBox.mac.bytes),
    };

    return jsonEncode(envelope);
  }

  Future<String> decryptText(String storedValue) async {
    final decoded = jsonDecode(storedValue);
    if (decoded is! Map<String, dynamic>) {
      return storedValue;
    }
    if (!decoded.containsKey('n') || !decoded.containsKey('c') || !decoded.containsKey('m')) {
      return storedValue;
    }

    final keyBytes = await _keyVault.getOrCreateMasterKey();
    final secretKey = SecretKey(keyBytes);
    final secretBox = SecretBox(
      base64Decode(decoded['c'] as String),
      nonce: base64Decode(decoded['n'] as String),
      mac: Mac(base64Decode(decoded['m'] as String)),
    );

    final clearBytes = await _algorithm.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(clearBytes);
  }
}
