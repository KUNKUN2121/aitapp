// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';

import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/domain/types/cookies.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/domain/types/identity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

/// SSOサインインに失敗したときにスローされる (認証失敗・混雑など)。
class SsoException implements Exception {
  SsoException(this.message);
  final String message;

  @override
  String toString() => message;
}

const constHeader = {
  'Accept-Language': 'ja',
  'Connection': 'keep-alive',
  'Accept-Encoding': 'gzip',
  'Accept': '*/*',
};
const secFetchHeader = {
  'Sec-Fetch-Site': 'same-origin',
  'Sec-Fetch-Mode': 'navigate',
  'Sec-Fetch-Dest': 'document',
};
const contentTypeHeader = {
  'Content-Type': 'application/x-www-form-urlencoded',
};

/// 1リクエストあたりのタイムアウト。無応答で「ずっとロード」になるのを防ぐ。
/// 再認証(SSO)のユーザー操作待ちには掛からない(HTTPリクエスト単位のため)。
const _httpTimeout = Duration(seconds: 15);

Future<Response> httpAccess(
  Uri uri, {
  required Map<String, String> headers,
  Map<String, String>? body,
}) async {
  late final Response res;
  try {
    if (body != null) {
      res = await http
          .post(uri, headers: headers, body: body)
          .timeout(_httpTimeout);
    } else {
      res = await http.get(uri, headers: headers).timeout(_httpTimeout);
    }
  } on TimeoutException {
    throw const GetDataException('通信がタイムアウトしました。電波状況を確認してください');
  }
  if (res.statusCode != 200) {
    throw Exception('http.get error: statusCode= ${res.statusCode}');
  }
  return res;
}

Future<String> generalPurpose({
  required Cookies cookies,
  required String token,
}) async {
  final headers = {
    'Origin': 'https://$origin',
    'Referer': 'https://$origin/portalv2/login/login/initLogin',
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'org.apache.struts.taglib.html.TOKEN': token,
    'headTitle': 'ホーム',
    'menuCode': 'A00',
    'nextPath': '/classsupporttop/classSupportTop/initialize',
    '_screenIdentifier': '',
    '_screenInfoDisp': '',
    '_scrollTop': '0',
  };

  final url = Uri.parse('https://$origin/portalv2/common/generalPurpose/');

  final res = await httpAccess(url, headers: headers, body: data);
  return res.body;
}

Future<String> searchTimeTable({
  required Cookies cookies,
  required String token,
  required String year,
  required String semester,
}) async {
  final headers = {
    'Origin': 'https://$origin',
    'Referer': 'https://$origin/portalv2/common/generalPurpose/',
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'org.apache.struts.taglib.html.TOKEN': token,
    'schoolYear': year,
    'semesterCode': semester,
    '_screenIdentifier': 'SC_A00_01',
    '_screenInfoDisp': '',
    '_scrollTop': '494',
  };

  final url = Uri.parse(
    'https://$origin/portalv2/portaltopcommon/timeTableForTop/searchTimeTable',
  );

  final res = await httpAccess(url, headers: headers, body: data);
  return res.body;
}

/// 授業アンケート一覧ページを取得する。
///
/// レスポンスHTMLに埋め込まれた Struts トークンを使って
/// [selectSubjectInfoList] で年度・学期ごとの授業コード一覧を取得する。
Future<String> getClassEnqueteBody({required Cookies cookies}) async {
  debugPrint('getClassEnqueteBody');
  final headers = {
    'Cookie': cookies.header,
    'Referer':
        'https://$origin/portalv2/smartphone/smartPhoneHome/nextPage/contactNotice',
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader);

  final url = Uri.parse(
    'https://$origin/portalv2/smartphone/smartPhoneContactNotice/nextPage/classEnquete',
  );

  final res = await httpAccess(url, headers: headers);
  return res.body;
}

/// 指定年度・学期の授業アンケート対象科目(subjectDispCode)一覧を取得する。
///
/// レスポンスHTMLには `#subjectDispCode` の option 群と、次リクエスト用の
/// 新しい Struts トークンが含まれる。
Future<String> selectSubjectInfoList({
  required Cookies cookies,
  required String token,
  required String year,
  required String semester,
}) async {
  debugPrint('selectSubjectInfoList');
  final headers = {
    'Origin': 'https://$origin',
    'Referer':
        'https://$origin/portalv2/smartphone/smartPhoneContactNotice/nextPage/classEnquete',
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'org.apache.struts.taglib.html.TOKEN': token,
    'schoolYear': year,
    'semesterCode': semester,
    'subjectDispCode': '',
    'titleSearch': '',
    'listPageNo': '1',
  };

  final url = Uri.parse(
    'https://$origin/portalv2/smartphone/smartPhoneClassEnqList/selectSubjectInfoList/',
  );

  final res = await httpAccess(url, headers: headers, body: data);
  return res.body;
}

