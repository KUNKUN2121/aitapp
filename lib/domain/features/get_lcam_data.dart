import 'dart:io';

import 'package:aitapp/domain/features/lcam_parse.dart';
import 'package:aitapp/domain/types/academic_year.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/cookies.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/disp_code.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/domain/types/notice.dart';
import 'package:aitapp/domain/types/notice_detail.dart';
import 'package:aitapp/domain/types/semester.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GetLcamData {
  late Cookies cookies;
  late String? token;
  final parse = LcamParse();

  Future<bool> create(String id, String password) async {
    token = null;
    cookies = await getCookie();
    return parse
        .isLogin(await loginLcam(id: id, password: password, cookies: cookies));
  }

  Future<List<Notice>> getNoticelist({
    required int page,
    required bool isCommon,
    required bool withLogin,
  }) async {
    if (withLogin) {
      final tempToken = parse.lCamStrutsToken(
        body: await getStrutsToken(
          cookies: cookies,
          isCommon: isCommon,
        ),
      );
      token = parse.lCamStrutsToken(
        body: await getNoticeBody(
          cookies: cookies,
          token: tempToken,
          isCommon: isCommon,
        ),
      );
    }

    final body = await getNoticeBodyNext(
      cookies: cookies,
      token: token!,
      pageNumber: page,
      isCommon: isCommon,
    );
    token = parse.lCamStrutsToken(body: body);

    if (isCommon) {
      return parse.univNotice(body);
    } else {
      return parse.classNotice(body);
    }
  }

  Future<NoticeDetail> getNoticeDetail({
    required int pageNumber,
    required bool isCommon,
  }) async {
    if (cookies.jSessionId.isEmpty) {
      throw Exception('ログインできません');
    }
    final body = await getNoticeDetailBody(
      index: pageNumber,
      cookies: cookies,
      token: token!,
      isCommon: isCommon,
    );
    if (isCommon) {
      return parse.univNoticeDetail(body);
    } else {
      return parse.classNoticeDetail(body);
    }
  }

  Future<File> shareFile(
    MapEntry<String, String> entry,
    BuildContext context,
  ) async {
    final response = await getFile(
      cookies: cookies,
      fileUrl: entry.value,
    );
    final contentType = response.headers['content-type']!;
    if (contentType != 'text/html;charset=utf-8') {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${entry.key}');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw const GetDataException('[shareFile]データの取得に失敗しました');
    }
  }

  Future<Map<DayOfWeek, Map<int, Class>>> getClassTimeTable() async {
    final body = await getClassTimeTableBody(cookies: cookies);
    return parse.classTimeTable(body);
  }
}

class GetPCLcamData {
  late Cookies cookies;
  late String? token;
  final parse = LcamParse();

  // pc版にログインする
  //
  // 仮パスワードではPC版ログイン(initLogin)ができないため、SP版ログインの
  // セッションCookieを流用してPC版ポータルにアクセスする。
  // /portalv2/ は認証済みでも見た目はログイン画面だが、そこに埋め込まれた
  // Strutsトークンを使えば generalPurpose 経由でPC版の各機能へ遷移できる
  // (playwright_lcam.py の go_home_via_cookie と同じ方式)。
  Future<bool> create(String id, String password) async {
    token = null;
    cookies = await getCookie();
    await loginLcam(id: id, password: password, cookies: cookies);
    final portalTop = await getPortalTop(cookies: cookies);
    token = parse.portalStrutsToken(portalTop);
    return true;
  }

