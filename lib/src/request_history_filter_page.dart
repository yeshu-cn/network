import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lib_network/src/request_record.dart';
import 'package:lib_network/src/http_request_detail_page.dart';
import 'package:lib_network/src/request_record_repository.dart';

class RequestHistoryFilterPage extends StatefulWidget {
  final String url;
  const RequestHistoryFilterPage({Key? key, required this.url}) : super(key: key);

  @override
  State<RequestHistoryFilterPage> createState() => _RequestHistoryFilterPageState();
}

class _RequestHistoryFilterPageState extends State<RequestHistoryFilterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.url),
      ),
      body: Scrollbar(
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            var record = RequestRecordRepository.getInstance().getRecordListByUrl(widget.url)[index];
            return _buildItem(record);
          },
          itemCount: RequestRecordRepository.getInstance().getRecordListByUrl(widget.url).length,
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
    return Text(' $code', style: TextStyle(color: _getStatusCodeColor(code)),);
  }

  String _formatRequestTime(DateTime dateTime) {
    var format = DateFormat('yyyy-MM-dd hh:mm:ss');
    return format.format(dateTime);
  }
}
