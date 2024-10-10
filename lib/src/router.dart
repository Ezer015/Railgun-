import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'pages.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (_, __) => const SafeArea(
        child: HomePage(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'search/:keyword',
          builder: (_, state) => SafeArea(
            child: SearchPage(keyword: state.pathParameters['keyword']!),
          ),
        ),
      ],
    ),
  ],
);
