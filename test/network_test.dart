import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lib_network/lib_network.dart';


void main() {

  setUpAll(() async {
    // 有的api喜欢把response封装为code,message,data。在这里可以统一判断请求结果
    responseHandler(Response response) {
      if (!_isSuccess(response)) {
        // response中返回失败，则提示网络错误
        _showNetErrorTip();
      }
    }

    netErrorHandler(NetError error) {
      switch (error) {
        case NetError.timeout:
          _showNetErrorTip();
          break;
        case NetError.other:
          _showNetErrorTip();
          break;
        case NetError.cancel:
          _showNetErrorTip();
          break;
        case NetError.unauthorized:
          _onUnauthorized();
          break;
      }
    }

    HttpUtils.init(responseHandler: responseHandler, netErrorHandler:  netErrorHandler);
  });


  test('get', () async {
    Options options = _getCommonOptions();
    var response = await HttpUtils.get(_getApiUrl('/getApi'), options: options);
  });

  test('post', () async {
    // 设置请求头
    Options options = _getCommonOptions();
    // 设置post请求参数
    var data = {};
    data["uid"] = 'uid';
    var response = await HttpUtils.post(_getApiUrl('/postApi'), options: options, data: data);
  });

  test('use base url', () {

  });

  test("custom time out", ()  async {
    // 设置请求头
    Options options = _getCommonOptions();
    options.receiveTimeout = 30 * 1000;
    options.sendTimeout = 30 * 1000;

    // 设置post请求参数
    var data = {};
    data["uid"] = 'uid';
    var response = await HttpUtils.post(_getApiUrl('/postApi'), options: options, data: data);
  });

}

// 获取通用的请求头
Options _getCommonOptions() {
  return Options();
}

// 获取完整的api地址
String _getApiUrl(String api) {
  return "host:$api";
}

// 处理未登录或者登录无效的场景
void _onUnauthorized() {

}

// 显示网络请求错误提示
void _showNetErrorTip() {

}

// 统一判断code,message, data
bool _isSuccess(Response response) {
  return true;
}