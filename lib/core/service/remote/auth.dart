import 'package:dio/dio.dart';
import 'package:inotes/core/models/auth_form.dart';
import 'package:inotes/core/models/user.dart';
import 'package:inotes/core/service/api_client.dart';
import 'package:inotes/core/service/dio_helper.dart';
import 'package:inotes/core/types.dart';

final class AuthenticationService {
  static AuthenticationService? _instance;
  static AuthenticationService get instance => _instance ?? AuthenticationService._();
  late final Dio _dio;

  AuthenticationService._() : _dio = ApiClient.instance.dio;

  Future<AuthResponse> login(LoginForm form) async {
    try {
      final data = {
        'username': form.username,
        'password': form.password,
      };

      final response = await _dio.post('/auth/login', data: data);
      if (response.statusCode == 200) {
        return AuthResponse.success(response.data);
      }
      throw 'Failed to login';
    } on DioException catch (exception) {
      throw AuthResponse.failure(DioErrorHelper.handle(exception));
    } catch (e) {
      throw 'Failed to login';
    }
  }

  Future<AuthResponse> register(RegisterForm form) async {
    try {
      final data = {
        'email': form.email,
        'username': form.username,
        'password': form.password,
      };

      final response = await _dio.post('/auth/register', data: data);
      if (response.statusCode == 201) {
        return AuthResponse.success(response.data);
      }
      throw 'Failed to register';
    } on DioException catch (exception) {
      throw AuthResponse.failure(DioErrorHelper.handle(exception));
    } catch (e) {
      throw 'Failed to register';
    }
  }
}

final class FailureResponse {
  FailureResponse({required this.error});

  final String error;

  factory FailureResponse.fromMap(dynamic json) {
    return FailureResponse(error: _findErrorMessageRecursive(json['message'] ?? json));
  }

  static String _findErrorMessageRecursive(dynamic object) {
    if (object is Map<String, dynamic>) {
      return _findErrorMessageRecursive(object.values.first);
    } else if (object is List<dynamic>) {
      return _findErrorMessageRecursive(object.first);
    } else if (object is String) {
      return object;
    }
    return 'Unknown error';
  }

  Map<String, dynamic> toMap() => {'error': error};
}

class SuccessResponse {
  final User user;

  SuccessResponse({required this.user});
}

class AuthResponse {
  final SuccessResponse? successResponse;
  final FailureResponse? failureResponse;

  AuthResponse({
    this.successResponse,
    this.failureResponse,
  });

  factory AuthResponse.success(Json json) {
    final successResponse = SuccessResponse(user: User.fromJson(json['user']));
    return AuthResponse(successResponse: successResponse);
  }

  factory AuthResponse.failure(dynamic json) {
    final failureResponse = FailureResponse.fromMap(json);
    return AuthResponse(failureResponse: failureResponse);
  }
}
