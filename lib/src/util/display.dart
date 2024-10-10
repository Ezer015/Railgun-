import 'package:html_unescape/html_unescape_small.dart';

abstract class Display {
  static String formatTitle(String title, {bool simplify = false}) {
    final unescapedTitle = HtmlUnescape().convert(title);
    return simplify
        ? unescapedTitle.replaceAll(RegExp(r'^【.*?】'), '')
        : unescapedTitle;
  }

  static String formatPlay(int play) {
    if (play < 10000) {
      return play.toString();
    }
    if (play < 100000000) {
      return '${(play / 10000).toStringAsFixed(1)}万';
    }
    return '${(play / 100000000).toStringAsFixed(1)}亿';
  }

  static String formatPubDate(DateTime pubDate) {
    final now = DateTime.now();
    final difference = now.difference(pubDate);

    if (difference.inSeconds < 60) {
      return '刚刚';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    }
    if (difference.inDays == 1) {
      return '昨天 ${pubDate.hour}:${pubDate.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inDays < 4) {
      return '${difference.inDays}天前';
    }
    if (now.year == pubDate.year) {
      return '${pubDate.month}月${pubDate.day}日';
    }
    return '${pubDate.year}年${pubDate.month}月${pubDate.day}日';
  }

  static String formatDuration(String duration) {
    if (duration == '') {
      return duration;
    }

    final parts = duration.split(':');
    if (parts.isEmpty) {
      return duration;
    }
    if (int.parse(parts.first) >= 60) {
      final hours = int.parse(parts.first) ~/ 60;
      final minutes = int.parse(parts.first) % 60;
      return '$hours:${minutes.toString().padLeft(2, '0')}:${parts.last.padLeft(2, '0')}';
    }
    return '${parts.first}:${parts.last.padLeft(2, '0')}';
  }
}
