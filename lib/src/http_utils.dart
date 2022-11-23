import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'error_interceptor.dart';
import 'response_interceptor.dart';

/// 网络请求的utils
class HttpUtils {
  // 超时时间
  static const int connectTimeout = 30000;

  static ResponseHandler? _responseHandler;

  static NetErrorHandler? _netErrorHandler;

  static int _connectTimeout = 30000;
  static CookieJar cookieJar = CookieJar();
  static String? _baseUrl;
  static bool _enableLog = true;

  static get responseHandler => _responseHandler;
  static get netErrorHandler => _netErrorHandler;

  static void init(
      {int? connectTimeout,
      NetErrorHandler? netErrorHandler,
      ResponseHandler? responseHandler,
      String? baseUrl,
      bool enableLog = true}) {
    _connectTimeout = connectTimeout ?? _connectTimeout;
    _netErrorHandler = netErrorHandler;
    _responseHandler = responseHandler;
    _baseUrl = baseUrl;
    _enableLog = enableLog;
  }

  static Future<Dio> _getDio() async {
    var dio = Dio();
    // set default timeout
    dio.options.connectTimeout = _connectTimeout;
    if (null != _baseUrl) {
      dio.options.baseUrl = _baseUrl!;
    }

    // set interceptor
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(ResponseInterceptor());
    dio.interceptors.add(CookieManager(cookieJar));
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
    var dio = await _getDio();
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
    var dio = await _getDio();
    return await dio.post(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
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
    var dio = await _getDio();
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
    var dio = await _getDio();
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
    var dio = await _getDio();
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
