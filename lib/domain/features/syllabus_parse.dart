import 'package:aitapp/domain/types/class_syllabus.dart';
import 'package:aitapp/domain/types/class_syllabus_detail.dart';
import 'package:aitapp/domain/types/classification.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/domain/types/syllabus_filters.dart';
import 'package:aitapp/domain/types/teacher.dart';
import 'package:collection/collection.dart';
import 'package:universal_html/html.dart';
import 'package:universal_html/parsing.dart';

class SyllabusParse {
  String cookie(Map<String, String> headers) {
    final setCookie = _getSetCookie(headers);
    if (setCookie.isNotEmpty) {
      for (final cookie in setCookie.split(RegExp(',(?=[^ ])'))) {
        return cookie.split(';')[0];
      }
    }
    return '';
  }

  SyllabusFilters filters(String body) {
    final rows = parseHtmlDocument(body).querySelectorAll(
      'body > form > table:nth-child(1) > tbody > tr > td > table > tbody > tr',
    );
    return SyllabusFilters(
      year: _extractOptions(rows, '年度'),
      folder: _extractOptions(rows, 'フォルダ'),
      campus: _extractOptions(rows, '校舎区分'),
      hour: _extractOptions(rows, '時限'),
      week: _extractOptions(rows, '曜日'),
      semester: _extractOptions(rows, '開講学期'),
    );
  }

  Map<String, String> _extractOptions(List<Element> rows, String filterName) {
    final options = <String, String>{};
    final row = rows.firstWhereOrNull(
      (r) => r.querySelector('td:nth-child(1)')?.text?.trim() == filterName,
    );
    if (row != null) {
      final optionElements =
          row.querySelectorAll('td:nth-child(2) > div > select > option');
      var i = 0;
      for (final option in optionElements) {
        if (i != 0) {
          options[option.text!] = option.attributes['value']!;
        }
        i++;
      }
    } else {
      throw const GetDataException('[parseSyllabusFilters]データの取得に失敗しました');
    }
    return options;
  }

  List<ClassSyllabus> searchList(String body) {
    final classSyllabusList = <ClassSyllabus>[];
    final rows = parseHtmlDocument(body).querySelectorAll(
      'body > form > table:nth-child(2) > tbody > tr > td > table > tbody > tr',
    );
    final error = parseHtmlDocument(body)
        .querySelector(
          '#errorTag > li',
        )
        ?.childNodes[0];
    if (rows.isEmpty) {
      if (error != null) {
        throw const NotFoundException(
          '検索条件と十分に一致する結果が見つかりません。\n条件を変えて再度検索してください',
        );
      } else {
        throw const GetDataException('[parseSyllabusList]データの取得に失敗しました');
      }
    }
    for (var i = 1; i < rows.length; i++) {
      //1授業単位
      final row = rows[i];
      final texts = _extractText(row);
      classSyllabusList.add(
        ClassSyllabus(
          int.tryParse(texts[11]) ?? 0, // 単位数
          _parseClassification(texts[10].trim()), // 区分
          texts[5].trim(), // 教員名
          texts[3].trim(), // 教科
          _extractUrl(row), //詳細URL
        ),
      );
    }
    return classSyllabusList;
  }

  String _extractUrl(Element row) {
    final linkElement = row.querySelector(
      'td > a',
    );
    return linkElement?.attributes['onclick']?.split("'")[1] ?? '';
  }

  List<String> _extractText(Element row) {
    final texts = <String>[];
    final infomations = row.querySelectorAll('td'); //1授業の枠の中の情報をリストで取得
    for (final info in infomations) {
      if (info.children.isNotEmpty) {
        texts.add(
          info.querySelector('div')?.text?.replaceAll('\n', '').trim() ?? '?',
        );
      } else {
        texts.add(info.text?.replaceAll('\n', '').trim() ?? '?');
      }
    }
    return texts;
  }

  Classification _parseClassification(String text) {
    switch (text.trim()) {
      case '選必':
        return Classification.requiredElective;
      case '選択':
        return Classification.choice;
      case '必修':
        return Classification.required;
      default:
        return Classification.unknown;
    }
  }

