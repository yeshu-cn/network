import 'package:flutter/material.dart';
import 'package:lib_network/src/request_record.dart';

class HttpRequestDetailPage extends StatefulWidget {
  final RequestRecord record;

  const HttpRequestDetailPage({Key? key, required this.record}) : super(key: key);

  @override
  State<HttpRequestDetailPage> createState() => _HttpRequestDetailPageState();
}

class _HttpRequestDetailPageState extends State<HttpRequestDetailPage> {
  @override
  Widget build(BuildContext context) {
    var options = widget.record.requestOptions;
    var response = widget.record.response;
    var dioError = widget.record.dioError;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('*** Request ***'),
                    Text('uri: ${options.uri.toString()}\n'
                        'method: ${options.method}\n'
                        'responseType: ${options.responseType.toString()}\n'
                        'followRedirects: ${options.followRedirects}\n'
                        'connectTimeout: ${options.connectTimeout}\n'
                        'sendTimeout: ${options.sendTimeout}\n'
                        'receiveTimeout: ${options.receiveTimeout}\n'
                        'receiveDataWhenStatusError: ${options.receiveDataWhenStatusError}\n'
                        'extra: ${options.extra}\n'
                        'headers: ${options.headers}\n'
                        'data: ${options.data}'),
                  ],
                ),
              ),
            ),
            const Divider(
              height: 10,
            ),
            if (null != dioError)
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('*** Dio Error ***'),
                    Text('error: $dioError'),
                    if (null != dioError.response) Text('statusCode: ${dioError.response!.statusCode}'),
                    if (null != dioError.response)
                      if (dioError.response!.isRedirect == true) Text('statusCode: ${dioError.response!.realUri}'),
                    if (null != dioError.response) Text('headers: ${dioError.response!.headers}'),
                    if (null != dioError.response) Text('response body: ${dioError.response!.toString()}'),
                  ],
                ),
              ),
            if (null != response)
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('*** Response ***'),
                    Text('statusCode: ${response.statusCode}'),
                    if (response.isRedirect == true) Text('statusCode: ${response.realUri}'),
                    Text('headers: ${response.headers}'),
                    Text('response body: ${response.toString()}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
