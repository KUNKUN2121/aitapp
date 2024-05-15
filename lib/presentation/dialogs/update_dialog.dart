import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'アプリのアップデートがあります',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        // ボタン領域
        ElevatedButton(
          child: const Text('後で'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            launchUrl(
              Uri.parse(
                'https://github.com/piman528/aitapp/releases/latest',
              ),
            );
          },
        ),
      ],
    );
  }
}