  List<String> _extractDetailText(ElementList<Element> rows) {
    final texts = <String>[];
    for (final tr in rows) {
      final tds = tr.querySelectorAll('td');
      var index = 0;
      for (final tdtext in tds) {
        if (index == 0) {
          for (final text in tdtext.text!
              .replaceAll('	', '')
              .replaceAll(' ', '')
              .trim()
              .split('\n')) {
            if (text != '' && text != ' ') {
              texts.add(text);
              if (text == '計画') {
                index = 1;
              }
            }
          }
        } else {
          final contents = tdtext.nodes;
          for (final content in contents) {
            final text = content.text!.trim();
            if (text != '') {
              texts.add(text);
              // print(text);
            }
          }
          index = 0;
        }
      }
    }
    return texts;
  }

  List<String> _extractExpain(
    Map<String, int> explainsIndex,
    List<String> texts,
    String text,
  ) {
    var i = explainsIndex[text]! + 1;
    final result = <String>[];
    while (explainsIndex[texts[i]] == null && texts.length > i) {
      result.add(texts[i]);
      i++;
    }
    if (result.isEmpty) {
      result.add('不明');
    }

    return result;
  }

  Map<String, int> _makeIndex(List<String> texts) {
    final explains = [
      '科目名',
      '担当教員',
      '研究室・オフィスアワー',
      'メールアドレス',
      '対象学年',
      'クラスコード',
      '講義室（キャンパス）',
      '開講学期',
      '曜日・時限',
      '単位区分',
      '科目種別',
      '単位数',
      '準備事項',
      '備考',
      '概要',
      'ディプロマ・ポリシー',
      '実施形態',
      '計画',
      '教科書',
      '参考書',
      '学習到達目標',
      '方法と特徴',
      '成績評価の方法',
      '教員からのメッセージ',
      'アクティブ・ラーニング科目',
      '実務経験に基づく教育内容',
      '添付ファイル(5MBまで）',
    ];
    final explainsIndex = explains
        .asMap()
        .map((key, value) => MapEntry(value, texts.indexOf(value)));
    return explainsIndex;
  }

  ClassSyllabusDetail detail(String body) {
    final rows = parseHtmlDocument(body).querySelectorAll(
      'body > table:nth-child(16) > tbody > tr > td > table > tbody > tr',
    );
    if (rows.isEmpty) {
      throw const GetDataException('[parseSyllabus]データの取得に失敗しました');
    }
    final texts = _extractDetailText(rows);
    final explainsIndex = _makeIndex(texts);

    final teachers = <Teacher>[];
    final teacherList = _extractExpain(explainsIndex, texts, '担当教員');
    for (var i = 0; i < teacherList.length; i += 3) {
      teachers.add(Teacher(name: teacherList[i], ruby: teacherList[i + 1]));
    }
    return ClassSyllabusDetail(
      int.tryParse(_extractExpain(explainsIndex, texts, '単位数')[0]) ?? 0,
      _parseClassification(_extractExpain(explainsIndex, texts, '単位区分')[0]),
      teachers,
      _extractExpain(explainsIndex, texts, '開講学期')[0],
      _extractExpain(explainsIndex, texts, '概要'),
      _extractExpain(explainsIndex, texts, '科目名')[2],
      _extractExpain(explainsIndex, texts, '曜日・時限')[0],
      _extractExpain(explainsIndex, texts, '講義室（キャンパス）')[0],
      _extractExpain(explainsIndex, texts, '計画'),
      _extractExpain(explainsIndex, texts, '学習到達目標')[0],
      _extractExpain(explainsIndex, texts, '方法と特徴')[0],
      _extractExpain(explainsIndex, texts, '成績評価の方法')[0],
      _extractExpain(explainsIndex, texts, '教員からのメッセージ')[0],
      _extractExpain(explainsIndex, texts, '教科書')[0],
      _extractExpain(explainsIndex, texts, '参考書')[0],
    );
  }

  String _getSetCookie(Map<String, dynamic> headers) {
    for (final key in headers.keys) {
      // システムによって返却される "set-cookie" のケースはバラバラです。
      if (key.toLowerCase() == 'set-cookie') {
        return headers[key] as String;
      }
    }

    return '';
  }
}
