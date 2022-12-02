import 'package:flutter/material.dart';
import 'package:lib_network/lib_network.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.title, {super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();

  final String _url = 'https://api.github.com/users';

  @override
  void initState() {
    super.initState();
    controller.text = _url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                navigationToRequestHistoryPage(context);
              },
              icon: const Icon(Icons.history)),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                _sendGetRequest();
              },
              child: const Text('Get Request')),
        ],
      ),
    );
  }

  _sendGetRequest() async {
    var response = await HttpUtils.get('/users/octocat/orgs');
    print('response is $response');
  }
}
