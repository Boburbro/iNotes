import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/auth_form.dart';
import '../../models/user.dart';
import '../../utils/api_client.dart';
import '../../types.dart';

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
      if (response.statusCode == HttpStatus.ok) {
        return AuthResponse.success(response.data);
      }
      throw 'Failed to login';
    } on DioException catch (exception) {
      final error = jsonDecode(exception.response?.data);
      throw error['message'];
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
      if (response.statusCode == HttpStatus.created) {
        return AuthResponse.success(response.data);
      }
      throw 'Failed to register';
    } on DioException catch (exception) {
      final error = jsonDecode(exception.response?.data);
      throw error['message'];
    } catch (e) {
      throw 'Failed to register';
    }
  }

  Future<bool?> deleteAccount({required int userId}) async {
    final queryParameters = {'user_id': userId};

    try {
      final response = await _dio.delete('/delete-account', queryParameters: queryParameters);
      return response.statusCode == HttpStatus.noContent;
    } on DioException catch (exception) {
      final error = jsonDecode(exception.response?.data);
      throw error['message'];
    } catch (e) {
      throw 'Failed to delete account';
    }
  }
}

class FailureResponse {
  final String message;

  FailureResponse({required this.message});

  factory FailureResponse.fromMap(Map<String, dynamic> map) {
    return FailureResponse(message: map['message']);
  }
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
