import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models.dart';
import '../services.dart';
import '../utils.dart';

class UserView extends StatefulWidget {
  const UserView({
    super.key,
    required this.userApi,
    this.height = 112.5,
  });

  final UserApi userApi;
  final double height;

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  static const _pageSize = 5;
  static const _padding = 4.0;

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
      final (audioSummaries: newItems, isLastPage: isLastPage) =
          await widget.userApi.getPage(pageKey: pageKey, pageSize: _pageSize);
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
  Widget build(BuildContext context) => Flexible(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: widget.height + _padding * 2,
          ),
          child: PagedListView<int, AudioSummary>(
            scrollDirection: Axis.horizontal,
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<AudioSummary>(
              itemBuilder: (context, item, index) {
                if (!item.isValid) {
                  return const SizedBox.shrink();
                }

                return InkWell(
                  onTap: () async {
                    if (item.isValid) {
                      await AudioPlayApi.pause();
                      await AudioPlayApi.add(item);
                      await AudioPlayApi.seekTo(item);
                      AudioPlayApi.play();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(_padding),
                    child: UserItem(
                      item: item,
                      height: widget.height,
                    ),
                  ),
                );
              },
              newPageProgressIndicatorBuilder: (context) =>
                  const SizedBox.shrink(),
              firstPageProgressIndicatorBuilder: (context) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),
      );
}

class UserItem extends StatefulWidget {
  const UserItem({
    super.key,
    required this.item,
    required this.height,
  });

  static const _circular = 4.0;
  static const _textPadding = 6.0;
  static const _ratio = 4 / 3;
  static const _expandedRatio = 21 / 9;

  final double height;
  final AudioSummary item;

  @override
  _UserItemState createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  final _scrollController = ScrollController();
  bool _isLongPressed = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewImage = ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(UserItem._circular),
        topRight: Radius.circular(UserItem._circular),
      ),
      child: AspectRatio(
        aspectRatio: _isLongPressed ? UserItem._expandedRatio : UserItem._ratio,
        child: Image.memory(
          widget.item.pic,
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
            ' ${Display.formatDuration(widget.item.duration)} ',
            style: const TextStyle(color: Colors.white, fontSize: 8.5),
          ),
        ),
      ),
    );

    final playDisplay = Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 1),
              const Icon(
                Icons.play_arrow_rounded,
                size: 12,
                color: Colors.white,
              ),
              Text(
                ' ${Display.formatPlay(widget.item.play)} ',
                style: const TextStyle(color: Colors.white, fontSize: 8.5),
              ),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onLongPress: () async {
        if (!_isLongPressed) {
          setState(() => _isLongPressed = true);
          if (_scrollController.position.maxScrollExtent >
              _scrollController.position.viewportDimension -
                  UserItem._textPadding * 2) {
            await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 2400),
              curve: Curves.easeIn,
            );
          }
        }
      },
      onLongPressUp: () async {
        if (_isLongPressed) {
          setState(() => _isLongPressed = false);
          await _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
          );
        }
      },
      child: SizedBox(
        height: widget.height,
        width: _isLongPressed
            ? widget.height * (UserItem._expandedRatio / UserItem._ratio)
            : widget.height,
        child: Stack(
          children: [
            SizedBox(
              height: widget.height / UserItem._ratio,
              child: Stack(
                children: [
                  previewImage,
                  durationDisplay,
                  playDisplay,
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: widget.height * (1 - 1 / UserItem._ratio),
                width: _isLongPressed
                    ? widget.height *
                        (UserItem._expandedRatio / UserItem._ratio)
                    : widget.height,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(UserItem._circular),
                    bottomRight: Radius.circular(UserItem._circular),
                  ),
                ),
                padding: const EdgeInsets.all(UserItem._textPadding),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Text(
                    Display.formatTitle(widget.item.title, simplify: true),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
