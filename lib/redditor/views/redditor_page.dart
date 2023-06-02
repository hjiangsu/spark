import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/core/utils/datetime.dart';
import 'package:spark/core/utils/numbers.dart';

import 'package:spark/redditor/bloc/redditor_bloc.dart';
import 'package:spark/redditor/widgets/redditor_feed_card_list.dart';

import 'package:spark/widgets/error_message/error_message.dart';

class RedditorPage extends StatefulWidget {
  final String username;

  const RedditorPage({super.key, required this.username});

  @override
  State<RedditorPage> createState() => _RedditorPageState();
}

class _RedditorPageState extends State<RedditorPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => RedditorBloc(reddit: RedditClient.instance),
      child: BlocBuilder<RedditorBloc, RedditorState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 70.0,
              centerTitle: false,
              title: AutoSizeText(
                widget.username,
                style: theme.textTheme.titleLarge,
              ),
              actions: const [],
            ),
            body: getRedditorSubmissionBody(context, state.status, state),
          );
        },
      ),
    );
  }

  // Determines the feed body based on the status of the RedditorBloc
  Widget getRedditorSubmissionBody(BuildContext context, RedditorStatus status, RedditorState state) {
    final theme = Theme.of(context);

    switch (state.status) {
      case RedditorStatus.initial:
        context.read<RedditorBloc>().add(RedditorRefeshed(username: widget.username));
        return const Center(child: CircularProgressIndicator());
      case RedditorStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case RedditorStatus.fetching:
      case RedditorStatus.success:
        String avatar = 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_1.png';

        if (state.redditorInstance?.information?["snoovatar_img"] != null && state.redditorInstance?.information?["snoovatar_img"] != "") {
          avatar = HtmlUnescape().convert(state.redditorInstance?.information?["snoovatar_img"]);
        } else if (state.redditorInstance?.information?["icon_img"] != null && state.redditorInstance?.information?["icon_img"] != "") {
          avatar = HtmlUnescape().convert(state.redditorInstance?.information?["icon_img"]);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                foregroundImage: CachedNetworkImageProvider(avatar),
                maxRadius: 70,
              ),
              const SizedBox(height: 24),
              Text(
                state.redditorInstance?.information?["name"] ?? "-",
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${formatNumberToK(state.redditorInstance?.information?["total_karma"] ?? 0)}  ·  ${formatTimeToString(epochTime: state.redditorInstance?.information?["created_utc"]?.toInt() ?? 0)}',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.textTheme.labelMedium?.color?.withAlpha(200)),
              ),
              const SizedBox(height: 24),
              RedditorFeedCardList(posts: state.posts, hasLoadedAllPosts: state.noMoreSubmissions),
            ],
          ),
        );
      case RedditorStatus.empty:
        return const ErrorMessage(
          message: 'No posts were found',
          icon: Icons.not_interested_rounded,
        );
      case RedditorStatus.failure:
        return const ErrorMessage(message: 'Oops, an unexpected error occurred.');
      default:
        return Container();
    }
  }
}
