import 'package:dio/dio.dart';
import 'package:inotes/core/service/log_service.dart';

class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  late Dio dio;

  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8080',
        contentType: Headers.jsonContentType,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLog.instance.debug('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onError: (DioException exception, handler) async {
        if (exception.response?.data == null) {
          AppLog.instance.debug('Exception response data is null');
          return;
        }
        if (exception.response?.data.isEmpty) {
          AppLog.instance.debug('Exception response data is empty');
          return;
        }
        AppLog.instance.debug('Exception response data: ${exception.response?.data}');

        return handler.next(exception);
      },
    ));
  }
}
