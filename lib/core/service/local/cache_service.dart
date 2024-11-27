import 'dart:convert';

import 'package:inotes/core/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CacheService {
  Future setNoteCategories(String category);
  Future<List<Category>> getNoteCategories();

  Future<void> changeTheme(String theme);
  Future<String?> getTheme();
}

class CacheServiceImpl implements CacheService {
  CacheServiceImpl() {
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
  Future setNoteCategories(String category) async {
    final categories = await getNoteCategories();
    final categoriesJsons = categories.map((category) => category.toJson()).toList();
    final encodedCategories = jsonEncode(categoriesJsons);
    (await _sharedPreferences).setString('categories', encodedCategories);
  }

  @override
  Future<List<Category>> getNoteCategories() async {
    final categories = (await _sharedPreferences).getString('categories');
    if (categories == null) return Future.value(<Category>[]);

    final decodedCategories = jsonDecode(categories) as List;
    return Future.value(decodedCategories.map((category) => Category.fromJson(category)).toList());
  }
}
