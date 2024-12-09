import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/category.dart';
import '../../models/user.dart';
import '../../types.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ICacheService {
  Future setCategory(Json category);
  Future removeCategory(String name);
  Future<List<Category>> getCategories();

  Future<void> changeTheme(String theme);
  Future<String?> getTheme();
}

class CacheService implements ICacheService {
  CacheService() {
    _sharedPreferences = SharedPreferences.getInstance();
  }

  late Future<SharedPreferences> _sharedPreferences;

  @override
  Future changeTheme(String theme) async {
    (await _sharedPreferences).setString('theme', theme);
  }

  @override
  Future<String?> getTheme() async {
    return (await _sharedPreferences).getString('theme');
  }

  @override
  Future setCategory(Json category) async {
    final categoryStr = jsonEncode(category);
    (await _sharedPreferences).setString(category['name'], categoryStr);
  }

  @override
  Future<List<Category>> getCategories() async {
    final categoriesMap = await getAllPreferences();
    List<Category> categories = [];

    for (var value in categoriesMap.values) {
      if (value is String) {
        final decodedValue = jsonDecode(value);
        categories.add(Category.fromJson(decodedValue));
      }
    }

    return categories;
  }

  Future<Map<String, dynamic>> getAllPreferences() async {
    Map<String, dynamic> allPrefs = {};
    Set<String> keys = (await _sharedPreferences).getKeys();

    for (String key in keys) {
      allPrefs[key] = (await _sharedPreferences).get(key);
    }

    return allPrefs;
  }
  
  @override
  Future removeCategory(String name) async{
    return (await _sharedPreferences).remove(name);
  }
}

abstract class ISecureStorageCacheService {
  Future<void> setUser(User user);
  Future<User?> getUser();

  Future<void> clearCache();
}

class SecureStorageCacheService implements ISecureStorageCacheService {
  static SecureStorageCacheService? _instance;
  late final FlutterSecureStorage _secureStorage;

  SecureStorageCacheService._();

  // Initialize method that should be called during app startup
  static Future<void> init() async {
    if (_instance == null) {
      _instance = SecureStorageCacheService._();
      _instance!._secureStorage = const FlutterSecureStorage();
    }
  }

  // Instance getter that throws if not initialized
  static SecureStorageCacheService get instance {
    if (_instance == null) {
      throw StateError('SecureStorageCacheService must be initialized before using it. '
          'Call SecureStorageCacheService.init() first.');
    }
    return _instance!;
  }

  @override
  Future<void> setUser(User? user) async {
    if (user == null) {
      await _secureStorage.delete(key: 'user');
      return;
    }
    final userJson = user.toJson();
    final encodedUserJson = jsonEncode(userJson);
    await _secureStorage.write(key: 'user', value: encodedUserJson);
  }

  @override
  Future<User?> getUser() async {
    final encodedUserJson = await _secureStorage.read(key: 'user');
    if (encodedUserJson == null) return null;

    try {
      final userJson = jsonDecode(encodedUserJson);
      return User.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await _secureStorage.deleteAll();
  }
}
