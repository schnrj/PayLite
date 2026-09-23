import 'package:dio/dio.dart';
import 'api_config.dart';
import 'error_mapper.dart';
import '../errors/bank_error.dart';
import '../security/secure_session_store.dart';

/// Dio-based network client with auth, 401 recovery, and error conversion interceptors.
class ApiClient {
  late final Dio dio;
  final SecureSessionStore sessionStore;

  ApiClient({required this.sessionStore}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = await sessionStore.loadSession();
          if (session != null && session['token'] != null) {
            options.headers['Authorization'] = 'Bearer ${session['token']}';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await sessionStore.clearSession();
          }
          final bankError = ErrorMapper.fromResponse(
            e.response?.statusCode,
            e.response?.data,
            defaultMessage: e.message,
          );
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: bankError,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      if (e.error is BankError) throw e.error as BankError;
      throw ErrorMapper.fromException(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data, String? idempotencyKey}) async {
    try {
      final options = Options();
      if (idempotencyKey != null) {
        options.headers = {'Idempotency-Key': idempotencyKey};
      }
      return await dio.post<T>(path, data: data, options: options);
    } on DioException catch (e) {
      if (e.error is BankError) throw e.error as BankError;
      throw ErrorMapper.fromException(e);
    }
  }
}
