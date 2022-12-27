import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:lib_network/src/request_record.dart';


class RequestRecordRepository {
  final LinkedHashMap<String, RequestRecord> logMap = LinkedHashMap();

  int capacity = 100;

  static final RequestRecordRepository _instance = RequestRecordRepository._singleton();

  RequestRecordRepository._singleton();

  static RequestRecordRepository getInstance() {
    return _instance;
  }

  List<RequestRecord> getRecordList() {
    return logMap.values.toList();
  }

  List<RequestRecord> getRecordListByUrl(String url) {
    return logMap.values.toList().where((element) => element.requestOptions.uri.path == url).toList();
  }

  void onError(DioError dioError) {
    var key = dioError.requestOptions.hashCode.toString();
    if (logMap.containsKey(key)) {
      logMap.update(key, (value) {
        value.dioError = dioError;
        return value;
      });
    }
  }

  void onRequest(RequestOptions options) {
    if (logMap.length >= capacity) {
      logMap.remove(logMap.keys.last);
    }
    var key = options.hashCode.toString();
    logMap.putIfAbsent(key, () => RequestRecord(requestOptions: options));
  }

  void onResponse(Response response) {
    var key = response.requestOptions.hashCode.toString();
    if (logMap.containsKey(key)) {
      logMap.update(key, (value) {
        value.response = response;
        return value;
      });
    }
  }

  void clear() {
    logMap.clear();
  }
}
