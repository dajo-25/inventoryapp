// api_client_dio.dart
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({String baseUrl = 'https://inventoryapi.reservarum.com'})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: 5), // tiempo máximo para conectar
          receiveTimeout:
              Duration(seconds: 5), // tiempo máximo para recibir datos
          headers: {
            'Content-Type': 'application/json',
          },
        )) {
    // Opcional: añadir un interceptor de logging para depurar
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(path, queryParameters: params);
    } on DioException catch (e) {
      // Manejo de errores más fino
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout de conexión al servidor');
      }
      if (e.response != null) {
        throw Exception(
            'Error ${e.response?.statusCode}: ${e.response?.statusMessage}');
      }
      throw Exception('Error de red: ${e.message}');
    }
  }

  Future<Response> post(String path, Map<String, dynamic> body) async {
    try {
      return await _dio.post(path, data: body);
    } on DioException catch (e) {
      throw Exception('POST falló: ${e.message}');
    }
  }

  Future<Response> put(String path, Map<String, dynamic> body) async {
    try {
      return await _dio.put(path, data: body);
    } on DioException catch (e) {
      throw Exception('PUT falló: ${e.message}');
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw Exception('DELETE falló: ${e.message}');
    }
  }
}
