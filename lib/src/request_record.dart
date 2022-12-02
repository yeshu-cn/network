import 'package:dio/dio.dart';


class RequestRecord {
  DioError? dioError;
  RequestOptions requestOptions;
  Response? response;

  RequestRecord({
    required this.requestOptions,
  });
}
