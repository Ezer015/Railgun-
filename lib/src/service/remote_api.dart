// import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cronet_http/cronet_http.dart';
// import 'package:crypto/crypto.dart';

enum RemoteApiPath {
  // wbi,
  search,
  audioInfo,
  audioStream,
  userInfo,
  userSpace,
}

class RemoteApi {
  static final RemoteApi _instance = RemoteApi._();

  factory RemoteApi() => _instance;

  RemoteApi._()
      : _client = CronetClient.fromCronetEngine(
          CronetEngine.build(
            cacheMode: CacheMode.memory,
            cacheMaxSize: 32 * 1024 * 1024,
          ),
          closeEngine: true,
        );

  static Future<void> init() async {
    final response =
        await _instance._client.get(Uri.parse(_headers['Referer']!));
    _headers['Cookie'] = response.headers['set-cookie']!;
    // _instance._client.get(getBaseUri(RemoteApiPath.wbi)).then((response) {
    //   final responseJson = json.decode(response.body);

    //   final imgKey = (responseJson['data']['wbi_img']['img_url'] as String)
    //       .split('/')
    //       .last
    //       .split('.')
    //       .first;
    //   final subKey = (responseJson['data']['wbi_img']['sub_url'] as String)
    //       .split('/')
    //       .last
    //       .split('.')
    //       .first;
    //   final rawWbiKey = imgKey + subKey;

    //   _wbiKey = mixinKeyEncryptionTable
    //       .map((i) => rawWbiKey[i])
    //       .join()
    //       .substring(0, 32);
    // });
  }

  static const base = 'api.bilibili.com';
  static const accountBase = 'api.vc.bilibili.com';
  static final Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0',
    'Referer': 'https://www.bilibili.com',
  };
  // static const mixinKeyEncryptionTable = [
  //   46,
  //   47,
  //   18,
  //   2,
  //   53,
  //   8,
  //   23,
  //   32,
  //   15,
  //   50,
  //   10,
  //   31,
  //   58,
  //   3,
  //   45,
  //   35,
  //   27,
  //   43,
  //   5,
  //   49,
  //   33,
  //   9,
  //   42,
  //   19,
  //   29,
  //   28,
  //   14,
  //   39,
  //   12,
  //   38,
  //   41,
  //   13,
  //   37,
  //   48,
  //   7,
  //   16,
  //   24,
  //   55,
  //   40,
  //   61,
  //   26,
  //   17,
  //   0,
  //   1,
  //   60,
  //   51,
  //   30,
  //   4,
  //   22,
  //   25,
  //   54,
  //   21,
  //   56,
  //   59,
  //   6,
  //   63,
  //   57,
  //   62,
  //   11,
  //   36,
  //   20,
  //   34,
  //   44,
  //   52
  // ];
  // static late final String _wbiKey;
  final http.Client _client;

  static Map<String, String> get headers => _headers;
  static String getPath(RemoteApiPath path) => switch (path) {
        // RemoteApiPath.wbi => 'x/web-interface/nav',
        RemoteApiPath.search => 'x/web-interface/search/type',
        RemoteApiPath.audioInfo => 'x/web-interface/view',
        RemoteApiPath.audioStream => 'x/player/playurl',
        RemoteApiPath.userInfo => 'account/v1/user/cards',
        RemoteApiPath.userSpace => 'x/series/recArchivesByKeywords',
      };
  static Uri getBaseUri(
    RemoteApiPath path, {
    Map<String, String>? query,
  }) {
    final apiBase = path == RemoteApiPath.userInfo ? accountBase : base;
    return Uri.https(apiBase, getPath(path), query);
  }

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async =>
      _instance._get(url, headers: headers);

  Future<http.Response> _get(
    Uri url, {
    Map<String, String>? headers,
  }) async =>
      await _client.get(url, headers: {..._headers, ...?headers});

  static Future<http.Response> getBaseSrc(
    RemoteApiPath path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async =>
      await get(getBaseUri(path, query: query), headers: headers);

  // static Map<String, String> encryptWbi(Map<String, String>? query) =>
  //     _instance._encryptWbi(query);
  // Map<String, String> _encryptWbi(Map<String, String>? query) {
  //   query ??= {};

  //   query['wts'] =
  //       (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

  //   query = Map.fromEntries(
  //     query.entries.toList()
  //       ..sort(
  //         (a, b) => a.key.compareTo(b.key),
  //       ),
  //   ).map(
  //     (k, v) => MapEntry(
  //       k,
  //       v.replaceAll(RegExp(r"[!'()*]"), ''),
  //     ),
  //   );

  //   query['w_rid'] = md5
  //       .convert(
  //         utf8.encode(
  //           Uri(queryParameters: query).query + _wbiKey,
  //         ),
  //       )
  //       .toString();

  //   return query;
  // }
}
