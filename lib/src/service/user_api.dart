import 'dart:convert';

import '../models.dart';
import '../utils.dart';
import 'remote_api.dart';

class UserApi {
  UserApi({
    required this.uid,
    this.tag,
    this.keywords = '',
  });

  final int uid;
  final String? tag;
  final String keywords;
  final List<bool Function(dynamic)> verifiers = [
    (jsonData) => (jsonData['ugc_pay'] as int) == 0,
    (jsonData) => !(jsonData['title'] as String).startsWith('【直播回放】'),
  ];

  Future<UserSummary> get userSummary async {
    final response = await RemoteApi.getBaseSrc(
      RemoteApiPath.userInfo,
      query: {'uids': uid.toString()},
    );

    final jsonData = (jsonDecode(response.body)['data'] as List)[0];
    jsonData['face'] = (await RemoteApi.get(
      Format.validUri(jsonData['face']),
    ))
        .bodyBytes;
    jsonData['tag'] = tag;

    return UserSummary.fromJson(jsonData);
  }

  void addVerifier(bool Function(dynamic) verifier) => verifiers.add(verifier);

  Future<({List<AudioSummary> audioSummaries, bool isLastPage})> getPage(
      {int pageKey = 1, int pageSize = 15}) async {
    final response = await RemoteApi.getBaseSrc(
      RemoteApiPath.userSpace,
      query: {
        'mid': uid.toString(),
        'keywords': keywords,
        'ps': pageSize.toString(),
        'pn': pageKey.toString(),
      },
    );
    final jsonResponseData = json.decode(response.body)['data'];
    final isLastPage = (jsonResponseData['page']['num'] as int) *
            (jsonResponseData['page']['size'] as int) >=
        (jsonResponseData['page']['total'] as int);

    return (
      audioSummaries: await Future.wait(
        (jsonResponseData['archives'] as List).map(
          (jsonData) async {
            if (verifiers.any(
              (verifier) => !verifier(jsonData),
            )) {
              return AudioSummary.invalid();
            }

            final viewResponse = await RemoteApi.getBaseSrc(
              RemoteApiPath.audioInfo,
              query: {'bvid': jsonData['bvid']},
            );
            var viewJson = json.decode(viewResponse.body)['data'];
            if (viewJson['is_upower_exclusive'] as bool) {
              return AudioSummary.invalid();
            }

            viewJson['author'] = viewJson['owner']['name'] as String;
            viewJson['mid'] = uid;
            viewJson['play'] = viewJson['stat']['view'] as int;

            var duration = (viewJson['duration'] as int);
            if (duration > 0) {
              duration--;
            }
            viewJson['duration'] = '${duration ~/ 60}:${(duration % 60)}';

            viewJson['pic'] = (await RemoteApi.get(
              Format.validUri(viewJson['pic']),
            ))
                .bodyBytes;

            viewJson['description'] = viewJson['desc'] as String;
            viewJson['like'] = viewJson['stat']['like'] as int;
            viewJson['favorites'] = viewJson['stat']['favorite'] as int;

            return AudioSummary.fromJson(viewJson);
          },
        ),
      ),
      isLastPage: isLastPage,
    );
  }
}