Future<String> getPortalTop({required Cookies cookies}) async {
  debugPrint('getPortalTop');
  final headers = {
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader);

  final url = Uri.parse('https://$origin/portalv2/');

  final res = await httpAccess(url, headers: headers);
  return res.body;
}

Future<Cookies> getCookie() async {
  debugPrint('getcookie');
  final url = Uri.parse('https://$origin/portalv2/sp');
  final headers = <String, String>{}
    ..addAll(constHeader)
    ..addAll(secFetchHeader);

  final res = await httpAccess(url, headers: headers);

  return _parseCookies(res.headers);
}

Future<bool> canLoginLcam({
  required String id,
  required String password,
}) async {
  debugPrint('canLoginLcam');
  final headers = <String, String>{}
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'userId': id,
    'password': password,
  };

  final url = Uri.parse('https://$origin/portalv2/login/login/spAppLogin/');

  final res = await httpAccess(url, headers: headers, body: data);
  final json = jsonDecode(res.body) as Map;
  if (json['status'] == 'success') {
    return true;
  }
  return false;
}

/// SSOで取得した `key` を spAppLogin にPOSTし、ID/仮パスワードを取得する。
///
/// アプリ内WebViewでSSOサインインを行い、`lamyapp://lcam?key=xxxx` への遷移を
/// 横取りして得た `key` を渡す。認証失敗・混雑時は [SsoException] をスローする。
Future<Identity> ssoExchangeKey({required String key}) async {
  debugPrint('ssoExchangeKey');
  final headers = <String, String>{}
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  // keyをuserIdに、passwordは空文字で送る
  final data = {
    'userId': key,
    'password': '',
  };

  final url = Uri.parse('https://$origin/portalv2/login/login/spAppLogin/');

  final res = await httpAccess(url, headers: headers, body: data);
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  // 仮パスワード・学籍番号を含む body 全体は出さない(結果ステータスのみ)。
  debugPrint('[ssoExchangeKey] status=${res.statusCode} result=${json['status']}');
  if (json['status'] == 'success') {
    return Identity(
      id: json['userId'] as String,
      password: json['password'] as String,
    );
  }
  if (json['status'] == 'stop_login') {
    throw SsoException('ただいま混み合っております。しばらくしてからもう一度お試しください。');
  }
  throw SsoException(
    (json['errorMessage'] as String?) ?? '愛工大IDまたはパスワードが正しくありません。',
  );
}

Future<String> loginLcam({
  required String id,
  required String password,
  required Cookies cookies,
}) async {
  debugPrint('loginlcam');
  final headers = {
    'Origin': 'https://$origin',
    'Referer': 'https://$origin/portalv2/sp',
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'userID': id,
    'password': password,
    'selectLocale': 'ja',
    'mode': 'sp',
    'userDivision': '2',
    'spFlg': '1',
    'locale': 'ja',
    'spAppFlag': '1',
    'clientLocationUrl': 'https://$origin/',
  };

  final url = Uri.parse(
    'https://$origin/portalv2/login/login/smartPhoneLogin',
  );

  final res = await httpAccess(url, headers: headers, body: data);
  return res.body;
}

Future<String> getStrutsToken({
  required Cookies cookies,
  required bool isCommon,
}) async {
  debugPrint('gettoken');
  String contactType;
  if (isCommon) {
    contactType = 'commonContact';
  } else {
    contactType = 'classContact';
  }
  final headers = {
    'Cookie': cookies.header,
    'Referer':
        'https://$origin/portalv2/smartphone/smartPhoneHome/nextPage/contactNotice',
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader);

  final url = Uri.parse(
    'https://$origin/portalv2/smartphone/smartPhoneContactNotice/nextPage/$contactType',
  );

  final res = await httpAccess(url, headers: headers);
  return res.body;
}

Future<String> getNoticeBody({
  required Cookies cookies,
  required String token,
  required bool isCommon,
}) async {
  final noticeType = isCommon ? 'Common' : 'Class';
  debugPrint('get${noticeType}NoticeBody');
  final headers = {
    'Origin': 'https://$origin',
    'Referer':
        'https://$origin/portalv2/smartphone/smartPhoneContactNotice/nextPage/${noticeType.toLowerCase()}Contact',
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'org.apache.struts.taglib.html.TOKEN': token,
    'unReadFlg': '1',
    'listPageNo': '1',
    '_screenIdentifier': 'smartPhone${noticeType}ContactList',
    '_scrollTop': '0',
  };

  final url = Uri.parse(
    'https://$origin/portalv2/smartphone/smartPhone${noticeType}Contact/select${noticeType}ContactList',
  );

  final res = await httpAccess(url, headers: headers, body: data);

  return res.body;
}

