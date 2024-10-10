import 'package:flutter/foundation.dart';
import 'package:railgun_minus/src/utils.dart';

@immutable
class AudioSummary {
  const AudioSummary({
    required this.bvid,
    required this.title,
    required this.author,
    required this.mid,
    required this.play,
    required this.pubDate,
    required this.duration,
    required this.pic,
    required this.description,
    // required this.tags,
    required this.like,
    required this.favorites,
  });

  AudioSummary.invalid()
      : bvid = null,
        title = '',
        author = '',
        mid = 0,
        play = 0,
        pubDate = DateTime(0),
        duration = '',
        pic = Uint8List(0),
        description = '',
        // tags = const [],
        like = 0,
        favorites = 0;

  factory AudioSummary.fromJson(Map<String, Object?> json) => AudioSummary(
        bvid: json['bvid'] as String,
        title: Format.validTitle(json['title'] as String),
        author: json['author'] as String,
        mid: json['mid'] as int,
        play: json['play'] as int,
        pubDate:
            DateTime.fromMillisecondsSinceEpoch((json['pubdate'] as int) * 1000)
                .toLocal(),
        duration: json['duration'] as String,
        pic: json['pic'] as Uint8List,
        description: json['description'] as String,
        // tags: (json['tag'] as String).split(','),
        like: json['like'] as int,
        favorites: json['favorites'] as int,
      );

  final String? bvid;
  final String title;
  final String author;
  final int mid;
  final int play;
  final DateTime pubDate;
  final String duration;
  final Uint8List pic;
  final String description;
  // final List<String> tags;
  final int like;
  final int favorites;

  @override
  bool operator ==(Object other) {
    return other is AudioSummary &&
        runtimeType == other.runtimeType &&
        bvid == other.bvid &&
        title == other.title &&
        author == other.author &&
        mid == other.mid &&
        play == other.play &&
        pubDate == other.pubDate &&
        duration == other.duration &&
        pic == other.pic &&
        description == other.description &&
        // tags == other.tags &&
        like == other.like &&
        favorites == other.favorites;
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      bvid,
      title,
      author,
      mid,
      play,
      pubDate,
      duration,
      pic,
      description,
      // tags,
      like,
      favorites,
    );
  }

  bool get isValid => bvid != null;
}
