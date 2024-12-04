import 'package:dio/dio.dart';
import 'package:inotes/core/utils/log_service.dart';

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
        CSLog.instance.debug('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onError: (DioException exception, handler) async {
        if (exception.response?.data == null) {
          CSLog.instance.debug('Exception response data is null');
          return;
        }
        if (exception.response?.data.isEmpty) {
          CSLog.instance.debug('Exception response data is empty');
          return;
        }
        CSLog.instance.debug('Exception response data: ${exception.response?.data}');

        return handler.next(exception);
      },
    ));
  }
}
