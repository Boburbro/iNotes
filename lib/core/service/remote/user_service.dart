import 'package:dio/dio.dart';
import 'package:inotes/core/models/user.dart';
import 'package:inotes/core/utils/api_client.dart';
import 'package:inotes/core/utils/dio_helper.dart';
import 'package:inotes/core/service/log_service.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ?? UserService._();
  late final Dio _dio;

  UserService._() : _dio = ApiClient.instance.dio;

  Future<User?> getUser({required int userId}) async {
    final queryParameters = {'user_id': userId};
    try {
      final response = await _dio.get('/user', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw 'Failed to get user';
    } on DioException catch (exception) {
      final message = DioErrorHelper.handle(exception);
      AppLog.instance.debug('Get User Error Message: $message');
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      throw 'Failed to get user';
    }
  }

  Future<User?> updateProfilePicture({required Map<String, dynamic> userJson}) async {
    final formData = FormData.fromMap({
      'user_id': userJson['user_id'],
      'avatar': MultipartFile.fromBytes(
        userJson['avatar'],
        filename: 'avatar.png',
        contentType: DioMediaType('image', 'png'),
      ),
    });

    try {
      final response = await _dio.post('/update-profile-picture', data: formData);
      if (response.statusCode == 201) {
        return User.fromJson(response.data);
      }
      throw 'Failed to update profile picture';
    } on DioException catch (exception) {
      final message = DioErrorHelper.handle(exception);
      AppLog.instance.debug('Update Profile Picture Error Message: $message');
      throw DioErrorHelper.handle(exception);
    } catch (e) {
      throw 'Failed to update profile picture';
    }
  }
}
