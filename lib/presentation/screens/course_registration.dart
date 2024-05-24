import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/presentation/screens/webview.dart';
import 'package:flutter/material.dart';

class CourseRegistration extends StatelessWidget {
  const CourseRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('履修/アンケート/成績')),
      body: ListView(
        children: [
          for (final webAccessLink in webAccessLinks) ...{
            ListTile(
              title: Text(webAccessLink.title),
              leading: Icon(webAccessLink.icon),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (ctx) => WebViewScreen(
                      title: webAccessLink.title,
                      url: webAccessLink.url,
                    ),
                  ),
                );
              },
            ),
          },
        ],
      ),
    );
  }
}
