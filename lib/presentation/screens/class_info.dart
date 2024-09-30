import 'package:aitapp/presentation/wighets/class_info_shared_files.dart';
import 'package:aitapp/presentation/wighets/notice_class_info_page.dart';
import 'package:aitapp/presentation/wighets/notice_tab_page.dart';
import 'package:flutter/material.dart';
import 'package:aitapp/domain/types/class.dart';

class ClassInfo extends StatelessWidget {
  const ClassInfo({
    super.key,
    required this.clas,
  });

  final Class clas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(clas.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "教室: ${clas.classRoom!}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "担当教員: ${clas.teacher}",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                "授業連絡",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 170, // お知らせを表示するスペースの高さ
                child: NoticeClassInfoPage(isCommon: false, clas: clas),
              ),
              SizedBox(height: 20),
              Text(
                "授業共有ファイル",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 130,
                child: ClassInfoSharedFiles(),
              ),
              SizedBox(height: 20),
              Text(
                "レポート",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ReportSection(reports: [
                ReportItem(
                    status: "提出済",
                    title: "レポート1",
                    dateRange: "24/08/24 - 24/08/27"),
                ReportItem(
                    status: "募集中",
                    title: "レポート2",
                    dateRange: "24/08/24 - 24/08/27"),
                ReportItem(
                    status: "締切",
                    title: "レポート3",
                    dateRange: "24/08/24 - 24/08/27"),
              ]),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // シラバスページへの遷移処理
                },
                child: Text(
                  "シラバスを見る",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final String content;

  const SectionCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportSection extends StatelessWidget {
  final List<ReportItem> reports;

  const ReportSection({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reports.map((report) {
        return Card(
          child: ListTile(
            title: Text("【${report.status}】 ${report.title}"),
            subtitle: Text(report.dateRange),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // レポート詳細ページへの遷移処理
            },
          ),
        );
      }).toList(),
    );
  }
}

class ReportItem {
  final String status;
  final String title;
  final String dateRange;

  ReportItem({
    required this.status,
    required this.title,
    required this.dateRange,
  });
}
