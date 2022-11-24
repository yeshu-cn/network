基于Dio封装的网络库，把项目中经常使用到的场景封装为静态方法，方便调用

## Feature
- [x] Get,Post异步请求
- [ ] Get,Post同步请求
- [x] 单个文件上传，多个文件上传
- [x] 文件下载
- [x] 日志打印
- [x] 实现cookie管理（基于内存的）
- [x] 各种请求传参
- [x] 统一封装处理网络错误提示
- [x] 设置默认connectTimeout
- [x] 设置默认的请求头，也可请求的时候单独设置
- [ ] 支持缓存
- [ ] 重试
- [x] 取消网络请求

## 使用
1. 调用`HttpUtils.init()`方法进行初始化
2. 调用`HttpUtils`中提供的静态方法进行网络请求


虽然lib提供了baseUrl的设置，但是很多项目不止一个baseUrl。所以干脆让调用方自己管理url
```dart
// 获取完整的api地址
String _getApiUrl(String api) {
  return "host:$api";
}
```

网络错误提示和token失效后跳转到登录页面的处理
```dart
// 有的api喜欢把response封装为code,message,data。在这里可以统一判断请求结果
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
      print(e.toString());
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

getDefaultHeader() {
  var header = {"Content-Type": "application/json"};
  var token = '';
  header['token'] = token;
  return header;
}

HttpUtils.init(
responseHandler: responseHandler,
netErrorHandler: netErrorHandler,
baseUrl: 'baseUrl',
getDefaultHeader: getDefaultHeader);
```

使用默认的请求头(一般默认的请求头带一些设备信息，token等参数)
```dart
  test('use default header', () async {
    // 设置post请求参数
    var data = {};
    data["uid"] = 'uid';
    var response = await HttpUtils.post(_getApiUrl('/postApi'), data: data);
});
```

单独设置请求头（部分接口不需要在header中设置token参数，则单独设置请求头）
```dart
test('use custom header', () async {
    // 设置请求头
    Options options = Options();
    options.headers = {};
    // 设置post请求参数
    var data = {};
    data["uid"] = 'uid';
    var response = await HttpUtils.post(_getApiUrl('/postApi'), options: options, data: data);
});
```

