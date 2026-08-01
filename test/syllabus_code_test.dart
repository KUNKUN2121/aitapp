import 'package:aitapp/domain/features/lcam_parse.dart';
import 'package:aitapp/domain/types/disp_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DispCode.tryParse', () {
    test('授業コード_クラスコード を分解する', () {
      final code = DispCode.tryParse('K1018000_X1');
      expect(code?.subjectCode, 'K1018000');
      expect(code?.classCode, 'X1');
      expect(code?.searchWord, 'K1018000 X1');
    });

    test('アンダースコアが無い/端にある場合は null', () {
      expect(DispCode.tryParse('nounderscore'), isNull);
      expect(DispCode.tryParse('_X1'), isNull);
      expect(DispCode.tryParse('K1018000_'), isNull);
    });
  });

  group('normalizeSubjectName', () {
    test('時間割側とアンケート側の授業名が一致する', () {
      expect(
        LcamParse.normalizeSubjectName('コミュニカティブイングリッシュＤ'),
        LcamParse.normalizeSubjectName('[八]コミュニカティブイングリッシュＤ(49)'),
      );
      expect(
        LcamParse.normalizeSubjectName('卒業研究'),
        LcamParse.normalizeSubjectName('[八]卒業研究(X1)'),
      );
    });
  });

  group('subjectDispCodes', () {
    test('option をコード表に変換する', () {
      const html = '''
      <select id="subjectDispCode">
      <option value="" selected>▼選択してください</option>
      <option value="G1831000_49">[八]コミュニカティブイングリッシュＤ(49)</option>
      <option value="K1018000_X1">[八]卒業研究(X1)</option>
      </select>''';
      final codes = LcamParse().subjectDispCodes(html);
      expect(
        codes[LcamParse.normalizeSubjectName('卒業研究')]?.searchWord,
        'K1018000 X1',
      );
      expect(
        codes[LcamParse.normalizeSubjectName('コミュニカティブイングリッシュＤ')]?.searchWord,
        'G1831000 49',
      );
    });

    test('同名授業が別コードに割れる場合は null(曖昧回避)', () {
      const html = '''
      <select id="subjectDispCode">
      <option value="">▼選択してください</option>
      <option value="A0000000_11">[八]プログラミング(11)</option>
      <option value="A0000000_21">[八]プログラミング(21)</option>
      </select>''';
      final codes = LcamParse().subjectDispCodes(html);
      final key = LcamParse.normalizeSubjectName('プログラミング');
      expect(codes.containsKey(key), isTrue);
      expect(codes[key], isNull);
    });
  });
}