Future<String> getNoticeBodyNext({
  required Cookies cookies,
  required String token,
  required int pageNumber,
  required bool isCommon,
}) async {
  final noticeType = isCommon ? 'Common' : 'Class';
  debugPrint('get${noticeType}NoticeBodyNext');
  final headers = {
    'Origin': 'https://origin',
    'Referer':
        'https://$origin/portalv2/smartphone/smartPhone${noticeType}Contact/select${noticeType}ContactList',
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'org.apache.struts.taglib.html.TOKEN': token,
    'unReadFlg': '1',
    'listPageNo': '$pageNumber',
    '_screenIdentifier': 'smartPhone${noticeType}ContactList',
    '_scrollTop': '0',
  };

  final url = Uri.parse(
    'https://$origin/portalv2/smartphone/smartPhone${noticeType}Contact/nextSelect${noticeType}ContactList',
  );

  final res = await httpAccess(url, headers: headers, body: data);

  return res.body;
}

Future<String> getClassTimeTableBody({required Cookies cookies}) async {
  debugPrint('getClassTimeTableBody');
  final headers = {
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader);

  final url = Uri.parse(
    'https://$origin/portalv2/smartphone/smartPhoneHome/nextPage/timeTable',
  );

  final res = await httpAccess(url, headers: headers);

  return res.body;
}

Future<String> getNoticeDetailBody({
  required int index,
  required Cookies cookies,
  required String token,
  required bool isCommon,
}) async {
  final noticeType = isCommon ? 'Common' : 'Class';
  debugPrint('get${noticeType}NoticeDetailBody');
  final headers = {
    'Origin': 'https://origin',
    'Referer':
        'https://$origin/portalv2/smartphone/smartPhone${noticeType}Contact/nextSelect${noticeType}ContactList',
    'Cookie': cookies.header,
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'org.apache.struts.taglib.html.TOKEN': token,
    '_screenIdentifier': 'smartPhone${noticeType}ContactList',
    '_scrollTop': '0',
  };

  final url = Uri.parse(
    'https://$origin/portalv2/smartphone/smartPhone${noticeType}Contact/goDetail/$index',
  );

  final res = await httpAccess(url, headers: headers, body: data);
  return res.body;
}

/// 通知の targetUrl(例:
/// `portalv2/smartphone/smartPhoneCommonContactDetail/detail/330848`)が指す
/// 学内連絡詳細ページを、認証済みCookieで直接取得する。
///
/// 一覧経由の [getNoticeDetailBody]（index/token 依存の POST）とは別エンドポイント
/// だが、返るHTMLは同じ詳細テンプレートのため既存パーサでそのまま整形できる。
Future<String> getNoticeDetailBodyByPath({
  required String path,
  required Cookies cookies,
}) async {
  debugPrint('getNoticeDetailBodyByPath: $path');
  final headers = {
    'Referer': 'https://$origin/portalv2/',
    'Cookie': cookies.header,
  }..addAll(constHeader);
  final normalized = path.startsWith('/') ? path : '/$path';
  final url = Uri.parse('https://$origin$normalized');
  final res = await httpAccess(url, headers: headers);
  return res.body;
}

Future<Response> getFile({
  required Cookies cookies,
  required String fileUrl,
}) async {
  debugPrint('getfile');
  final headers = {
    'Cookie': cookies.header,
  }..addAll(constHeader);
  final url = Uri.parse('https://$origin$fileUrl');

  final res = await httpAccess(url, headers: headers);

  return res;
}

/// レスポンスの set-cookie から `JSESSIONID` と `LiveApps-Cookie` の**値だけ**を
/// 名前で抜き出す。
///
/// set-cookie は環境により1ヘッダに `,` 連結されたり別々に返ったりするため、
/// 全 set-cookie を連結してから名前一致で拾う(順序・属性・大文字小文字に依存しない)。
Cookies _parseCookies(Map<String, dynamic> headers) {
  final raw = headers.entries
      .where((e) => e.key.toLowerCase() == 'set-cookie')
      .map((e) => e.value.toString())
      .join(', ');

  String pick(String name) {
    final match = RegExp('$name=([^;,\\s]+)', caseSensitive: false)
        .firstMatch(raw);
    return match?.group(1) ?? '';
  }

  return Cookies(
    jsessionid: pick('JSESSIONID'),
    liveApps: pick('LiveApps-Cookie'),
  );
}
