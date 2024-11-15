import 'dart:async';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:lib_network/src/request_interceptor.dart';
import 'error_interceptor.dart';
import 'response_interceptor.dart';

/// 通用的请求头
typedef GetDefaultHeader = Future<Map<String, dynamic>> Function();

/// 网络请求的utils
class HttpUtils {
  /// response 拦截器
  static ResponseHandler? _responseHandler;

  /// 网络请求错误拦截器
  static NetErrorHandler? _netErrorHandler;

  /// 注入通用请求头
  static GetDefaultHeader? _getDefaultHeader;

  /// 超时时间
  static int _connectTimeout = 30000;
  static CookieJar cookieJar = CookieJar();
  static String? _baseUrl;

  /// 启用日志打印
  static bool _enableLog = true;

  /// 启用应用程序中的日志界面
  static bool _enableAppLog = false;

  /// 自定义拦截器列表
  static List<Interceptor> _customInterceptors = [];

  static get responseHandler => _responseHandler;

  static get netErrorHandler => _netErrorHandler;

  static get defaultHeader => _getDefaultHeader;

  static void baseConfig({
    int? connectTimeout,
    NetErrorHandler? netErrorHandler,
    ResponseHandler? responseHandler,
    GetDefaultHeader? getDefaultHeader,
    String? baseUrl,
    bool enableLog = true,
    bool enableAppLog = false,
    List<Interceptor>? interceptors,
  }) {
    _connectTimeout = connectTimeout ?? _connectTimeout;
    _netErrorHandler = netErrorHandler;
    _responseHandler = responseHandler;
    _getDefaultHeader = getDefaultHeader;
    _baseUrl = baseUrl;
    _enableLog = enableLog;
    _enableAppLog = enableAppLog;
    if (null != interceptors) {
      _customInterceptors = interceptors;
    }
  }

  static Future<Dio> _getDio(Map<String, dynamic>? headers) async {
    var dio = Dio();
    // set default timeout
    dio.options.connectTimeout = Duration(milliseconds: _connectTimeout);
    if (null != _baseUrl) {
      dio.options.baseUrl = _baseUrl!;
    }
    // 如果用户有设置header则使用用户的，否则使用默认的header
    if (null != headers) {
      dio.options.headers = headers;
    } else {
      if (null != _getDefaultHeader) {
        dio.options.headers = await _getDefaultHeader!.call();
      }
    }

    // 添加自定义拦截器（优先添加，保证最先执行）
    if (_customInterceptors.isNotEmpty) {
      dio.interceptors.addAll(_customInterceptors);
    }

    // set interceptor
    if (_enableAppLog) {
      dio.interceptors.add(RequestInterceptor());
    }
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(ResponseInterceptor());
    // web环境不需要cookie
    if (!kIsWeb) {
      dio.interceptors.add(CookieManager(cookieJar));
    }

    if (_enableLog) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }

    return dio;
  }

  /// Handy method to make http GET request, which is a alias of  [dio.fetch(RequestOptions)].
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    var dio = await _getDio(options?.headers);
    return await dio.get(path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
  }

  /// Handy method to make http POST request, which is a alias of  [dio.fetch(RequestOptions)].
  static Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    var dio = await _getDio(options?.headers);
    return await dio.post(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  /// put
  static Future<Response<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    var dio = await _getDio(options?.headers);
    return await dio.put(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  /// delete
  static Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    var dio = await _getDio(options?.headers);
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// upload file
  static Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    var queryParameters = {"Content-Type": "multipart/form-data"};
    var dio = await _getDio(options?.headers);
    return await dio.post(path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  /// upload files
  static Future<Response<T>> uploadFiles<T>(
    String path, {
    required List<String> filePaths,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    var formData = FormData();
    for (var file in filePaths) {
      formData.files.add(MapEntry('files', MultipartFile.fromFileSync(file)));
    }
    var queryParameters = {"Content-Type": "multipart/form-data"};
    var dio = await _getDio(options?.headers);
    return await dio.post(path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  /// upload form data
  static Future<Response<T>> uploadFormData<T>(
    String path, {
    required FormData formData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    var queryParameters = {"Content-Type": "multipart/form-data"};
    var dio = await _getDio(options?.headers);
    return await dio.post(path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  /// download file
  static Future<Response> download(
    String urlPath,
    savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    data,
    Options? options,
  }) async {
    var dio = await _getDio(options?.headers);
    return await dio.download(urlPath, savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options);
  }
}