  Future<Map<int, Map<Semester, Map<DayOfWeek, Map<int, Class>>>>>
      getClassTimeTable({
    void Function(int current, int total, String message)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final generalPurposeResult =
        await generalPurpose(cookies: cookies, token: token!);
    final result = <int, Map<Semester, Map<DayOfWeek, Map<int, Class>>>>{};
    token = LcamParse().lCamStrutsToken(body: generalPurposeResult);

    // 現在年度から過去にさかのぼって各学期を走査する。
    // 現在年度が履修0でも止まらず、データのある過去年度まで取得する。
    // (Strutsトークンは1リクエストごとに更新が必要なため毎回抽出する)
    const maxLookbackYears = 5;
    final currentYear = AcademicYear.getCurrent();
    // 進捗バーの分母。全年度×前期/後期を走査した場合の最大ステップ数。
    const totalSteps = (maxLookbackYears + 1) * 2;
    var step = 0;
    // 現在年度は履修が無くても必ず表示する(最新=空の時間割として出す)
    result[currentYear] = {
      Semester.early: {},
      Semester.late: {},
    };
    var foundAny = false;
    var emptyYearStreak = 0;

    // 授業アンケート一覧の初期トークンを取得しておく。
    // 取得できなければコード紐付けはスキップし、従来の時間割のみ返す。
    var enqueteToken = await _getEnqueteToken();

    for (var year = currentYear;
        year >= currentYear - maxLookbackYears;
        year--) {
      var yearHasData = false;
      for (final semester in [Semester.early, Semester.late]) {
        // リクエストの境目でキャンセルをチェックし、要求されていれば中断する。
        if (isCancelled?.call() ?? false) {
          throw const TimetableFetchCancelledException();
        }
        onProgress?.call(
          step,
          totalSteps,
          '$year年度 ${semester.displayName}を取得中…',
        );
        step++;
        final semesterCode = semester == Semester.early ? '1' : '2';
        final body = await searchTimeTable(
          cookies: cookies,
          token: token!,
          year: '$year',
          semester: semesterCode,
        );
        var timetable = <DayOfWeek, Map<int, Class>>{};
        try {
          timetable = LcamParse().pcClassTimeTable(body);
        } on Exception {
          timetable = {};
        }
        // 次リクエスト用にトークンを更新する
        token = LcamParse().lCamStrutsToken(body: body);
        if (timetable.isNotEmpty) {
          // 授業コード・クラスコードを紐付ける (トークンは繰り上げる)
          if (enqueteToken != null) {
            final enriched = await _enrichWithCodes(
              timetable: timetable,
              token: enqueteToken,
              year: '$year',
              semester: semesterCode,
            );
            timetable = enriched.timetable;
            enqueteToken = enriched.token;
          }
          result[year] ??= {Semester.early: {}, Semester.late: {}};
          result[year]![semester] = timetable;
          yearHasData = true;
          foundAny = true;
        }
      }
      if (yearHasData) {
        emptyYearStreak = 0;
      } else {
        emptyYearStreak++;
        // データが見つかった後に2年連続で空なら、それ以上さかのぼらない
        if (foundAny && emptyYearStreak >= 2) {
          break;
        }
      }
    }

    return result;
  }

  /// 授業アンケート一覧ページから初期 Struts トークンを取得する。
  /// アクセスできない場合は null を返し、コード紐付けをスキップする。
  Future<String?> _getEnqueteToken() async {
    try {
      final body = await getClassEnqueteBody(cookies: cookies);
      return parse.portalStrutsToken(body);
    } on Exception {
      return null;
    }
  }

  /// 指定年度・学期の授業コード一覧を取得し、時間割の各授業に付与する。
  /// 返り値には次リクエスト用に繰り上げたトークンを含める。
  Future<({Map<DayOfWeek, Map<int, Class>> timetable, String? token})>
      _enrichWithCodes({
    required Map<DayOfWeek, Map<int, Class>> timetable,
    required String token,
    required String year,
    required String semester,
  }) async {
    try {
      final body = await selectSubjectInfoList(
        cookies: cookies,
        token: token,
        year: year,
        semester: semester,
      );
      final codes = LcamParse().subjectDispCodes(body);
      final nextToken = LcamParse().portalStrutsToken(body);
      return (timetable: _applyCodes(timetable, codes), token: nextToken);
    } on Exception {
      // 取得失敗時はコード無しのまま、トークンも維持する
      return (timetable: timetable, token: token);
    }
  }

  /// 授業名の名寄せでコードを付与した時間割を返す。
  /// 一致しない/曖昧な授業はコード無しのまま(従来検索へフォールバック)。
  Map<DayOfWeek, Map<int, Class>> _applyCodes(
    Map<DayOfWeek, Map<int, Class>> timetable,
    Map<String, DispCode?> codes,
  ) {
    final result = <DayOfWeek, Map<int, Class>>{};
    for (final dayEntry in timetable.entries) {
      result[dayEntry.key] = <int, Class>{};
      for (final periodEntry in dayEntry.value.entries) {
        final clas = periodEntry.value;
        final dispCode = codes[LcamParse.normalizeSubjectName(clas.title)];
        result[dayEntry.key]![periodEntry.key] = dispCode == null
            ? clas
            : clas.copyWith(
                subjectCode: dispCode.subjectCode,
                classCode: dispCode.classCode,
              );
      }
    }
    return result;
  }
}
