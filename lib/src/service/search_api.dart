import 'dart:convert';

import '../models.dart';
import '../utils.dart';
import 'remote_api.dart';

class SearchApi {
  const SearchApi({
    required this.keyword,
    this.order = 'totalrank',
    this.typeId = 0,
  }) : assert(keyword != '');

  final String keyword;
  final String order;
  final int typeId;

  Future<List<AudioSummary>> getPage(
      {int pageKey = 1, int pageSize = 15}) async {
    final response = await RemoteApi.getBaseSrc(
      RemoteApiPath.search,
      query: {
        'search_type': 'video',
        'keyword': keyword,
        'order': order,
        'tids': typeId.toString(),
        'page': pageKey.toString(),
        'page_size': pageSize.toString(),
      },
    );

    return await Future.wait(
      (json.decode(response.body)['data']['result'] as List).map(
        (jsonData) async {
          if (jsonData['type'] != 'video') {
            return AudioSummary.invalid();
          }

          final parts = (jsonData['duration'] as String).split(':');
          var minutes = int.parse(parts.first);
          var seconds = int.parse(parts.last);
          if (seconds > 0) {
            seconds--;
          } else if (minutes > 0) {
            minutes--;
            seconds = 59;
          }
          jsonData['duration'] = '$minutes:$seconds';

          jsonData['pic'] = (await RemoteApi.get(
            Format.validUri(jsonData['pic']),
          ))
              .bodyBytes;
          return AudioSummary.fromJson(jsonData);
        },
      ),
    );
  }
}
