import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: dioException.response?.statusCode,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request send timeout. Please try again.',
          statusCode: dioException.response?.statusCode,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Response receive timeout. Please try again.',
          statusCode: dioException.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;
        String errorMessage = 'Server error occurred ($statusCode).';

        if (responseData is Map<String, dynamic>) {
          if (responseData['message'] != null) {
            final msg = responseData['message'];
            if (msg is List) {
              errorMessage = msg.join(', ');
            } else {
              errorMessage = msg.toString();
            }
          } else if (responseData['error'] != null) {
            errorMessage = responseData['error'].toString();
          }
        }

        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          data: responseData,
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Cannot reach server. Please check your network connection.',
        );
      case DioExceptionType.badCertificate:
        return ApiException(message: 'Bad certificate from server.');
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: dioException.message ?? 'An unexpected network error occurred.',
          statusCode: dioException.response?.statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
