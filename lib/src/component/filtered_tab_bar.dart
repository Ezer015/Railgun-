import 'package:flutter/material.dart';

class FilteredTabBar extends StatefulWidget {
  const FilteredTabBar({
    super.key,
    required this.tabTexts,
    required this.filters,
    required this.controller,
  })  : assert(tabTexts.length > 0),
        assert(filters.length > 0);

  final List<String> tabTexts;
  final List<
      ({
        String text,
        IconData leadingIcon,
        void Function()? onPressed,
      })> filters;
  final TabController controller;

  @override
  State<FilteredTabBar> createState() => _FilteredTabBarState();
}

class _FilteredTabBarState extends State<FilteredTabBar>
    with SingleTickerProviderStateMixin {
  static const _tabHeight = 40.0;

  late final _controller = widget.controller;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _tabHeight,
          child: Row(
            children: [
              Flexible(
                child: TabBar(
                  controller: _controller,
                  tabs: [
                    for (var tabText in widget.tabTexts)
                      Tab(text: tabText, height: _tabHeight),
                  ],
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  dividerColor: Colors.transparent,
                ),
              ),
              MenuAnchor(
                style: MenuStyle(
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).highlightColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                alignmentOffset: const Offset(-51, 6),
                menuChildren: [
                  for (var entry in widget.filters.asMap().entries)
                    Opacity(
                      opacity: entry.key == _selectedIndex ? 1 : .5,
                      child: MenuItemButton(
                        onPressed: () {
                          setState(() => _selectedIndex = entry.key);
                          entry.value.onPressed?.call();
                        },
                        leadingIcon: Icon(entry.value.leadingIcon),
                        child: Text(entry.value.text),
                      ),
                    ),
                ],
                builder: (_, menuController, __) => IconButton(
                  visualDensity: VisualDensity.comfortable,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (menuController.isOpen) {
                      menuController.close();
                    } else {
                      menuController.open();
                    }
                  },
                  icon: const Opacity(
                    opacity: .5,
                    child: Icon(Icons.filter_alt_outlined),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0, color: Theme.of(context).dividerColor),
      ],
    );
  }
}
