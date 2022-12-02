import 'package:dio/dio.dart';
import 'package:lib_network/src/request_record_repository.dart';

class RequestInterceptor implements Interceptor {
  late RequestRecordRepository repository;

  RequestInterceptor() {
    repository = RequestRecordRepository.getInstance();
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    repository.onError(err);
    return handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    repository.onRequest(options);
    return handler.next(options);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    repository.onResponse(response);
    return handler.next(response);
  }
}
