import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lib_network/lib_network.dart';


void main() {

  setUpAll(() async {

    responseHandler(Response response) {
      if (response.statusCode == 200) {
        try {
          var data = jsonDecode(response.data);
          var code = data['code'] as int;
          var msg = data['msg'];
          if (code == 401 || code == 403) {
            onUnauthorized(msg);
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }


    netErrorHandler(NetError error) {
      switch (error) {
        case NetError.timeout:
          showNetFailedTip();
          break;
        case NetError.other:
          showNetFailedTip();
          break;
        case NetError.cancel:
          showNetFailedTip();
          break;
        case NetError.unauthorized:
        // 统一处理token无效的情况
          onUnauthorized('');
          break;
      }
    }

    getDefaultHeader() async {
      var header = {"Content-Type": "application/json"};
      var token = '';
      header['token'] = token;
      return header;
    }

    HttpUtils.baseConfig(
        responseHandler: responseHandler,
        netErrorHandler: netErrorHandler,
        baseUrl: 'baseUrl',
        getDefaultHeader: getDefaultHeader);
  });


  test('use default header', () async {
    // 设置post请求参数
    var data = {};
    data["uid"] = 'uid';
    await HttpUtils.post(_getApiUrl('/postApi'), data: data);
  });

  test('use custom header', () async {
    // 设置请求头
    Options options = Options();
    options.headers = {};
    // 设置post请求参数
    var data = {};
    data["uid"] = 'uid';
    await HttpUtils.post(_getApiUrl('/postApi'), options: options, data: data);
  });

  test("custom time out", ()  async {
    // 设置请求头
    Options options = Options();
    options.receiveTimeout = const Duration(milliseconds: 30 * 1000);
    options.sendTimeout = const Duration(milliseconds: 30 * 1000);

    // 设置post请求参数
    var data = {};
    data["uid"] = 'uid';
    await HttpUtils.post(_getApiUrl('/postApi'), options: options, data: data);
  });

}

// 获取完整的api地址
String _getApiUrl(String api) {
  return "host:$api";
}

// 显示网络请求错误提示
void showNetFailedTip() {

}

void onUnauthorized(msg) {
}