// Flutter package imports
import 'package:flutter/widgets.dart';

// External package imports
import 'package:go_router/go_router.dart';

// Spark package imports
import 'package:spark/feed/views/feed_page.dart';
import 'package:spark/post/views/post_page.dart';
import 'package:spark/search/views/search_page.dart';
import 'package:spark/account/views/account_page.dart';
import 'package:spark/redditor/views/redditor_page.dart';
import 'package:spark/settings/views/settings_page.dart';
import 'package:spark/settings/views/appearance_settings_page.dart';
import 'package:spark/widgets/scaffold_nav_bar/scaffold_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/feed',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/feed',
          pageBuilder: (context, state) => const NoTransitionPage(child: FeedPage()),
          routes: <RouteBase>[
            GoRoute(
              path: 'subreddit/:id',
              builder: (BuildContext context, GoRouterState state) {
                return FeedPage(subreddit: state.pathParameters['id']!);
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'post/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    return PostPage(postId: state.pathParameters['id']!);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'post/:id',
              builder: (BuildContext context, GoRouterState state) {
                return PostPage(postId: state.pathParameters['id']!);
              },
            ),
            GoRoute(
              path: 'redditor/:id',
              builder: (BuildContext context, GoRouterState state) {
                return RedditorPage(username: state.pathParameters['id']!);
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'post/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    return PostPage(postId: state.pathParameters['id']!);
                  },
                ),
              ],
            )
          ],
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(child: SearchPage()),
          routes: <RouteBase>[
            GoRoute(
              path: 'subreddit/:id',
              builder: (BuildContext context, GoRouterState state) {
                return FeedPage(subreddit: state.pathParameters['id']!);
              },
              routes: <RouteBase>[
                GoRoute(
                    path: 'post/:id',
                    builder: (BuildContext context, GoRouterState state) {
                      return PostPage(postId: state.pathParameters['id']!);
                    },
                    routes: const <RouteBase>[]),
              ],
            ),
            GoRoute(
              path: 'redditor/:id',
              builder: (BuildContext context, GoRouterState state) {
                return RedditorPage(username: state.pathParameters['id']!);
                // return FeedPage(redditor: state.pathParameters['id']!);
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'post/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    return PostPage(postId: state.pathParameters['id']!);
                  },
                  routes: const <RouteBase>[],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/mail',
          builder: (context, state) => Container(),
          routes: const <RouteBase>[],
        ),
        GoRoute(
          path: '/account',
          pageBuilder: (context, state) => const NoTransitionPage(child: AccountPage()),
          routes: const <RouteBase>[],
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
          routes: <RouteBase>[
            GoRoute(
              path: 'appearance',
              builder: (BuildContext context, GoRouterState state) {
                return const AppearanceSettingsPage();
              },
              routes: const <RouteBase>[],
            ),
          ],
        ),
      ],
    ),
  ],
);
