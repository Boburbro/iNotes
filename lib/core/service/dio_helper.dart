import 'package:dio/dio.dart';

class DioErrorHelper {
  // This method handles DioExceptions
  static String handle(DioException exception) {
    if (exception.response?.data != null) {
      return exception.response!.data['message'];
    }
    return exception.getCustomErrorMessage();
  }
}

extension on DioException {
  // This extension gives custom error messages based on DioException type
  String getCustomErrorMessage() {
    return switch (type) {
      DioExceptionType.connectionTimeout => 'Connection timed out. Please check your internet connection and try again.',
      DioExceptionType.sendTimeout => 'Send request timed out. Please check your network and try again.',
      DioExceptionType.receiveTimeout => 'Server took too long to respond. Please try again later.',
      DioExceptionType.badCertificate =>
        'Failed to verify server certificate. Please ensure you are connected to a secure network.',
      DioExceptionType.badResponse => 'Received an unexpected response from the server. Please try again later.',
      DioExceptionType.cancel => 'Request was cancelled. Please try again.',
      DioExceptionType.connectionError => 'Connection error occurred. Please check your internet connection.',
      DioExceptionType.unknown => 'An unexpected error occurred. Please try again later.',
    };
  }
}
