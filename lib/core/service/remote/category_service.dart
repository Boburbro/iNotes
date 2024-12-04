import 'package:dio/dio.dart';
import 'package:inotes/core/models/category.dart';
import 'package:inotes/core/models/response.dart';
import 'package:inotes/core/utils/api_client.dart';
import 'package:inotes/core/utils/dio_helper.dart';
import 'package:inotes/core/service/log_service.dart';
import 'package:inotes/core/types.dart';
import 'package:inotes/view/utilities/utils.dart';

final class CategoryService {
  static CategoryService? _instance;
  static CategoryService get instance => _instance ?? CategoryService._();
  late final Dio _dio;

  CategoryService._() : _dio = ApiClient.instance.dio;

  Future<PaginatedDataResponse<Category>?> fetchCategories({required int userId}) async {
    final queryParameters = {'user_id': userId};
    try {
      final response = await _dio.get('/categories', queryParameters: queryParameters);
      if (response.statusCode == 200) {
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
      if (response.statusCode == 201) {
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
}
