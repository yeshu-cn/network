import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lib_network/src/request_history_filter_page.dart';
import 'package:lib_network/src/request_record.dart';
import 'package:lib_network/src/http_request_detail_page.dart';
import 'package:lib_network/src/request_record_repository.dart';

class RequestHistoryPage extends StatefulWidget {
  const RequestHistoryPage({Key? key}) : super(key: key);

  @override
  State<RequestHistoryPage> createState() => _RequestHistoryPageState();
}

class _RequestHistoryPageState extends State<RequestHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Http Request Logs'),
      ),
      body: Scrollbar(
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            var record = RequestRecordRepository.getInstance().getRecordList()[index];
            return _buildItem(record);
          },
          itemCount: RequestRecordRepository.getInstance().getRecordList().length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),
      ),
    );
  }

  Widget _buildItem(RequestRecord record) {
    var options = record.requestOptions;
    var dioError = record.dioError;
    var response = record.response;
    return ListTile(
      title: Row(
        children: [
          Text("${_formatRequestTime(record.requestTime)}  Method: ${options.method}"),
          if (null != response) _buildStatusCode(response.statusCode),
          if (null != dioError && dioError.response != null) _buildStatusCode(dioError.response!.statusCode),
        ],
      ),
      subtitle: Text(options.uri.toString()),
      onLongPress: () {
        _showFilterDialog(record.requestOptions.uri.path);
      },
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HttpRequestDetailPage(
              record: record,
            ),
          ),
        );
      },
    );
  }

  Color _getStatusCodeColor(int? code) {
    if (code == 200) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Widget _buildStatusCode(int? code) {
    return Text(
      ' $code',
      style: TextStyle(color: _getStatusCodeColor(code)),
    );
  }

  String _formatRequestTime(DateTime dateTime) {
    var format = DateFormat('yyyy-MM-dd hh:mm:ss');
    return format.format(dateTime);
  }

  Future<void> _showFilterDialog(String url) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter request by: $url'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RequestHistoryFilterPage(
                      url: url,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
