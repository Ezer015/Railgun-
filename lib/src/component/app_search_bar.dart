import 'package:flutter/material.dart';

import '../services.dart';

class AppSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const AppSearchBar({
    super.key,
    this.height = 60,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 4),
    this.searchText = '',
    required this.controller,
    required this.onSubmitted,
  });

  final double height;
  final EdgeInsets padding;
  final String searchText;
  final TextEditingController controller;
  final void Function(String) onSubmitted;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final _controller = widget.controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: SearchBar(
          controller: _controller,
          focusNode: _focusNode,
          leading: const Opacity(opacity: .6, child: Icon(Icons.search)),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              side: BorderSide(
                  color: (Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColorLight)
                      .withOpacity(.85),
                  width: 1.6),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16)),
          onTapOutside: (event) => _focusNode.unfocus(),
          onSubmitted: (value) {
            if (value == '') {
              return;
            }
            if (value.startsWith('>')) {
              var commands = value.split(RegExp(r'\s+'));
              if (commands[0] == '>' && commands.length > 1) {
                switch (commands[1]) {
                  case 'up':
                    if (commands.length > 2) {
                      switch (commands[2]) {
                        case 'add':
                          switch (commands.length) {
                            case 4:
                            case 5:
                            case 6:
                              var uid = int.tryParse(commands[3]);
                              var tag =
                                  commands.length > 4 ? commands[4] : null;
                              var pattern =
                                  commands.length > 5 ? commands[5] : null;
                              if (uid != null) {
                                SettingApi.addUp(
                                  uid: uid,
                                  tag: tag,
                                  pattern: pattern,
                                );
                                _controller.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Up $uid added')),
                                );
                                return;
                              }
                          }
                        case 'remove':
                          if (commands.length == 4) {
                            var uid = int.tryParse(commands[3]);
                            if (uid != null) {
                              SettingApi.removeUp(uid);
                              _controller.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Up $uid removed')),
                              );
                              return;
                            }
                          }
                        default:
                      }
                    }
                  default:
                }
              }
            }
            widget.onSubmitted(value);
          }),
    );
  }
}
