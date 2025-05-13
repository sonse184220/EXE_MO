import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inner_child_app/domain/entities/auth/account_profile.dart';

class SecureStorageUtils {
  final _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) =>
      _storage.read(key: key);

  Future<void> delete(String key) =>
      _storage.delete(key: key);

  Future<void> clear() => _storage.deleteAll();

  // Future<void> saveToken(String token) async {
  //   await _storage.write(key: 'access_token', value: token);
  // }
  //
  // Future<String?> getToken() async {
  //   return _storage.read(key: 'access_token');
  // }
  //
  // Future<void> clearToken() async {
  //   await _storage.delete(key: 'access_token');
  // }
  //
  // Future<void> saveProfileData(AccountProfile profile) async {
  //   await _storage.write(key: 'access_token', value: token);
  // }
}
