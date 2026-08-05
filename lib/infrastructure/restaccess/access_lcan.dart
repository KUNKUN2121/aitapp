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
const _httpTimeout = Duration(seconds: 30);

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

Future<String> getSchedule({required Cookies cookie}) async {
  debugPrint('getSchedule');
  final headers = {
    'Origin': 'https://$origin',
    'Cookie': cookie.toString(),
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    '_mode': '5',
    'EXCLUDE_SET': '',
  };

  final url = Uri.parse(
    'https://$origin/portalv2/schedule/scheduleForHome/getSchedule',
  );

  final res = await httpAccess(url, headers: headers, body: data);

  return res.body;
}

Future<String> reload({
  required Cookies cookie,
  required String token,
}) async {
  debugPrint('reload');
  final headers = {
    'Origin': 'https://$origin',
    'Cookie': cookie.toString(),
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'org.apache.struts.taglib.html.TOKEN': token,
    '_screenIdentifier': 'home',
    '_screenInfoDisp': '',
    '_scrollTop': '148',
  };

  final url = Uri.parse('https://$origin/portalv2/home/home/reload');

  final res = await httpAccess(url, headers: headers, body: data);

  return res.body;
}

Future<String> preAccess({required Cookies cookie}) async {
  debugPrint('preAccess');
  final url = Uri.parse('https://$origin/portalv2/login/preLogin/preLogin');
  final headers = {
    'Origin': 'https://$origin',
    'Referer': 'https://$origin/',
    'Cookie': cookie.toString(),
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'mistakeChecker': '0',
    'clientLocationUrl': 'https://$origin/',
  };

  final res = await httpAccess(url, headers: headers, body: data);

  final setCookie = _getSetCookie(res.headers);
  return setCookie;
}

Future<String> initLogin({
  required String id,
  required String password,
  required Cookies cookies,
}) async {
  debugPrint('initLogin');
  final headers = {
    'Origin': 'https://$origin',
    'Referer': 'https://$origin/portalv2/',
    'Cookie': cookies.toString(),
  }
    ..addAll(constHeader)
    ..addAll(secFetchHeader)
    ..addAll(contentTypeHeader);

  final data = {
    'userID': id,
    'password': password,
    'selectLocale': 'ja',
    'authenticMethod': '1',
    'mistakeChecker': '0',
    'EXCLUDE_SET': '',
  };

  final url = Uri.parse('https://$origin/portalv2/login/login/initLogin');

  final res = await http.post(url, headers: headers, body: data);
  return res.body;
}

Future<String> generalPurpose({
  required Cookies cookies,
  required String token,
}) async {
  final headers = {
    'Origin': 'https://$origin',
    'Referer': 'https://$origin/portalv2/login/login/initLogin',
    'Cookie': cookies.toString(),
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
    'Cookie': cookies.toString(),
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
    'Cookie': cookies.toString(),
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
    'Cookie': cookies.toString(),
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

Future<Cookies> pcGetCookie() async {
  debugPrint('pcgetcookie');
  final url = Uri.parse('https://$origin/portalv2/');
  final headers = <String, String>{}
    ..addAll(constHeader)
    ..addAll(secFetchHeader);

  final res = await httpAccess(url, headers: headers);

  final setCookie = _getSetCookie(res.headers);
  final cookies = setCookie.split(RegExp(',(?=[^ ])'));
  return Cookies(jSessionId: cookies[0], liveAppsCookie: cookies[1]);
}

Future<String> getPortalTop({required Cookies cookies}) async {
  debugPrint('getPortalTop');
  final headers = {
    'Cookie': cookies.toString(),
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

  final setCookie = _getSetCookie(res.headers);
  final cookies = setCookie.split(RegExp(',(?=[^ ])'));
  return Cookies(jSessionId: cookies[0], liveAppsCookie: cookies[1]);
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
    'Cookie': cookies.toString(),
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
    'Cookie': cookies.toString(),
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
    'Cookie': cookies.toString(),
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
    'Cookie': cookies.toString(),
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
    'Cookie': cookies.toString(),
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
    'Cookie': cookies.toString(),
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

Future<Response> getFile({
  required Cookies cookies,
  required String fileUrl,
}) async {
  debugPrint('getfile');
  final headers = {
    'Cookie': cookies.toString(),
  }..addAll(constHeader);
  final url = Uri.parse('https://$origin$fileUrl');

  final res = await httpAccess(url, headers: headers);

  return res;
}

String _getSetCookie(Map<String, dynamic> headers) {
  for (final header in headers.entries) {
    // システムによって返却される "set-cookie" のケースはバラバラ

    String? jSessionId;
    String? liveAppCookie;

    if (header.key.toLowerCase() == 'set-cookie') {
      if (header.value.toString().toLowerCase().contains('jsessionid') &&
          header.value.toString().toLowerCase().contains('liveapps-cookie')) {
        return header.value as String;
      } else if (header.value.toString().toLowerCase().contains('jsessionid')) {
        jSessionId = (header.value as String).split(',').last;
      } else if (header.value
          .toString()
          .toLowerCase()
          .contains('liveapps-cookie')) {
        liveAppCookie = header.value as String;
      }
      if (jSessionId != null && liveAppCookie != null) {
        return '$jSessionId, $liveAppCookie';
      } else if (jSessionId != null) {
        return jSessionId;
      } else if (liveAppCookie != null) {
        return liveAppCookie;
      }
    }
  }

  return '';
}
