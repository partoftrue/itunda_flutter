import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<void> writeObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await write(key, jsonString);
  }

  Future<Map<String, dynamic>?> readObject(String key) async {
    final jsonString = await read(key);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await writeObject(key, value);
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    return await readObject(key);
  }
} 