import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _keyName = 'encryption_key';
  static final _storage = const FlutterSecureStorage();

  static Future<encrypt.Key> _getKey() async {
    String? key = await _storage.read(key: _keyName);
    if (key == null) {
      final newKey = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _keyName, value: newKey.base64);
      return newKey;
    }
    return encrypt.Key.fromBase64(key);
  }

  static Future<String> encryptText(String plain) async {
    final key = await _getKey();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plain, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  static Future<String> decryptText(String data) async {
    final key = await _getKey();
    final parts = data.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt(encrypted, iv: iv);
  }
}
