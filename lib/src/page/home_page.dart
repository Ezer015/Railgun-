import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:railgun_minus/src/model/user_summary.dart';

import '../components.dart';
import '../services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _userApis = [
    for (var up in SettingApi.Ups)
      if (up.pattern != null)
        UserApi(
          uid: up.uid,
          tag: up.tag,
        )..addVerifier(
            (jsonData) => RegExp(up.pattern!).hasMatch(jsonData['title']),
          )
      else
        UserApi(
          uid: up.uid,
          tag: up.tag,
        )
  ];
  final Map<UserApi, UserSummary> _userSummaries = {};

  @override
  void initState() {
    super.initState();
    for (var userApi in _userApis) {
      userApi.userSummary.then((value) {
        setState(() {
          _userSummaries[userApi] = value;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppSearchBar(
          controller: _controller,
          onSubmitted: (value) {
            context.go('/search/$value');
            _controller.clear();
          }),
      body: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var userApi in _userApis) ...[
                const SizedBox(height: 16),
                if (_userSummaries[userApi] != null) ...[
                  UserInfo(userSummary: _userSummaries[userApi]!),
                  const SizedBox(height: 4),
                ],
                UserView(userApi: userApi),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AudioView(),
    );
  }
}
