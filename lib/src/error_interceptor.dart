import 'package:dio/dio.dart';
import 'http_utils.dart';

/// 网络错误的类型
enum NetError {
  /// 超时错误（连接超时，发送超时，接受超时）
  timeout,
  /// 取消
  cancel,
  /// 401，这里只把401当作未授权，404,403,都当作其他错误处理
  unauthorized,
  /// 其他错误
  other,
}

/// 处理网络请求错误
typedef NetErrorHandler = Function(NetError error);

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioErrorType.connectionTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        HttpUtils.netErrorHandler?.call(NetError.timeout);
        break;
      case DioErrorType.badResponse:
        if (401 == err.response!.statusCode) {
          // 401，这里只把401当作未授权，404,403,都当作其他错误处理
          HttpUtils.netErrorHandler?.call(NetError.unauthorized);
        } else {
          HttpUtils.netErrorHandler?.call(NetError.other);
        }
        break;
      case DioErrorType.cancel:
        HttpUtils.netErrorHandler?.call(NetError.cancel);
        break;
      case DioErrorType.unknown:
        HttpUtils.netErrorHandler?.call(NetError.other);
        break;
      default:
        HttpUtils.netErrorHandler?.call(NetError.other);
    }

    handler.next(err);
  }
}