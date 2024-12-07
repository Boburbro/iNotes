import 'dart:io';

import 'package:dio/dio.dart';
import '../../models/category.dart';
import '../../models/response.dart';
import '../../utils/api_client.dart';
import '../../utils/dio_helper.dart';
import '../log_service.dart';
import '../../types.dart';
import '../../../view/utilities/utils.dart';

final class CategoryService {
  static CategoryService? _instance;
  static CategoryService get instance => _instance ?? CategoryService._();
  late final Dio _dio;

  CategoryService._() : _dio = ApiClient.instance.dio;

  Future<PaginatedDataResponse<Category>?> fetchCategories({required int userId}) async {
    final queryParameters = {'user_id': userId};
    try {
      final response = await _dio.get('/categories', queryParameters: queryParameters);
      if (response.statusCode == HttpStatus.ok) {
        final categories = PaginatedDataResponse<Category>.fromJson(response.data, Category.fromJson);
        return categories;
      }
      throw 'Failed to load categories';
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Fetch Categories Error Message: $e');
      throw 'Failed to load categories';
    }
  }

  Future<Category?> addCategory({required Json categoryJson}) async {
    try {
      final formData = FormData.fromMap({
        'user_id': categoryJson['user_id'],
        'name': categoryJson['name'],
        'color': ViewUtils.colorToHex(categoryJson['color']),
        'avatar': MultipartFile.fromBytes(
          categoryJson['avatar'],
          filename: 'avatar.png',
          contentType: DioMediaType('image', 'png'),
        ),
      });
      final response = await _dio.post('/category', data: formData);
      if (response.statusCode == HttpStatus.created) {
        return Category.fromJson(response.data);
      }
      throw 'Failed to add category';
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Add Category Error Message: $e');
      throw 'Failed to add category';
    }
  }

  Future<bool?> deleteCategory({required int userId, required int categoryId}) async {
    final queryParameters = {'user_id': userId, 'category_id': categoryId};
    try {
      final response = await _dio.delete('/category/delete', queryParameters: queryParameters);
      return response.statusCode == HttpStatus.noContent;
    } on DioException catch (exception) {
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      AppLog.instance.debug('Fetch Categories Error Message: $e');
      throw 'Failed to load categories';
    }
  }
}
