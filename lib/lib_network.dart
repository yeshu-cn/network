library lib_network;

import 'package:flutter/material.dart';
import 'package:lib_network/src/request_history_page.dart';
export 'src/http_utils.dart';
export 'src/error_interceptor.dart';
export 'src/response_interceptor.dart';
export 'package:dio/dio.dart';
export 'src/request_interceptor.dart';

void navigationToRequestHistoryPage(BuildContext context){
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return const RequestHistoryPage();
  }));
}