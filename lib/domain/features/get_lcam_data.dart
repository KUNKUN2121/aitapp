import 'dart:io';

import 'package:aitapp/domain/features/lcam_parse.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/cookies.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/domain/types/notice.dart';
import 'package:aitapp/domain/types/notice_detail.dart';
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
        isCommon: isCommon,
      );
      token = parse.lCamStrutsToken(
        body: await getNoticeBody(
          cookies: cookies,
          token: tempToken,
          isCommon: isCommon,
        ),
        isCommon: isCommon,
      );
    }

    final body = await getNoticeBodyNext(
      cookies: cookies,
      token: token!,
      pageNumber: page,
      isCommon: isCommon,
    );
    token = parse.lCamStrutsToken(body: body, isCommon: isCommon);

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
