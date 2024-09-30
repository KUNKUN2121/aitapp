import 'package:flutter/material.dart';

class ClassInfoSharedFiles extends StatelessWidget {
  const ClassInfoSharedFiles({super.key});

  @override
  Widget build(BuildContext context) {
    // ダミーデータ
    final List<Map<String, String>> files = [
      {'icon': '📁', 'label': 'File 1'},
      {'icon': '📁', 'label': 'File 2'},
      {'icon': '📁', 'label': 'File 3'},
      {'icon': '📁', 'label': 'File 4'},
      {'icon': '📁', 'label': 'File 5'},
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // ファイルの水平リスト部分
            SizedBox(
              height: 100, // アイテムの高さを調整
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              files[index]['icon']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(files[index]['label']!),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
