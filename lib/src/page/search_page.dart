import 'package:flutter/material.dart';
import 'package:railgun_minus/src/services.dart';

import '../components.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.keyword,
  }) : assert(keyword != '');

  final String keyword;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  static const _tabConfigs = [
    (
      text: '综合',
      value: 0,
    ),
    (
      text: '音乐',
      value: 3,
    ),
    (
      text: '虚拟',
      value: 30,
    ),
  ];
  static const _filterConfigs = [
    (
      text: '默认',
      value: 'totalrank',
      leadingIcon: Icons.menu,
    ),
    (
      text: '播放',
      value: 'click',
      leadingIcon: Icons.play_circle_outline,
    ),
    (
      text: '时间',
      value: 'pubdate',
      leadingIcon: Icons.access_time,
    ),
  ];

  final _searchController = TextEditingController();
  late final _tabController =
      TabController(length: _tabConfigs.length, vsync: this);

  late String _keyword = widget.keyword;
  String _order = _filterConfigs[0].value;

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppSearchBar(
        searchText: widget.keyword,
        controller: _searchController,
        onSubmitted: (value) => setState(() {
          _keyword = value;
          _order = _filterConfigs[0].value;
        }),
      ),
      body: Column(
        children: [
          FilteredTabBar(
            key: ValueKey(_keyword),
            tabTexts: [for (var tabConfig in _tabConfigs) tabConfig.text],
            filters: [
              for (var filterConfig in _filterConfigs)
                (
                  text: filterConfig.text,
                  leadingIcon: filterConfig.leadingIcon,
                  onPressed: () => setState(() => _order = filterConfig.value),
                ),
            ],
            controller: _tabController,
          ),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (var tabConfig in _tabConfigs)
                  SearchView(
                    key: ValueKey([_keyword, _order]),
                    searchApi: SearchApi(
                      keyword: _keyword,
                      order: _order,
                      typeId: tabConfig.value,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AudioView(),
    );
  }
}
