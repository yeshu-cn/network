import 'package:dio/dio.dart';
import 'http_utils.dart';

/// handler net request response
typedef ResponseHandler = Function(Response response);

/// 针对response返回code,message的情况，在这里统一解析判断结果成功还是失败
/// 不推荐这种做法，但没办法，很多API喜欢这样设计
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    HttpUtils.responseHandler?.call(response);
    super.onResponse(response, handler);
  }
}

