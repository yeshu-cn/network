import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lib_network/lib_network.dart';
import 'home_page.dart';

void main() {
  initHttp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: snackBarKey,
      title: 'Network lib Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage('Network lib Demo'),
    );
  }
}

initHttp() {
  HttpUtils.baseConfig(
      enableLog: true,
      connectTimeout: 1000 * 30,
      netErrorHandler: _netErrorHandler,
      responseHandler: _responseHandler,
      getDefaultHeader: _getDefaultHeader,
      enableAppLog: true,
      baseUrl: "https://api.github.com");
}

Future<Map<String, dynamic>> _getDefaultHeader() async {
  var header = {"Content-Type": "application/json"};
  return header;
}

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();

_netErrorHandler(NetError error) {
  switch (error) {
    case NetError.timeout:
      snackBarKey.currentState?.showSnackBar(const SnackBar(content: Text('connect timeout')));
      break;
    case NetError.other:
      snackBarKey.currentState?.showSnackBar(const SnackBar(content: Text('request failed, retry later')));
      break;
    case NetError.cancel:
      break;
    case NetError.unauthorized:
      onUnauthorized(null);
      break;
  }
}

// 很多API喜欢将返回包装一层code, message, data。可以在这里统一处理错误的解析
_responseHandler(Response response) {
  if (response.statusCode == 200) {
    try {
      var data = jsonDecode(response.data);
      var code = data['code'] as int;
      var msg = data['msg'];
      if (code == 401 || code == 403) {
        onUnauthorized(msg);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

void onUnauthorized(msg) {
  snackBarKey.currentState?.showSnackBar(const SnackBar(content: Text('no permission, please login')));
  // 跳转到登录页面
}
