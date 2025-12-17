import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/app_config.dart';

/// Service for managing secure local storage
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Token Management
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConfig.accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
  }

  // User Data
  Future<void> saveUserData(String userData) async {
    await _secureStorage.write(key: AppConfig.userDataKey, value: userData);
  }

  Future<String?> getUserData() async {
    return await _secureStorage.read(key: AppConfig.userDataKey);
  }

  // Organization Data
  Future<void> saveOrgData(String orgData) async {
    await _secureStorage.write(key: AppConfig.orgDataKey, value: orgData);
  }

  Future<String?> getOrgData() async {
    return await _secureStorage.read(key: AppConfig.orgDataKey);
  }

  // Menus Data
  Future<void> saveMenusData(String menusData) async {
    await _secureStorage.write(key: AppConfig.menusDataKey, value: menusData);
  }

  Future<String?> getMenusData() async {
    return await _secureStorage.read(key: AppConfig.menusDataKey);
  }

  // Permissions Data
  Future<void> savePermissionsData(String permissionsData) async {
    await _secureStorage.write(
        key: AppConfig.permissionsDataKey, value: permissionsData);
  }

  Future<String?> getPermissionsData() async {
    return await _secureStorage.read(key: AppConfig.permissionsDataKey);
  }

  // Clear All
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
