import 'package:dio/dio.dart';


class RequestRecord {
  DioError? dioError;
  RequestOptions requestOptions;
  Response? response;
  DateTime requestTime = DateTime.now();

  RequestRecord({
    required this.requestOptions,
  });
}
