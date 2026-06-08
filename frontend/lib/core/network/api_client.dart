import 'package:dio/dio.dart';
import '../services/token_service.dart';
import '../utils/debug_logger.dart';

class ApiClient {
  static const String _tag = 'ApiClient';
  static const String baseUrl = 'https://wakeell.microdesk.tech/api';

  late final Dio _dio;
  final TokenService _tokenService;

  ApiClient(this._tokenService) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        DebugLogger.log(_tag, '>>> ${options.method} ${options.baseUrl}${options.path}');
        if (options.queryParameters.isNotEmpty) {
          DebugLogger.log(_tag, '    PARAMS: ${options.queryParameters}');
        }
        if (options.data != null) {
          DebugLogger.log(_tag, '    BODY:   ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        DebugLogger.log(_tag, '<<< ${response.statusCode} ${response.requestOptions.path}');
        DebugLogger.log(_tag, '    DATA:   ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        DebugLogger.error(_tag, '!!! ${error.response?.statusCode} ${error.requestOptions.path} — ${error.message}');
        if (error.response?.data != null) {
          DebugLogger.error(_tag, '    ERR DATA: ${error.response?.data}');
        }
        if (error.response?.statusCode == 401) {
          await _tokenService.clearToken();
          DebugLogger.log(_tag, 'Token cleared on 401');
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}
