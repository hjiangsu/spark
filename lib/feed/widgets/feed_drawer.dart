import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spark/core/auth/bloc/auth_bloc.dart';
import 'package:spark/core/enums/front_page_options.dart';
import 'package:spark/feed/bloc/feed_bloc.dart';
import 'package:spark/core/spark/bloc/spark_bloc.dart';

class FrontPageDestination {
  const FrontPageDestination(this.label, this.frontPage, this.icon);

  final String label;
  final FrontPage frontPage;
  final IconData icon;
}

const List<FrontPageDestination> frontPageDestinations = <FrontPageDestination>[
  FrontPageDestination('Home', FrontPage.home, Icons.home_rounded),
  FrontPageDestination('Popular Posts', FrontPage.popular, Icons.trending_up_rounded),
  FrontPageDestination('All Posts', FrontPage.all, Icons.grid_view_rounded),
];

class FeedDrawer extends StatefulWidget {
  final FrontPage frontPage;

  const FeedDrawer({super.key, this.frontPage = FrontPage.home});

  @override
  State<FeedDrawer> createState() => _FeedDrawerState();
}

class _FeedDrawerState extends State<FeedDrawer> {
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    selectedIndex = frontPageDestinations.indexWhere((element) => element.frontPage == widget.frontPage);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Drawer(
          child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text('Feed', style: Theme.of(context).textTheme.titleSmall),
            ),
            Column(
              children: frontPageDestinations.map((FrontPageDestination destination) {
                return FeedDrawerItem(
                    disabled: destination.frontPage == FrontPage.home && state.isUserAuthorized == false,
                    onTap: () {
                      context.read<SparkBloc>().state.feedContext?.read<FeedBloc>().add(FeedRefreshed(frontPage: destination.frontPage));
                      context.pop();
                    },
                    label: destination.label,
                    icon: destination.icon);
              }).toList(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text('Subscriptions', style: Theme.of(context).textTheme.titleSmall),
            ),
            (state.isUserAuthorized && state.subscriptions != null)
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Scrollbar(
                        // thumbVisibility: true,
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.subscriptions!.length,
                              itemBuilder: (context, index) {
                                return TextButton(
                                  style: TextButton.styleFrom(
                                    alignment: Alignment.centerLeft,
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  onPressed: () {
                                    context.read<SparkBloc>().state.feedContext?.read<FeedBloc>().add(FeedRefreshed(subreddit: state.subscriptions![index].information['display_name']));
                                    context.pop();
                                  },
                                  child: Text(state.subscriptions![index].information['display_name_prefixed']),
                                );
                              }),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
                    child: Text(
                      'No subscriptions available',
                      style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                    ),
                  )
          ],
        ),
      ));
    });
  }
}

class FeedDrawerItem extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  final bool disabled;

  const FeedDrawerItem({super.key, required this.onTap, required this.label, required this.icon, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: 56.0,
        child: InkWell(
          splashColor: disabled ? Colors.transparent : null,
          highlightColor: Colors.transparent,
          onTap: disabled ? null : onTap,
          customBorder: const StadiumBorder(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(width: 16),
                  Icon(icon, color: disabled ? theme.dividerColor : null),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: disabled ? theme.textTheme.bodyMedium?.copyWith(color: theme.dividerColor) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
