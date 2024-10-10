abstract class Format {
  static String validTitle(String title) =>
      title.replaceAll(RegExp(r'<[^>]*>'), '');

  static Uri validUri(String uri) => Uri.parse(
        uri.startsWith('//')
            ? "https:$uri"
            : (uri.replaceAll('http://', 'https://')),
      );
}
