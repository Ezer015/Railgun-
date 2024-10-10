import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models.dart';
import '../services.dart';
import '../utils.dart';

class SearchView extends StatefulWidget {
  const SearchView({
    super.key,
    required this.searchApi,
  });

  final SearchApi searchApi;

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  static const _pageSize = 10;
  static const _padding = 12.0;

  final PagingController<int, AudioSummary> _pagingController =
      PagingController(firstPageKey: 1);
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await widget.searchApi.getPage(pageKey: pageKey, pageSize: _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (_isDisposed) {
        return;
      }
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, ++pageKey);
      }
    } catch (error) {
      if (_isDisposed) {
        return;
      }
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, AudioSummary>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<AudioSummary>(
          itemBuilder: (context, item, index) {
            if (!item.isValid) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                InkWell(
                  onTap: () async {
                    if (item.isValid) {
                      await AudioPlayApi.pause();
                      await AudioPlayApi.add(item);
                      await AudioPlayApi.seekTo(item);
                      AudioPlayApi.play();
                    }
                  },
                  onLongPress: () {
                    if (item.isValid) {
                      Clipboard.setData(
                        ClipboardData(text: item.bvid!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(_padding),
                    child: SearchItem(item: item),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _padding),
                  child: Divider(
                    height: 0,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class SearchItem extends StatelessWidget {
  const SearchItem({
    super.key,
    required this.item,
  });

  final AudioSummary item;

  @override
  Widget build(BuildContext context) {
    final previewImage = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.memory(
          item.pic,
          fit: BoxFit.cover,
        ),
      ),
    );

    final durationDisplay = Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.6),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            ' ${Display.formatDuration(item.duration)} ',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );

    final titleDisplay = Align(
      alignment: Alignment.topLeft,
      child: Text(
        Display.formatTitle(item.title),
        // style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final authorDisplay = Row(
      children: [
        const Icon(
          Icons.person,
          size: 18,
          color: Colors.grey,
        ),
        const SizedBox(width: 3),
        Text(
          item.author,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );

    final playAndPubDate = Row(
      children: [
        const Icon(
          Icons.play_circle_outline,
          size: 18,
          color: Colors.grey,
        ),
        const SizedBox(width: 3),
        Text(
          '${Display.formatPlay(item.play)} · ${Display.formatPubDate(item.pubDate)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );

    return IntrinsicHeight(
      child: Row(
        children: [
          Flexible(
            flex: 14,
            child: Stack(
              children: [
                previewImage,
                durationDisplay,
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 17,
            child: Stack(
              children: [
                titleDisplay,
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      authorDisplay,
                      const SizedBox(height: 2),
                      playAndPubDate,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
